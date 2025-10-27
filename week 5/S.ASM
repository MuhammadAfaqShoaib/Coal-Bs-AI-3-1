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
    loop N1

    ; Print "Even="
    mov ah, 9
    mov dx, OFFSET msg2
    int 21h

    ; Loop through numbers 0–9 and check even/odd
    mov cx, 10        ; 10 numbers
    mov bl, '0'       ; start with ASCII '0'

CheckEven:
    mov al, bl        ; copy number
    sub al, '0'       ; convert ASCII → number (0–9)

    ; Check if even: num mod 2 == 0
    mov ah, 0
    mov dl, 2
    div dl            ; AL / 2 → AL=quotient, AH=remainder
    cmp ah, 0
    jne NotEven       ; if remainder ≠ 0 → odd

    ; If even, print number
    mov dl, bl
    mov ah, 2
    int 21h

NotEven:
    inc bl
    loop CheckEven

    ; Print "Odd="
    mov ah, 9
    mov dx, OFFSET msg3
    int 21h

    ; Loop through numbers 0–9 and check odd
    mov cx, 10
    mov bl, '0'

CheckOdd:
    mov al, bl
    sub al, '0'       ; ASCII → num
    mov ah, 0
    mov dl, 2
    div dl            ; AL / 2
    cmp ah, 0
    je NotOdd         ; if remainder = 0 → even

    ; If odd, print number
    mov dl, bl
    mov ah, 2
    int 21h

NotOdd:
    inc bl
    loop CheckOdd

    ; Exit
    mov ah, 4ch
    int 21h

main endp
end main
