.model small
.stack 100h
SCREEN_W        equ 320
SCREEN_H        equ 200
VGA_OFF         equ 0            ; Смещение видеопамяти
VGA_SEG         equ 0A000h       ; Сегмент видеопамяти

MAX_PALETTE     equ 8       ; Максимальный размер палитры
MAX_T_BITS      equ 5       ; Максимальная точность t
SHIFT_STEP      equ 20      ; Шаг перемещения картинки в пикселях

; --- Смещения в структуре Header ---
HDR_SIGNATURE   equ 0   ; char signature[4];           (4 байта)
HDR_WIDTH       equ 4   ; unsigned short width;        (2 байта)
HDR_HEIGHT      equ 6   ; unsigned short height;       (2 байта)
HDR_PAL_SIZE    equ 8   ; unsigned short palette_size; (2 байта)
HDR_MIX_BITS    equ 10  ; unsigned short mix_bits;     (2 байта)
HDR_SIZE        equ 12

; --- Смещения в структуре Content ---
CNT_FILE_SIZE   equ 0 ;file_size;      (4 байта)
CNT_PAL_OFF     equ 4 ;palette_offset; (4 байта)
CNT_PIX_OFF     equ 8 ;pixels_offset;  (4 байта)
CNT_SIZE        equ 12

; --- Буфер для чтения строки сырого изображения ---
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

; Установка видеорежима 13h 
VIDEO_MODE macro
 mov  ax, 0013h
 int  10h
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

; --- Установка позиции в файле (LSEEK) ---
; Вход: BX = файловый дескриптор, CX:DX = 32-битное смещение
LSEEK macro
 mov  ax, 4200h
 int  21h
endm

; --- Закрытие файла ---
; Вход: BX = файловый дескриптор
CLOSE_FILE macro
 mov  ah, 3Eh
 int  21h
endm

; --- Чтение из файла (READ) ---
; Вход: BX = дескриптор, CX = сколько байт, DS:DX -> буфер
; Выход: AX = сколько прочитано
READ_FILE macro
 mov  ah, 3Fh
 int  21h
endm

; Ввод строки с клавиатуры (DS:DX -> буфер)
GET_STR macro
 mov  ah, 0Ah
 int  21h
endm

; Рисование пикселя (VGA 13h)
; Вход: SI = X, DI = Y, AL = цвет
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
 mov  ax, VGA_SEG
 mov  es, ax
 pop  ax         
 mov  es:[bx], al
 pop  es
@@skip:
endm

; ============================================================
; СЕГМЕНТ ДАННЫХ
; ============================================================

_DATA SEGMENT

 ; --- Текущее состояние открытого файла ---
 current_header  db HDR_SIZE dup(0)  ; Структура Header (12 байт)
 current_content db CNT_SIZE dup(0)  ; Структура Content (12 байт)
 current_palette db MAX_PALETTE * RGB_SIZE dup(0) ; Палитра (до 24 байт)
 p_bytes         db 0            ; Размер одного пикселя (1 или 2)
 i_bits          db 0            ; Биты для индекса (1, 2 или 3)


 ; Буфер для ввода команды (с префиксом длины для DOS 0Ah)
 input_buf       db 20          ; Максимальная длина
 db 0            ; Фактическая длина (заполняется DOS)
 input_str       db 20 dup(0)   ; Сама строка
 filename_buf    db 10 dup(0)   ; Сюда копируем имя файла с нулем на конце
 line_buffer      db LINE_BUFFER_SIZE dup(0)
 file_handle      dw 0           ; Дескриптор файла, который держим открытым для просмотра

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
 ; ЗАГЛУШКИ 
 ; ============================================================
 create_image proc near
  ret
 create_image endp



 ; ============================================================
 ; open_image
 ; Вход: DS:DX -> имя файла (с '\0' в конце)
 ; ============================================================
 open_image proc near
  ; --- 1. Открыть файл ---
  mov  ax, 3D00h
  int  21h
  jnc  @@ok_open
  jmp  @@err_open
@@ok_open:
  mov  [file_handle], ax

  ; --- 2. Читаем Content (12 байт) и Header (12 байт) ---
  mov  bx, [file_handle]
  mov  cx, 12
  lea  dx, current_content
