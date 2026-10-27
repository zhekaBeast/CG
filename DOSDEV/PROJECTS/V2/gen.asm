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
; --- Буфер для чтения строки изображения ---
LINE_BUFFER_SIZE equ 640       ; (макс. строка 320*2 = 640 байт)

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

; Ввод строки с клавиатуры (DS:DX -> буфер)
; Ввод строки с клавиатуры (DS:DX -> буфер)
; После вызова в строке гарантированно стоит '\0' в конце!
GET_STR macro
 mov  ah, 0Ah
 int  21h

 ; --- Добавляем '\0' в конец строки ---
 push    ax
 push    bx
 push    cx
 push    si

 mov  si, dx             ; SI = указатель на буфер (DX нельзя использовать в [DX+const])
 mov  cl, [si + 1]       ; CL = фактическая длина (byte ptr)
 mov  ch, 0
 add  si, 2              ; SI -> начало строки
 add  si, cx             ; SI -> первый байт после строки
 mov  byte ptr [si], 13   
 mov  byte ptr [si+1], 10   

 pop  si
 pop  cx
 pop  bx
 pop  ax
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
 p_bytes         db 0            ; Размер одного пикселя (1 или 2)
 i_bits          db 0            ; Биты для индекса (1, 2 или 3)

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
 msg_err_mem     db 'Error: Out of memory.', 13, 10, '$'
 msg_err_seek    db 'Error: Seek failed.', 13, 10, '$'

 ; Буфер для ввода команды (с префиксом длины для DOS 0Ah)
 input_buf       db 20          ; Максимальная длина
 db 0            ; Фактическая длина (заполняется DOS)
 input_str       db 20 dup(0)   ; Сама строка
 filename_buf    db 10 dup(0)   ; Сюда копируем имя файла с нулем на конце
 raster db 


 line_buffer      db LINE_BUFFER_SIZE dup(0)
 file_handle      dw 0           ; Дескриптор файла, который держим открытым для просмотра
_DATA ENDS

_TEXT SEGMENT
 ASSUME CS:_TEXT, DS:_DATA, ES:_DATA
 ; ============================================================
 ; main
 ; Главный цикл консоли: печать "> ", чтение строки,
 ; разбор команды (h / c / o <file> / e) и вызов обработчиков.
 ; ============================================================
 main proc near
  push ds
  mov  ax, _DATA
  mov  ds, ax

  lea  dx, msg_help
PRINT_STR

@@loop:
  lea  dx, msg_prompt
PRINT_STR
  ; --- Чтение строки в input_buf (DOS 0Ah) ---
  lea  dx, input_buf
GET_STR
  ; --- Проверка длины введённой строки ---
  mov  cl, [input_buf + 1]   ; фактическая длина
  mov  ch, 0
  test cx, cx
  jz   @@unknown             ; пустая строка — неизвестная команда
  ; --- Первый символ команды ---
  mov  al, [input_str]
  cmp  al, 'e'
  je   @@exit
  cmp  al, 'h'
  je   @@help
  cmp  al, 'c'
  je   @@create
  cmp  al, 'o'
  je   @@maybe_open

  jmp  @@unknown

@@help:
  lea  dx, msg_help
PRINT_STR
  jmp  @@loop      
@@create:
  call create_image
  jmp  @@loop
; -------- o <file> : open --------

@@maybe_open:
  ; должно быть "o " + имя, минимум 3 символа
  cmp  cx, 3
  jb   @@unknown
  cmp  byte ptr [input_str + 1], ' '
  jne  @@unknown
  ; --- Копируем имя файла из input_str+2 в filename_buf с '\0' ---
  lea  si, [input_str + 2]      ; SI -> начало имени
  lea  di, filename_buf         ; DI -> буфер назначения
  mov  cl, [input_buf + 1]      ; CL = фактическая длина введенной строки
  mov  ch, 0
  sub  cx, 2                    ; вычитаем "o " (2 символа)

