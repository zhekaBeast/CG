.model small
.stack 100h

_DATA SEGMENT

body LABEL BYTE
    dw 0
    dw 10
    dw 20

_DATA ENDS


_TEXT SEGMENT

ASSUME CS:_TEXT, DS:_DATA

main PROC
    mov ax, _DATA
    mov ds, ax

    mov bx, OFFSET body
    mov ax, [bx]

    mov ax, 4C00h
    int 21h
main ENDP

_TEXT ENDS

END main