READ_FILE
  jnc  @@ok_read1
  jmp  @@err_read
@@ok_read1:

  mov  cx, 12
  lea  dx, current_header
READ_FILE
  jnc  @@ok_read2
  jmp  @@err_read
@@ok_read2:

  ; --- 3. Проверка сигнатуры "QBT1" ---
  lea  si, current_header
  cmp  byte ptr [si + HDR_SIGNATURE + 0], 'Q'
  jne  @@sig_err_local
  cmp  byte ptr [si + HDR_SIGNATURE + 1], 'B'
  jne  @@sig_err_local
  cmp  byte ptr [si + HDR_SIGNATURE + 2], 'T'
  jne  @@sig_err_local
  cmp  byte ptr [si + HDR_SIGNATURE + 3], '1'
  je   @@sig_ok
@@sig_err_local:
  jmp  @@err_sig
@@sig_ok:

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

  mov  al, cl
  add  al, cl
  add  al, byte ptr [current_header + HDR_MIX_BITS]
  add  al, 7
  shr  al, 3
  mov  [p_bytes], al

  ; --- 5. Читаем палитру ---
  mov  bx, [file_handle]
  mov  dx, word ptr [current_content + CNT_PAL_OFF]
  mov  cx, word ptr [current_content + CNT_PAL_OFF + 2]
LSEEK
  jnc  @@ok_seek_pal
  jmp  @@err_seek
@@ok_seek_pal:

  mov  cx, MAX_PALETTE * RGB_SIZE
  lea  dx, current_palette
READ_FILE
  jnc  @@ok_read_pal
  jmp  @@err_read
@@ok_read_pal:

  ; --- 6. Передаём управление в view_image ---
  ; Все данные уже в DS (current_header, p_bytes, file_handle)
  call view_image

  ; --- 7. Закрываем файл ---
  mov  bx, [file_handle]
CLOSE_FILE
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
@@err_seek:
  lea  dx, msg_err_seek
PRINT_STR
  jmp  @@end

@@end:
  ret  
 open_image endp



 ; ============================================================
 ; view_image
 ; Вход: file_handle, current_header, current_content, raster_seg
 ; Делает построчную загрузку в line_buffer и отрисовку.
 ; ============================================================
 view_image proc near
  mov  bp, sp
  sub  sp, 32             ; Локальные переменные

  ; [bp-2]  = offset_x
  ; [bp-4]  = offset_y
  ; [bp-6]  = zoom
  ; [bp-8]  = start_x
  ; [bp-10] = start_y
  ; [bp-12] = end_x
  ; [bp-14] = end_y
  ; [bp-16] = y
  ; [bp-18] = x
  ; [bp-20] = dy
  ; [bp-22] = dx
  ; [bp-24] = row_size
  ; [bp-26] = color
  ; [bp-28] = key

  mov  word ptr [bp-2], 0
  mov  word ptr [bp-4], 0
  mov  word ptr [bp-6], 1
VIDEO_MODE

@@main_loop:
  ; --- Мудрая очистка экрана (серый фон 7) ---
  mov  ax, VGA_SEG
  mov  es, ax
  xor  di, di
  mov  cx, SCREEN_H * SCREEN_W / 2 ; 64000 байт / 2 (используем stosw)
  mov  ax, 0707h ; серость
  rep  stosw

  ; --- start_x = (offset_x < 0) ? (-offset_x / zoom) : 0;
  mov  ax, [bp-2]
  test ax, ax
  jns  @@sx_pos
  neg  ax
  cwd  
  idiv word ptr [bp-6]
  jmp  @@sx_done
@@sx_pos:
  xor  ax, ax
@@sx_done:
  mov  [bp-8], ax

  ; --- start_y = (offset_y < 0) ? (-offset_y / zoom) : 0;
  mov  ax, [bp-4]
  test ax, ax
  jns  @@sy_pos
  neg  ax
  cwd  
  idiv word ptr [bp-6]
  jmp  @@sy_done
@@sy_pos:
  xor  ax, ax
