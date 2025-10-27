org 0x100
mov ax,3 
cmp ax,6 
js add 
jns exit 
add: 
mov ax,2 
exit: 
mov ax,0x4c00 
int 0x21