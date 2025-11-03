dosseg
.model small
.stack 100h
.data
.code
main proc
mov cx,26
mov dx,65
l1:
mov ah,2
int 21h
add dx,1
loop l1
mov dx,10
mov ah,2
int 21h
mov cx,26
mov dx,97
l2:
mov ah,2
int 21h
add dx,1
loop l2
mov dx,10
mov ah,2
int 21h
mov cx,10
mov dx,48
l3:
mov ah,2
int 21h
add dx,1
loop l3
mov ah,4ch
int 21h
main endp
end main
