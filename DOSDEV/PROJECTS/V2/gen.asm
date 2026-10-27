.model small
.stack 100h
SCREEN_W        equ 320
SCREEN_H        equ 200

MAX_PALETTE     equ 8       ; Максимальный размер палитры
MAX_T_BITS      equ 5       ; Максимальная точность t
SHIFT_STEP      equ 20      ; Шаг перемещения картинки в пикселях

; --- Смещения в структуре Header ---
; char signature[4];           (4 байта)
; unsigned short width;        (2 байта)
; unsigned short height;       (2 байта)
; unsigned short palette_size; (2 байта)
; unsigned short mix_bits;     (2 байта)
HDR_SIGNATURE   equ 0
HDR_WIDTH       equ 4
HDR_HEIGHT      equ 6
HDR_PAL_SIZE    equ 8
HDR_MIX_BITS    equ 10
HDR_SIZE        equ 12

; --- Смещения в структуре Content ---
; unsigned long file_size;      (4 байта)
; unsigned long palette_offset; (4 байта)
; unsigned long pixels_offset;  (4 байта)
CNT_FILE_SIZE   equ 0
CNT_PAL_OFF     equ 4
CNT_PIX_OFF     equ 8
CNT_SIZE        equ 12

; --- Смещения в структуре RGB24 ---
; unsigned char r, g, b;
RGB_R           equ 0
RGB_G           equ 1
RGB_B           equ 2
RGB_SIZE        equ 3

; ============================================================
; МАКРОСЫ
; ============================================================

; Печать строки (DS:DX -> строка)
PRINT_STR macro
 mov     ah, 09h
 int 21h
endm

; Выход 
EXIT macro 
 mov     ax, 4C00h
 int 21h
endm

; Ввод строки с клавиатуры (DS:DX -> буфер)
GET_STR macro
 mov     ah, 0Ah
 int 21h
endm

; Вывод одного символа (AL = символ)
PUT_CHAR macro
 mov     ah, 02h
 int 21h
endm

; Ожидание нажатия клавиши (результат в AL)
GET_CHAR macro
 mov     ah, 01h
 int 21h
endm

; Установка видеорежима (AL = режим)
SET_VIDEO macro
 mov     ah, 00h
 int 10h
endm

; Рисование пикселя (VGA 13h)
; Вход: SI = X, DI = Y, AL = цвет
; Портит: AX, BX, ES
PUT_PIXEL macro
 ; Проверка границ
 cmp  si, SCREEN_W
 jae  @@skip
 cmp  di, SCREEN_H
 jae  @@skip
 push ax         
 ; Вычисляем смещение: Y * 320 + X
 mov  ax, di
 mov  bx, SCREEN_W
 mul  bx         ; DX:AX = Y * 320
 add  ax, si     ; AX = Y * 320 + X
 mov  bx, ax     ; BX = смещение
 ; Запись в видеопамять
 push es
 mov  ax, vga_seg
 mov  es, ax
 pop  ax         
 mov  es:[bx], al
 pop  es

@@skip:
endm

; Выделить память (BX = сколько параграфов (16 байт), возвращает сегмент в AX)
ALLOC_MEM macro
 mov ah, 48h
 int 21h
 jc  @@alloc_err
@@alloc_err:
endm

; Освободить память (ES = сегмент)
FREE_MEM macro
 mov ah, 49h
 int 21h
endm

