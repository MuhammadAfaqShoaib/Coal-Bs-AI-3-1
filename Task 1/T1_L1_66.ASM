dosseg                  ;Arrange segments in DOS order
.model small            ;use small memory model
.stack 100h             ;Reserve 256 bytes for the stack
.data                   ;Data segment
.code                   ; Code segment
main proc               ;Define msin procedure
mov dl,'A'              ;Load ASCII character into DL register
mov ah,2                ;for output of the function
int 21h                 ;for interrupt
mov dl,'f'
mov ah,2
int 21h
mov dl,'a'
mov ah,2
int 21h
mov dl,'q'
mov ah,2
int 21h
mov ah,4ch              ;terminate program
int 21h
main endp               ;End ofprocedure
end main                ;Mark 'main' as program entry point