@@sy_done:
  mov  [bp-10], ax

  ; --- end_x = (VIEW_W - offset_x) / zoom + 1;
  mov  ax, 320
  sub  ax, [bp-2]
  cwd  
  idiv word ptr [bp-6]
  inc  ax
  mov  [bp-12], ax

  ; --- end_y = (VIEW_H - offset_y) / zoom + 1;
  mov  ax, 200
  sub  ax, [bp-4]
  cwd  
  idiv word ptr [bp-6]
  inc  ax
  mov  [bp-14], ax

  ; --- Корректировки ---
  ; if (end_x > current_header.width)
  ;  end_x = current_header.width;
  ; if (end_y > current_header.height)
  ;  end_y = current_header.height;
  mov  ax, word ptr [current_header + HDR_WIDTH]
  cmp  [bp-12], ax
  jle  @@ex_ok
  mov  [bp-12], ax
@@ex_ok:
  mov  ax, word ptr [current_header + HDR_HEIGHT]
  cmp  [bp-14], ax
  jle  @@ey_ok
  mov  [bp-14], ax
@@ey_ok:

  ; row_size = width * p_bytes
  mov  ax, word ptr [current_header + HDR_WIDTH]
  xor  cx, cx
  mov  cl, [p_bytes]
  mul  cx
  mov  [bp-24], ax

  ; --- Цикл по Y ---
  mov  ax, [bp-10]
  mov  [bp-16], ax

@@row_loop:
  mov  ax, [bp-16]
  cmp  ax, [bp-14]
  jb   @@draw_continue
  jmp  @@draw_done
@@draw_continue:

  ; --- LSEEK: file_offset = pixels_offset + y * width * p_bytes ---
  mov  ax, [bp-16]
  mul  word ptr [current_header + HDR_WIDTH]
  xor  cx, cx
  mov  cl, [p_bytes]
  mul  cx
  add  ax, word ptr [current_content + CNT_PIX_OFF]
  adc  dx, word ptr [current_content + CNT_PIX_OFF + 2]

  mov  cx, dx              ; CX = старшая часть
  mov  dx, ax              ; DX = младшая часть
  mov  bx, [file_handle]
LSEEK
  jnc  @@lseek_ok
  jmp  @@draw_err
@@lseek_ok:
  ; --- Чтение строки в line_buffer ---
  mov  cx, [bp-24]         ; row_size
  lea  dx, line_buffer
  mov  bx, [file_handle]
READ_FILE
  jnc  @@read_ok
  jmp  @@draw_err
@@read_ok:
  cmp  ax, [bp-24]
  jge  @@draw_not_done         ; Если прочитали меньше, чем нужно — прерываем
  jmp  @@draw_done         
@@draw_not_done:
  ; --- Цикл по X ---
  mov  ax, [bp-8]
  mov  [bp-18], ax

@@col_loop:
  mov  ax, [bp-18]
  cmp  ax, [bp-12]
  jb   @@this_row
  jmp  @@next_row
@@this_row:

  ; --- idx = x * p_bytes ---
  mov  ax, [bp-18]
  xor  cx, cx
  mov  cl, [p_bytes]
  mul  cx
  lea  si, line_buffer
  add  si, ax              ; SI = idx

  ; --- Декодирование ---
  call decode_pixel        ; AL = цвет

  ; --- Отрисовка (zoom) ---
  mov  [bp-26], al         ; color
  mov  word ptr [bp-20], 0 ; dy = 0

@@zoom_y:
  mov  ax, [bp-20]
  cmp  ax, [bp-6]          ; dy < zoom
  jge  @@next_x

  mov  word ptr [bp-22], 0 ; dx = 0

@@zoom_x:
  mov  ax, [bp-22]
  cmp  ax, [bp-6]          ; dx < zoom
  jge  @@zoom_y_next

  ; --- screen_x = offset_x + x * zoom + dx ---
  mov  ax, [bp-18]
  mul  word ptr [bp-6]
  add  ax, [bp-2]
  add  ax, [bp-22]
  mov  si, ax              ; SI = screen_x
  ; --- screen_y = offset_y + y * zoom + dy ---
  mov  ax, [bp-16]
  mul  word ptr [bp-6]
  add  ax, [bp-4]
  add  ax, [bp-20]
  mov  di, ax              ; DI = screen_y

  mov  al, [bp-26]
PUT_PIXEL

@@zoom_x_next:
  inc  word ptr [bp-22]
  jmp  @@zoom_x