; ============================================================
; СЕГМЕНТ ДАННЫХ
; ============================================================
_DATA SEGMENT

 ; --- Видеопамять ---
 vga_off         dw 0            ; Смещение видеопамяти
 vga_seg         dw 0A000h       ; Сегмент видеопамяти

 ; --- Текущее состояние открытого файла ---
 current_header  db HDR_SIZE dup(0)  ; Структура Header (12 байт)
 current_content db CNT_SIZE dup(0)  ; Структура Content (12 байт)
 current_palette db MAX_PALETTE * RGB_SIZE dup(0) ; Палитра (до 24 байт)

 ; --- Размеры буферов ---
 raster_size     dw 0            ; Размер сырого буфера (в байтах)
 total_pixels    dw 0            ; Общее количество пикселей (width * height)
 p_bytes         db 0            ; Размер одного пикселя в байтах (1 или 2)
 i_bits          db 0            ; Биты для индекса (1, 2 или 3)

 ; --- Указатели на буферы (сегмент:смещение) ---
 ; Так как в DOS память сегментирована, будем хранить указатели
 raster_ptr      dd 0            ; Указатель на сырой буфер
 decoded_ptr     dd 0            ; Указатель на декодированный буфер

 ; --- Переменные для VIEW (отрисовки) ---
 raster_seg      dw 0    ; Сегмент сырого буфера
 decoded_seg     dw 0    ; Сегмент декодированного буфера

 ; --- Временные переменные для разных функций ---
 temp_ax         dw 0
 temp_bx         dw 0
 temp_cx         dw 0
 temp_dx         dw 0

 msg_help db 'QBT1 MVP (Turbo C)', 13, 10
 db 'Commands:', 13, 10
 db '  h - help', 13, 10
 db '  c - create', 13, 10
 db '  o - open', 13, 10
 db '  e - exit', 13, 10, '$'
 msg_prompt      db '> $'
 msg_unknown     db 'Unknown command.', 13, 10, '$'
 msg_create      db 13, 10, '--- Create New QBT1 File ---', 13, 10, '$'
 msg_open        db 'Opened file successfully.', 13, 10, '$'
 msg_err_open    db 'Error: Cannot open file.', 13, 10, '$'
 msg_err_read    db 'Error: Read error.', 13, 10, '$'
 msg_err_sig     db 'Error: Invalid format.', 13, 10, '$'

 ; Буфер для ввода команды (с префиксом длины для DOS 0Ah)
 input_buf       db 20          ; Максимальная длина
 db 0            ; Фактическая длина (заполняется DOS)
 input_str       db 20 dup(0)   ; Сама строка
 filename_buf    db 10 dup(0)   ; Сюда копируем имя файла с нулем на конце

_DATA ENDS

_TEXT SEGMENT
 ASSUME CS:_TEXT, DS:_DATA, ES:_DATA

 main proc near
  mov  ax, _DATA
  mov  ds, ax
  mov  es, ax

  ; Печатаем приветствие
  lea  dx, msg_help
PRINT_STR

main_loop:
  ; Печатаем приглашение "> "
  lea  dx, msg_prompt
PRINT_STR
  ; Ввод строки
  lea  dx, input_buf
GET_STR

  ; Переводим строку на новую (так как Enter от DOS не выводится)
  mov  al, 13
PUT_CHAR
  mov  al, 10
PUT_CHAR

  ; Проверяем, что ввели хотя бы один символ
  mov  cl, [input_buf + 1] ; CL = длина строки
  cmp  cl, 0
  je   main_loop

  ; Проверяем команды
  ; 'e' - exit
  mov  al, [input_str]
  cmp  al, 'e'
  je   do_exit

  ; 'h' - help
  cmp  al, 'h'
  je   do_help

  ; 'c' - create
  cmp  al, 'c'
  je   do_create

  ; 'o' - open (начинается с 'o', а потом пробел)
  cmp  al, 'o'
  jne  unknown_cmd
  cmp  byte ptr [input_str + 1], ' '
  jne  unknown_cmd
  jmp  do_open

do_help:
  lea  dx, msg_help
PRINT_STR
  jmp  main_loop

do_create:
  call    create_image
  jmp  main_loop

do_open:
  lea  si, input_str + 2  ; Пропускаем "o "
  lea  di, filename_buf
@@copy_loop:
  mov  al, [si]
  cmp  al, 13             ; Если дошли до Enter
  je   @@end_copy
  cmp  al, 0              ; Или до нуля
  je   @@end_copy
  mov  [di], al
  inc  si
  inc  di
  jmp  @@copy_loop
@@end_copy:
  mov  byte ptr [di], 0   ; Ставим нуль в конец

  lea  dx, filename_buf   ; DX = указатель на имя файла
  call open_image
  jmp  main_loop

unknown_cmd:
  lea  dx, msg_unknown
PRINT_STR
  jmp  main_loop

