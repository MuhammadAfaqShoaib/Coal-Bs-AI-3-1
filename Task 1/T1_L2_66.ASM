[org 0x100]             ;set origin at 0x100          
mov ax,6                ;load 6 into AX register
mov bx,4                ;load 4 into BX register
add ax,bx               ;AX = AX + BX now holds 10
mov bx,3                ;load 3 into bx register
mov ax,0x4c00           ;terminate program 
int 0x21                ;interrupt to exit program 
