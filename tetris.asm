; #fasm# ; this code is for the flat assembler, to compile in emu8086, this line should be uncommented

; --------------------------------------------------
; Formula for calculating the memory position based on X and Y coords:
;
; y * screen_width + x
; --------------------------------------------------

; COM programs should start at CS:0100h
org  100h

jmp init_graphics ; skip the variables

; --------------------------------------------------
; VARIABLES
; --------------------------------------------------

screen_width dw 320
screen_height dw 200

board_color db 150
board_width dw 100
board_height dw 160
; center of the screen is 160px
; minus half the length of the board_width is 110px
; 110x20
board_top_left dw 6510
; 110+board_width x 20 = 210x20
board_top_right dw 6610
; 110x(200-20)=110x180
board_bottom_left dw 57710

; --------------------------------------------------
; CODE
; --------------------------------------------------

; enter graphics mode 13h, 320x200, 256 (1byte) colors per pixel
init_graphics:
    mov ax, 13h
    int 10h

; draw the tetris board
call draw_board

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
; draw the tetris board
; ----------
draw_board:
    mov dl, [board_color]

    ; top line

    mov di, [board_top_left]
    mov cx, [board_width]
    call draw_line_x

    ; bottom line

    mov di, [board_bottom_left]
    mov cx, [board_width] ; have to set again because cx gets reset (looping)
    inc cx ; + 1px, so it aligns with the edge of the right line
    call draw_line_x

    ; left line

    mov di, [board_top_left]
    mov cx, [board_height] ; have to set again because cx gets reset (looping)
    call draw_line_y

    ; right line

    mov di, [board_top_right]
    mov cx, [board_height] ; have to set again because cx gets reset (looping)
    call draw_line_y

    ret

; ----------
; draw a horizontal line to the screen
;
; dl - color
; di - position
; cx - size
; ----------
draw_line_x:
    call draw_pixel

    ; move position one pixel right
    inc di

    ; loops until cx is 0
    loop draw_line_x

    ret

; ----------
; draw a vertical line to the screen
;
; dl - color
; di - position
; cx - size
; ----------
draw_line_y:
    call draw_pixel

    ; move position one pixel down
    add di, [screen_width]

    ; loops until cx is 0
    loop draw_line_y

    ret

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
