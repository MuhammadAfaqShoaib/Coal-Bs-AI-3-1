dosseg               ;Arrange segments
.model small         ;small memory
.stack 100h          ;reserve 256 bytes
.data                ;data segment
.code                ;code segment
main proc            ;main procedure
mov dl,'A'           ;Load 'a' in DL register
mov ah,2             ;display character
int 21h              ;interrupt function
mov ah,4ch           ;terminate program
int 21h
main endp            ;end of procedure
end main             ;mark 'main' as program entery points