@@copy_name:
  mov  al, [si]                 ; AL = текущий символ
  mov  [di], al                 ; копируем
  inc  si
  inc  di
  dec  cx
  jnz  @@copy_name

  mov  byte ptr [di], 0         ; СТАВИМ '\0' В КОНЕЦ!

  ; --- Вызываем open_image с правильным указателем ---
  lea  dx, filename_buf
  call open_image
  jmp  @@loop
; -------- неизвестная команда --------
@@unknown:
  lea  dx, msg_unknown
PRINT_STR
  jmp  @@loop
; -------- e : exit --------
@@exit:
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
 ; ============================================================
; open_image
; Вход: DS:DX -> строка с именем файла (с '\0' на конце)
; ============================================================
open_image proc near
  push bx
  push cx
  push dx
  push si
  push di
  push es
  push ds

  ; --- 1. Открыть файл ---
  mov  ax, 3D00h
  int  21h
  jnc  @@ok_open
  jmp  @@err_open
@@ok_open:
  mov  [file_handle], ax  ; сохраняем дескриптор для view_image

  ; --- 2. Читаем Content (12 байт) и Header (12 байт) ---
  mov  bx, [file_handle]
  mov  ah, 3Fh
  mov  cx, 12
  lea  dx, current_content
  int  21h
  jnc  @@ok_read1
  jmp  @@err_read
@@ok_read1:

  mov  ah, 3Fh
  mov  cx, 12
  lea  dx, current_header
  int  21h
  jnc  @@ok_read2
  jmp  @@err_read
@@ok_read2:

  ; --- 3. Проверка сигнатуры "QBT1" ---
  lea  si, current_header
  cmp  byte ptr [si + HDR_SIGNATURE + 0], 'Q'
  jne  @@err_sig
  cmp  byte ptr [si + HDR_SIGNATURE + 1], 'B'
  jne  @@err_sig
  cmp  byte ptr [si + HDR_SIGNATURE + 2], 'T'
  jne  @@err_sig
  cmp  byte ptr [si + HDR_SIGNATURE + 3], '1'
  jne  @@err_sig

  ; --- 4. Вычисляем i_bits и p_bytes ---
  mov  al, byte ptr [current_header + HDR_PAL_SIZE]
  cmp  al, 2
  ja   @@chk4
  mov  cl, 1
  jmp  @@store_i
@@chk4:
  cmp  al, 4
  ja   @@chk8
  mov  cl, 2
  jmp  @@store_i
@@chk8:
  mov  cl, 3
@@store_i:
  mov  [i_bits], cl

  ; p_bytes = (2*i_bits + t_bits + 7) / 8
  mov  al, cl
  add  al, cl
  add  al, byte ptr [current_header + HDR_MIX_BITS]
  add  al, 7
  shr  al, 3
  mov  [p_bytes], al

  ; raster_size = width * height * p_bytes
  mov  ax, word ptr [current_header + HDR_WIDTH]
  mov  bx, word ptr [current_header + HDR_HEIGHT]
  mul  bx
  mov  cl, [p_bytes]
  mov  ch, 0
  mul  cx
  mov  [raster_size], ax

  ; --- 5. Выделяем память в куче ---
  add  ax, 15
  shr  ax, 4              ; AX = параграфы
  mov  bx, ax
  mov  ah, 48h
  int  21h
  jnc  @@ok_mem
  jmp  @@err_mem
@@ok_mem:
  mov  [raster_seg], ax

  ; --- 6. Читаем палитру ---
  ; LSEEK на palette_offset
  mov  ax, 4200h
  mov  bx, [file_handle]
  mov  dx, word ptr [current_content + CNT_PAL_OFF]
  mov  cx, word ptr [current_content + CNT_PAL_OFF + 2]
  int  21h
  jnc  @@ok_seek_pal
  jmp  @@err_seek
