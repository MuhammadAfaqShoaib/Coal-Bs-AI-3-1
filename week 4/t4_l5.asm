include 'emu8086.inc'
.model
.stack 100h
.data
.code
main proc
    mov dl,3
    mov bl,10
    cmp dl,bl
    je move
    print 'Both are not equal'
    mov ah,04h
    int 21h
    move:
    print ' Both are equal'
    mov ah,04h
    int 21h
    main endp
end main