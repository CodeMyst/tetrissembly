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

should_quit db 0 ; whether the game should stop

; should the element move left/right?
should_move_left db 0
should_move_right db 0

element_color db 4
element_color_final db 8

board_color db 150
board_width dw 100
board_height dw 160
; center of the screen is 160px
; minus half the length of the board_width is 110px
; 110x20
board_top_left dw 6509
; 110+board_width x 20 = 210x20
board_top_right dw 6610
; 110x(200-20)=110x180
board_bottom_left dw 57710

rect_start_pos_x dw 150
rect_start_pos_y dw 21

rect_pos_x dw 150
rect_pos_y dw 21
rect_pos dw 0

; --------------------------------------------------
; CODE
; --------------------------------------------------

; enter graphics mode 13h, 320x200, 256 (1byte) colors per pixel
init_graphics:
    mov ax, 13h
    int 10h

; draw the tetris board
call draw_board

; main game loop
main_loop:
    call handle_input

    ; check if should quit
    cmp [should_quit], 1
    je game_exit

    ; check if can move down
    ; if can't, dont move it anymore, spawn new one
    call can_move_down
    cmp al, 1
    je skip_spawn_new

    ; draw rect with final color
    mov dl, [element_color_final]
    call calc_pos
    mov di, [rect_pos]
    call draw_rect

    ; set position to starting position
    mov ax, [rect_start_pos_x]
    mov [rect_pos_x], ax
    mov ax, [rect_start_pos_y]
    mov [rect_pos_y], ax
    jmp draw_element

skip_spawn_new:

    ; clear the rect at the current position (draw rect with black color)
    mov dl, 0
    call calc_pos
    mov di, [rect_pos]
    call draw_rect

    ; move one row down
    mov di, [rect_pos_y]
    inc di
    mov [rect_pos_y], di

    ; check if the rect should move left
    cmp [should_move_left], 1
    jne check_move_right ; if not, skip to check if it should move right

    ; move left
    mov [should_move_left], 0
    cmp [rect_pos_x], 110 ; check if at left board edge
    je check_move_right ; if it is, skip moving left
    mov di, [rect_pos_x]
    sub di, 10
    mov [rect_pos_x], di

check_move_right:
    ; check if the rect should move right
    cmp [should_move_right], 1
    jne draw_element ; if not, skip

    ; move right
    mov [should_move_right], 0
    cmp [rect_pos_x], 200 ; check if at right board edge
    je draw_element ; if it is, skip moving right
    mov di, [rect_pos_x]
    add di, 10
    mov [rect_pos_x], di
    jmp draw_element

draw_element:
    ; draw rect
    mov dl, [element_color]
    call calc_pos
    mov di, [rect_pos]
    call draw_rect

    ; delay game loop
    call delay

    jmp main_loop

game_exit:
    ; return back to text mode
    mov ax, 3h
    int 10h

    ; return the control back to the OS
    ret

; --------------------------------------------------
; PROCEDURES
; --------------------------------------------------

; ----------
; checks if the current element can move down
;
; al is set to 1 if the element can move down
; ----------
can_move_down:
    push bx
    push di
    push dx

    cmp [rect_pos_y], 170 ; check if bottom of board reached
    jae can_move_down_false

    ; check if pixels directly below the element are blocked

    ; calculate position below current block
    ; y * width + x
    mov ax, [screen_width]
    mov bx, [rect_pos_y]
    add bx, 10 ; move down by one block
    mul bx
    add ax, [rect_pos_x]
    mov di, ax

    call read_pixel
    cmp dl, [element_color_final] ; check if pixel has the blocked color
    je can_move_down_false

    mov al, 1 ; true
    jmp can_move_down_end

can_move_down_false:
    mov al, 0 ; false

can_move_down_end:
    pop bx
    pop dx
    pop di

    ret

; ----------
; calculates the memory-based position of the current element
; ----------
calc_pos:
    push ax
    push bx
    push dx

    ; y * width + x
    mov ax, [screen_width]
    mov bx, [rect_pos_y]
    mul bx

    add ax, [rect_pos_x]

    mov [rect_pos], ax

    pop dx
    pop bx
    pop ax

    ret

; ----------
; handles any keyboard input
; ----------
handle_input:
    push ax
    push dx

    ; check if any key is pressed
    mov ah, 1
    int 16h
    jnz key_pressed

    jmp handle_input_end ; if no key pressed, exit procedure

key_pressed:
    mov ah, 0
    int 16h

    ; clear keyboard buffer
    push ax
    mov ah, 6
    mov dl, 0FFh
    int 21h
    pop ax

handle_pressed_key:
    ; is q pressed? quit
    cmp al, 'q'
    je handle_quit

    ; is a pressed? move left
    cmp al, 'a'
    je handle_left

    ; is d pressed? move right
    cmp al, 'd'
    je handle_right

    ; unknown key
    jmp handle_input_end

handle_quit:
    mov [should_quit], 1
    jmp handle_input_end

handle_left:
    mov [should_move_left], 1
    jmp handle_input_end

handle_right:
    mov [should_move_right], 1
    jmp handle_input_end

handle_input_end:
    pop dx
    pop ax

    ret

; ----------
; delay procedure, calls nop a lot of times
; ----------
delay:
    push cx

    mov cx, 20000
delay_loop:
    nop
    loop delay_loop

    pop cx

    ret

; ----------
; draw the tetris board
; ----------
draw_board:
    mov dl, [board_color]

    ; top line

    mov di, [board_top_left]
    mov cx, [board_width]
    inc cx ; + 1px, so it aligns with the edge of the right line
    call draw_line_x

    ; bottom line

    mov di, [board_bottom_left]
    mov cx, [board_width] ; have to set again because cx gets reset (looping)
    inc cx ; + 1px, so it aligns with the edge of the right line
    call draw_line_x

    ; left line

    mov di, [board_top_left]
    mov cx, [board_height] ; have to set again because cx gets reset (looping)
    inc cx
    call draw_line_y

    ; right line

    mov di, [board_top_right]
    mov cx, [board_height] ; have to set again because cx gets reset (looping)
    call draw_line_y

    ret

; ----------
; draw a rectangle
;
; dl - color
; di - position
; ----------
draw_rect:
    push di
    push cx

    ; loop counter for for rect height
    mov cx, 10

draw_rect_loop:
    ; save current loop counter,
    ; because it will be used for drawing horizontal lines
    push cx

    ; save position
    push di

    ; draw horizontal line, width is 10
    mov cx, 10
    call draw_line_x

    ; return position, and move it down one line
    pop di
    add di, [screen_width]

    ; return back loop counter
    pop cx

    loop draw_rect_loop

    pop cx
    pop di

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

; ----------
; reads a pixel from the screen
;
; dl - color (output)
; di - position
; ----------
read_pixel:
    push ax
    push es

    mov ax, 0A000h
    mov es, ax
    ; read 0A000+di
    mov byte dl, [es:di]

    pop es
    pop ax

    ret
