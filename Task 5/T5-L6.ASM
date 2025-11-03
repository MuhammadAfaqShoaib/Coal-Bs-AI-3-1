dosseg
.model small
.stack 100h
.data
 msg1 db 'Number=', '$'
 msg2 db 0dh,0ah, 'Even=', '$'
 msg3 db 0dh,0ah, 'Odd=', '$'

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Print "Number="
    mov ah, 9
    mov dx, OFFSET msg1
    int 21h

    ; Print 0–9
    mov cx, 10
    mov dl, '0'
N1:
    mov ah, 2
    int 21h
    inc dl
    dec cx
    jnz N1

    ; Print "Even="
    mov ah, 9
    mov dx, OFFSET msg2
    int 21h

    ; Print even numbers 0,2,4,6,8
    mov cx, 5
    mov dl, '0'
N2:
    mov ah, 2
    int 21h
    add dl, 2
    dec cx
    jnz N2

    ; Print "Odd="
    mov ah, 9
    mov dx, OFFSET msg3
    int 21h

    ; Print odd numbers 1,3,5,7,9
    mov cx, 5
    mov dl, '1'
N3:
    mov ah, 2
    int 21h
    add dl, 2
    dec cx
    jnz N3

    ; Exit program
    mov ah, 4ch
    int 21h

main endp
end main