@@ok_seek_pal:

  mov  ah, 3Fh
  mov  cx, MAX_PALETTE * RGB_SIZE
  lea  dx, current_palette
  mov  bx, [file_handle]
  int  21h
  jnc  @@ok_read_pal
  jmp  @@err_read
@@ok_read_pal:

  ; --- 7. Читаем пиксели в кучу ---
  ; LSEEK на pixels_offset
  mov  ax, 4200h
  mov  bx, [file_handle]
  mov  dx, word ptr [current_content + CNT_PIX_OFF]
  mov  cx, word ptr [current_content + CNT_PIX_OFF + 2]
  int  21h
  jnc  @@ok_seek
  jmp  @@err_seek
@@ok_seek:

  ; Сохраняем DS, переключаемся на сегмент кучи
  mov  ax, ds
  mov  es, ax             ; ES = DS (данные)
  mov  ds, [raster_seg]   ; DS = сегмент кучи
  xor  dx, dx             ; смещение 0
  mov  cx, [raster_size]
  mov  ah, 3Fh
  mov  bx, [file_handle]
  int  21h
  jnc  @@ok_read3
  mov  ax, es
  mov  ds, ax             ; восстановили DS
  jmp  @@err_read
@@ok_read3:
  mov  ax, es
  mov  ds, ax             ; восстановили DS

  ; --- 8. Запускаем просмотр ---
  lea  dx, msg_open
  PRINT_STR
  call view_image

  ; --- 9. Освобождаем память ---
  mov  ax, [raster_seg]
  push ax
  pop  es
  mov  ah, 49h
  int  21h
  mov  [raster_seg], 0

  ; --- 10. Закрываем файл ---
  mov  ah, 3Eh
  mov  bx, [file_handle]
  int  21h
  jmp  @@end

; ==========================================
; ОБРАБОТКА ОШИБОК
; ==========================================
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

@@err_mem:
  lea  dx, msg_err_mem
  PRINT_STR
  jmp  @@end

@@err_seek:
  lea  dx, msg_err_seek
  PRINT_STR
  jmp  @@end

@@end:
  pop  ds
  pop  es
  pop  di
  pop  si
  pop  dx
  pop  cx
  pop  bx
  ret
open_image endp



 ; ============================================================
 ; decode_pixel
 ; Вход:  DS:SI -> указатель на пиксель в line_buffer
 ; Выход: AL = цвет VGA
 ; Портит: AX, BX, CX, DX, DI, BP
 ; ============================================================
 decode_pixel proc near
  push si                 ; Сохраняем SI, чтобы не сломать цикл вызова

  ; --- 1. Чтение p (1 или 2 байта) ---
  xor  ax, ax
  mov  al, [si]           ; Младший байт
  cmp  byte ptr [p_bytes], 1
  je   @@p_ready
  mov  ah, [si+1]         ; Старший байт