do_exit:
; Возврат в DOS
EXIT
 main endp

 ; ============================================================
 ; ЗАГЛУШКИ (пока пустые, будем заполнять по ходу)
 ; ============================================================
 create_image proc near
  ret
 create_image endp

 ; ============================================================
 ; open_image
 ; Вход: DS:DX -> строка с именем файла (уже с пробелом пропущенным)
 ; ============================================================
 open_image proc near
  push si
  push di
  push es

  ; --- 1. Открыть файл (DOS INT 21h, AH=3Dh) ---
  ; На входе DX должен указывать на строку имени файла.
  ; Но у нас имя файла лежит в input_str + 2 (пропускаем "o ")
  ; Нам нужно скопировать его в отдельный буфер с нулем на конце.
  ; Для простоты будем считать, что имя файла уже в DX (передадим из main)

  ; Внимание: в main мы вызываем "call open_image", но DX там указывает на input_buf.
  ; Нам нужно, чтобы DX указывал на имя файла (input_str + 2).
  ; Мы сделаем это в main перед вызовом! 
  ; Пока считаем, что DX уже настроен на имя файла с нулем на конце.
  ; Но DOS 0Ah не ставит ноль в конце... 
  ; Поэтому нам придется добавить ноль вручную в main.

  ; Открываем файл для чтения
  mov  ax, 3D00h      ; AH=3Dh (открыть), AL=00h (только чтение)
  int  21h
  jc   @@err_open     ; Если CF=1, ошибка
  mov  bx, ax         ; BX = файловый дескриптор (handle)

  ; --- 2. Прочитать заголовок (Content + Header) ---
  ; Нам нужно прочитать 24 байта в current_content и current_header
  ; В структуре QBT1_FileHeader сначала идет Content (12 байт), потом Header (12 байт)

  mov  ah, 3Fh        ; AH=3Fh (читать из файла)
  mov  cx, 12         ; Читаем 12 байт (Content)
  lea  dx, current_content ; Куда читать
  int  21h
  jc   @@err_read

  mov  ah, 3Fh
  mov  cx, 12         ; Читаем 12 байт (Header)
  lea  dx, current_header
  int  21h
  jc   @@err_read

  ; --- 3. Проверить сигнатуру ("QBT1") ---
  ; Сравниваем 4 байта в current_header[0..3] с 'QBT1'
  cmp  byte ptr [current_header + HDR_SIGNATURE + 0], 'Q'
  jne  @@err_sig
  cmp  byte ptr [current_header + HDR_SIGNATURE + 1], 'B'
  jne  @@err_sig
  cmp  byte ptr [current_header + HDR_SIGNATURE + 2], 'T'
  jne  @@err_sig
  cmp  byte ptr [current_header + HDR_SIGNATURE + 3], '1'
  jne  @@err_sig

  ; --- 4. Вывести успешное сообщение и данные ---
  lea  dx, msg_open
PRINT_STR

  ; Выводим ширину
  mov  ax, word ptr [current_header + HDR_WIDTH]
  call print_num    ; Вызовем функцию печати числа (напишем ниже)

  ; Выводим высоту
  mov  ax, word ptr [current_header + HDR_HEIGHT]
  call print_num

  ; Переход на новую строку
  mov  al, 13
PUT_CHAR
  mov  al, 10
PUT_CHAR

  ; --- 5. Закрыть файл (DOS INT 21h, AH=3Eh) ---
  mov  ah, 3Eh
  int  21h

  jmp  @@end

@@err_open:
  lea  dx, msg_err_open
PRINT_STR
  jmp  @@end

@@err_read:
  lea  dx, msg_err_read
PRINT_STR
  jmp  @@end

@@err_sig:
  lea  dx, msg_err_sig
PRINT_STR
  jmp  @@end

@@end:
  pop  es
  pop  di
  pop  si
  ret  
 open_image endp

 ; ============================================================
 ; Вспомогательная функция: вывод беззнакового числа в AX на экран
 ; ============================================================
 print_num proc near
  ; Реализация простого вывода числа (например, 320)
  ; Использует стек для сохранения цифр
  push ax
  push bx
  push cx
  push dx

  mov  cx, 0       ; Счетчик цифр
  mov  bx, 10      ; Делитель

@@div_loop:
  xor  dx, dx
  div  bx          ; DX:AX / 10 -> AX = частное, DX = остаток
  push dx          ; Остаток в стек (цифра)
  inc  cx
  test ax, ax
  jnz  @@div_loop

@@print_loop:
  pop  dx
  add  dl, '0'     ; Превращаем цифру в символ
  mov  al, dl
PUT_CHAR
  loop @@print_loop

  pop  dx
  pop  cx
  pop  bx
  pop  ax
  ret  
 print_num endp

_TEXT ENDS

 ; ============================================================
 ; КОНЕЦ ФАЙЛА
 ; ============================================================
 END main