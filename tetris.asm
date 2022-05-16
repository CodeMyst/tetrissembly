; #fasm# ; this code is for the flat assembler, to compile in emu8086, this line should be uncommented

; COM programs should start at CS:0100h
org  100h

; enter graphics mode 13h, 320x200, 256 (1byte) colors per pixel
mov ax, 13h
int 10h

; test drawing a pixel to the center of the screen
mov dl, 150 ; color
mov di, 32160 ; center of screen, 160x100, 320*100+160
call draw_pixel

; infinite loop for now
main_loop:
    jmp main_loop

; return back to text mode
mov ax, 3h
int 10h

; return the control back to the OS
ret

; --------------------------------------------------
; PROCEDURES
; --------------------------------------------------

; ----------
; draw a pixel to the screen
;
; dl - color
; di - position
; ----------
draw_pixel:
    push ax
    push es

    mov ax, 0A000h
    mov es, ax
    ; set 0A000+di to specified color
    mov byte [es:di], dl

    pop es
    pop ax

    ret