@@p_ready:
  mov  bp, ax             ; BP = p

  ; --- 2. Загружаем t_bits и i_bits ---
  mov  cl, byte ptr [current_header + HDR_MIX_BITS]  ; CL = t_bits
  mov  ch, byte ptr [i_bits]                         ; CH = i_bits

  ; --- 3. Вычисляем t = p & ((1 << t_bits) - 1) ---
  mov  al, 1
  shl  al, cl
  dec  al                 ; AL = mask_t
  mov  dl, al
  mov  al, byte ptr [temp_ax]   ; Младший байт p
  and  al, dl
  mov  dh, al             ; DH = t

  ; --- 4. Вычисляем i1 = (p >> t_bits) & mask_i ---
  mov  al, byte ptr [temp_ax]   ; Младший байт p
  shr  al, cl             ; AL = p >> t_bits (CL все еще t_bits)

  mov  dl, ch             ; Сохраняем i_bits в DL
  mov  cl, ch             ; CL = i_bits (временно)
  mov  bl, 1
  shl  bl, cl             ; BL = 1 << i_bits
  dec  bl                 ; BL = mask_i
  and  al, bl
  mov  bl, al             ; BL = i1

  mov  cl, dl             ; CL = t_bits


  ; --- 5. Вычисляем i2 = (p >> (t_bits + i_bits)) & mask_i ---
  mov  al, byte ptr [temp_ax]   ; Младший байт p
  add  cl, ch             ; CL = t_bits + i_bits
  shr  al, cl
  mov  cl, ch             ; CL = i_bits (восстанавливаем)
  mov  dl, 1
  shl  dl, cl
  dec  dl                 ; DL = mask_i
  and  al, dl
  mov  bh, al             ; BH = i2

  ; --- 6. Получаем c1 (r1, g1, b1) ---
  mov  al, bl
  mov  cl, 3
  mul  cl                 ; AX = i1 * 3
  mov  di, ax             ; DI = смещение в палитре
  mov  al, byte ptr [current_palette + di + RGB_R]
  mov  byte ptr [temp_ax], al      ; r1
  mov  al, byte ptr [current_palette + di + RGB_G]
  mov  byte ptr [temp_bx], al      ; g1
  mov  al, byte ptr [current_palette + di + RGB_B]
  mov  byte ptr [temp_cx], al      ; b1

  ; --- 7. Получаем c2 (r2, g2, b2) ---
  mov  al, bh
  mov  cl, 3
  mul  cl
  mov  di, ax
  mov  al, [current_palette + di + RGB_R]
  mov  byte ptr [temp_dx], al      ; r2
  mov  al, byte ptr [current_palette + di + RGB_G]
  mov  byte ptr [temp_ax + 1], al  ; g2
  mov  al, byte ptr [current_palette + di + RGB_B]
  mov  byte ptr [temp_bx + 1], al  ; b2

  ; --- 8. t_scaled = (t * 255) / max_t ---
  mov  al, dh             ; AL = t
  xor  ah, ah
  mov  cx, 255
  mul  cx                 ; AX = t * 255
  mov  cl, byte ptr [current_header + HDR_MIX_BITS]
  mov  dx, 1
  shl  dx, cl
  dec  dx                 ; DX = max_t
  div  dx                 ; AX = t_scaled
  mov  di, ax             ; DI = t_scaled

  ; --- 9. 255 - t_scaled ---
  mov  cx, 255
  sub  cx, di             ; CX = 255 - ts

  ; --- 10. r = (r1 * (255-ts) + r2 * ts) / 255 ---
  mov  al, byte ptr [temp_ax]
  xor  ah, ah
  mul  cx
  mov  bx, ax
  mov  al, byte ptr [temp_dx]
  xor  ah, ah
  mul  di
  add  bx, ax
  mov  ax, bx
  mov  bx, 255
  xor  dx, dx
  div  bx
  mov  byte ptr [temp_ax], al      ; r

  ; --- 11. g = (g1 * (255-ts) + g2 * ts) / 255 ---
  mov  al, byte ptr [temp_bx]
  xor  ah, ah
  mul  cx
  mov  bx, ax
  mov  al, byte ptr [temp_ax + 1]
  xor  ah, ah
  mul  di
  add  bx, ax
  mov  ax, bx
  mov  bx, 255
  xor  dx, dx
  div  bx
  mov  byte ptr [temp_bx], al      ; g

  ; --- 12. b = (b1 * (255-ts) + b2 * ts) / 255 ---
  mov  al, byte ptr [temp_cx]
  xor  ah, ah
  mul  cx
  mov  bx, ax
  mov  al, byte ptr [temp_bx + 1]
  xor  ah, ah
  mul  di
  add  bx, ax
  mov  ax, bx
  mov  bx, 255
  xor  dx, dx
  div  bx
  mov  byte ptr [temp_cx], al      ; b

  ; --- 13. Сборка цвета VGA ---
  mov  al, byte ptr [temp_ax]
  and  al, 0E0h
  mov  bl, al

  mov  al, byte ptr [temp_bx]
  and  al, 0E0h
  shr  al, 3
  or   bl, al

  mov  al, byte ptr [temp_cx]
  and  al, 0C0h
  shr  al, 6
  or   bl, al

  mov  al, bl             ; AL = результат

  pop  si                 ; Восстанавливаем SI
  ret  
 decode_pixel endp



