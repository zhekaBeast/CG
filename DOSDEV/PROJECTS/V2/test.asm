; line.asm — рисует диагональную линию через экран
; Сборка: nasm -f bin line.asm -o line.com
; Запуск: line.com

BITS 16
ORG 100h

start:
    ; Установить видеорежим 13h (320x200, 256 цветов)
    mov ax, 0013h
    int 10h

    ; Указатель на видеопамять 0xA000:0000
    mov ax, 0A000h
    mov es, ax

    ; Рисуем диагональ от (0,0) до (319,199)
    ; Используем алгоритм Брезенхэма
    xor si, si          ; X = 0
    xor di, di          ; Y = 0
    mov cx, 320         ; счётчик пикселей

draw_loop:
    ; Вычислить смещение = Y*320 + X
    mov ax, di
    mov bx, 320
    mul bx
    add ax, si
    mov bx, ax

    ; Записать цвет (15 = белый) в видеопамять
    mov byte [es:bx], 15

    ; Шаг Брезенхэма для линии (0,0)-(319,199)
    ; dx = 319, dy = 199, err = dx/2
    ; Простая аппроксимация: каждые ~1.6 шага по X делаем шаг по Y
    inc si

    ; Y увеличиваем, когда X*199/319 >= Y+1
    ; Проще: инкремент Y, если (si * 199) / 319 > di
    push ax
    push dx
    mov ax, si
    mov bx, 199
    mul bx              ; ax = si*199
    mov bx, 319
    div bx              ; ax = (si*199)/319
    cmp ax, di
    jbe .no_y
    inc di
.no_y:
    pop dx
    pop ax

    loop draw_loop

    ; Ожидание нажатия клавиши
    xor ah, ah
    int 16h

    ; Возврат в текстовый режим 03h
    mov ax, 0003h
    int 10h

    ; Выход в DOS
    mov ax, 4C00h
    int 21h