@@zoom_y_next:
  inc  word ptr [bp-20]
  jmp  @@zoom_y

@@next_x:
  inc  word ptr [bp-18]
  jmp  @@col_loop

@@next_row:
  inc  word ptr [bp-16]
  jmp  @@row_loop

@@draw_done:
  ; --- Ожидание клавиши ---
  xor  ax, ax
  int  16h                ; Ждём нажатия (AL=ASCII, AH=ScanCode)

  test al, al
  jnz  @@key_ascii
  ; Если ASCII == 0, значит это спец. клавиша (стрелки)
  mov  al, ah             ; AL = ScanCode

  cmp  al, 72             ; Up
  je   @@key_up
  cmp  al, 80             ; Down
  je   @@key_down
  cmp  al, 75             ; Left
  je   @@key_left
  cmp  al, 77             ; Right
  je   @@key_right
  jmp  @@main_loop

@@key_up:
  add  word ptr [bp-4], SHIFT_STEP
  jmp  @@main_loop
@@key_down:
  sub  word ptr [bp-4], SHIFT_STEP
  jmp  @@main_loop
@@key_left:
  add  word ptr [bp-2], SHIFT_STEP
  jmp  @@main_loop
@@key_right:
  sub  word ptr [bp-2], SHIFT_STEP
  jmp  @@main_loop

@@key_ascii:
  cmp  al, 27             ; ESC
  je   @@exit_view
  cmp  al, '+'
  je   @@key_zoom_in
  cmp  al, '='
  je   @@key_zoom_in
  cmp  al, '-'
  je   @@key_zoom_out
  cmp  al, '_'
  je   @@key_zoom_out
  jmp  @@main_loop

@@key_zoom_in:
  inc  word ptr [bp-6]
  jmp  @@main_loop
@@key_zoom_out:
  cmp  word ptr [bp-6], 1
  jg   @@not_main_loop
  jmp  @@main_loop
@@not_main_loop:
  dec  word ptr [bp-6]
  jmp  @@main_loop

@@draw_err:
  ; (Для простоты просто выходим, но можно вывести msg_err_read)
  jmp  @@exit_view

@@exit_view:
  ; --- Возврат в текстовый режим ---
  mov  ax, 0003h
  int  10h

  mov  sp, bp
  pop  bp
  ret  
 view_image endp



 ; ============================================================
 ; decode_pixel
 ; Вход:  DS:SI -> указатель на пиксель в line_buffer
 ; Выход: AL = цвет VGA
 ; ============================================================
 decode_pixel proc near
  push bp

  ; --- 1. Чтение p (1 или 2 байта, Little Endian) ---
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
  mov  al, byte ptr [bp]  ; Младший байт p
  and  al, dl
  mov  dh, al             ; DH = t

  ; --- 4. Вычисляем i1 = (p >> t_bits) & mask_i ---
  mov  al, byte ptr [bp]
  shr  al, cl             ; AL = p >> t_bits
  mov  dl, ch             ; Сохраняем i_bits в DL
  mov  cl, ch             ; CL = i_bits
  mov  bl, 1
  shl  bl, cl
  dec  bl                 ; BL = mask_i
  and  al, bl
  mov  bl, al             ; BL = i1
  mov  cl, dl             ; Восстанавливаем t_bits в CL

  ; --- 5. Вычисляем i2 = (p >> (t_bits + i_bits)) & mask_i ---
  mov  al, byte ptr [bp]
  add  cl, ch             ; CL = t_bits + i_bits
  shr  al, cl
  mov  cl, ch             ; CL = i_bits
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
  mov  al, byte ptr [current_palette + di + RGB_R]
  mov  byte ptr [temp_dx], al      ; r2
  mov  al, byte ptr [current_palette + di + RGB_G]
  mov  byte ptr [temp_ax + 1], al  ; g2
  mov  al, byte ptr [current_palette + di + RGB_B]
  mov  byte ptr [temp_bx + 1], al  ; b2

  ; --- 8. t_scaled = (t * 255) / ((1 << t_bits) - 1) ---
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

  pop  bp
  ret  
 decode_pixel endp


_TEXT ENDS
 ; ============================================================
 ; КОНЕЦ ФАЙЛА
 ; ============================================================
 END main