; ============================================================
; view_image
; Вход: file_handle, current_header, current_content, raster_seg
; Делает построчную загрузку в line_buffer и отрисовку.
; ============================================================
view_image proc near
  push bx
  push cx
  push dx
  push si
  push di
  push es
  push ds

  ; --- 1. Установить видеорежим 13h ---
  mov  ax, 0013h
  int  10h

  ; --- 2. LSEEK на начало пикселей ---
  mov  ax, 4200h
  mov  bx, [file_handle]
  mov  dx, word ptr [current_content + CNT_PIX_OFF]
  mov  cx, word ptr [current_content + CNT_PIX_OFF + 2]
  int  21h
  jc   @@view_err

  ; --- 3. Цикл по строкам ---
  mov  word ptr [current_row], 0
  mov  ax, word ptr [current_header + HDR_HEIGHT]
  cmp  ax, 200
  jbe  @@height_ok
  mov  ax, 200            ; не рисуем ниже 200
@@height_ok:
  mov  [temp_ax], ax      ; temp_ax = min(height, 200)

@@row_loop:
  mov  ax, [current_row]
  cmp  ax, [temp_ax]
  jae  @@view_done

  ; --- 3.1. Читаем строку в line_buffer ---
  mov  ax, word ptr [current_header + HDR_WIDTH]
  mov  cl, [p_bytes]
  mov  ch, 0
  mul  cx
  mov  cx, ax             ; CX = width * p_bytes
  mov  ah, 3Fh
  lea  dx, line_buffer
  mov  bx, [file_handle]
  int  21h
  jc   @@view_err

  ; --- 3.2. Рисуем строку ---
  xor  si, si             ; SI = индекс в line_buffer
  xor  di, di             ; DI = X на экране
@@col_loop:
  cmp  di, word ptr [current_header + HDR_WIDTH]
  jae  @@next_row
  cmp  di, 320
  jae  @@next_row

  ; Вызов decode_pixel (вход: SI -> пиксель в line_buffer)
  call decode_pixel

  ; Рисуем (Y = current_row, X = DI, AL = цвет)
  push ax
  mov  ax, [current_row]
  mov  bx, 320
  mul  bx
  add  ax, di
  mov  bx, ax
  mov  ax, 0A000h
  mov  es, ax
  pop  ax
  mov  es:[bx], al

  ; Следующий пиксель
  mov  al, [p_bytes]
  xor  ah, ah
  add  si, ax
  inc  di
  jmp  @@col_loop

@@next_row:
  inc  word ptr [current_row]
  jmp  @@row_loop

@@view_done:
  ; --- 4. Ждём нажатия клавиши ---
  xor  ax, ax
  int  16h               ; AH=0, AL=ASCII
  ; (можно обрабатывать стрелки/зум, если нужно, но в MVP — просто ждём)

  ; --- 5. Возврат в текстовый режим ---
  mov  ax, 0003h
  int  10h

  jmp  @@view_exit

@@view_err:
  mov  ax, 0003h
  int  10h
  lea  dx, msg_err_read
  PRINT_STR

@@view_exit:
  pop  ds
  pop  es
  pop  di
  pop  si
  pop  dx
  pop  cx
  pop  bx
  ret
view_image endp



_TEXT ENDS
 ; ============================================================
 ; КОНЕЦ ФАЙЛА
 ; ============================================================
 END main