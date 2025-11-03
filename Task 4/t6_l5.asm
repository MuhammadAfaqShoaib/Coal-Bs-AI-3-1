include 'emu8086.inc'
.model
.stack 100h
.data
.code
main proc
    mov ax,4h
    mov bx,7h
    cmp ax,bx
    jg move
    mov ax,3
    mov ah,04h
    int 21h
    move:
    mov bx,4
    mov ah,04h
    int 21h
    main endp
end main