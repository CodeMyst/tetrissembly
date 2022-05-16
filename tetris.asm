; #fasm# ; this code is for the flat assembler, to compile in emu8086, this line should be uncommented

; COM programs should start at CS:0100h
org  100h

; enter graphics mode 13h, 320x200x8
mov ax, 13h
int 10h

; test drawing a pixel
mov di, 10
mov dl, 15
mov ax, 0A000h
mov es, ax
mov byte [es:di], dl

; return back to text mode
mov ax, 3h
int 10h

; return the control back to the OS
ret
