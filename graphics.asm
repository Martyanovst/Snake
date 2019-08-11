init_game_graphics proc
    mov ah, 0Fh      ;|
    int 10h          ;| Get old configuration
    mov old_mode, al ;|
    mov old_page, bh ;|

    xor ah, ah      ;|
    mov al, 03h     ;|  Set graphics mode
    int 10h         ;|

    mov ah, 05h          ;|
    mov al, current_page ;|  Set graphics page
    int 10h              ;|

    cmp top_wall_type, 1
    jne _dead_
    mov al, bounce_wall_attribute
    mov ah, bounce_wall_symbol
    mov top_wall_attribute, al
    mov top_wall_symbol, ah
    ret
_dead_:
    mov al, dead_wall_attribute
    mov ah, dead_wall_symbol
    mov top_wall_attribute, al
    mov top_wall_symbol, ah
    ret
endp

show_dialog proc
    mov cursor_x, 30
    mov cursor_y, 12
    call draw_scores
    call draw_dialog
    ret
endp

draw_str proc
    draw_str_loop:
    call set_cursor
    mov al, [si]
    mov bl, bounce_wall_attribute
    call draw
    inc si
    inc cursor_x
    dec cx
    jnz draw_str_loop
    ret
endp

draw_dialog proc
    mov cursor_x, 30
    inc cursor_y
    mov cx, dialog_len
    mov si, offset dialog
    call draw_str
    ret
endp
dialog db 'Press Space to Restart'
dialog_len equ $ - dialog
flush proc
    mov cursor_x, 0
flush_loop1:
    mov cursor_y, 0
flush_loop2:
    call set_cursor
    call hide
    inc cursor_y
    mov bx, height
    dec bx
    cmp cursor_y, bl
    jne flush_loop2

    inc cursor_x
    mov bx, _width
    dec bx
    cmp cursor_x, bl
    jne flush_loop1
    ret
endp

draw_scores_bottom proc
    mov cursor_x, 1
    mov cursor_y, byte ptr height
    dec cursor_y
    call draw_scores
    ret
endp
draw_scores proc
    mov cx, scores_msg_len
    mov si, offset scores_msg
    call draw_str
    ret
endp
scores_msg db 'SCORE:'
scores_place db 0,0,0, ' '
length_msg db 'LENGTH:'
length_place db 0, 0, 0
max_score db 'Max.Score:'
max_place db 0,0,0
scores_msg_len equ $ - scores_msg

draw_snake proc 
    push dx
    push cx
    xor cx, cx
    mov cl, snake_length
    mov cursor_x, byte ptr snake
    mov cursor_y, byte ptr snake+1 
draw_loop:
    call set_cursor 
    call draw_snake_segment
    dec cursor_x
    dec cl
    jnz draw_loop
    pop cx
    pop dx
    ret
endp

draw_snake_segment proc
    push ax
    push bx
    mov al, snake_symbol
    mov bl, snake_attribute
    call draw
    pop bx
    pop ax
    ret
endp

draw_snake_head_segment proc
    mov al, snake_head_symbol
    mov bl, snake_head_attribute
    call draw
    ret
endp

draw_snake_tail_segment proc
    mov al, snake_tail_symbol
    mov bl, snake_tail_attribute
    call draw
    ret
endp

draw_apple proc
    mov bl, apple_attribute
    mov al, apple_symbol
    call draw
    ret
endp

draw_scissors proc
    mov bl, scissors_attribute
    mov al, scissors_symbol
    call draw
    ret
endp

draw_bomb proc
    mov bl, bomb_attribute
    mov al, bomb_symbol
    call draw
    ret
endp

draw_dead_wall proc
    mov bl, dead_wall_attribute
    mov al, dead_wall_symbol
    call draw
    ret
endp

draw_bounce_wall proc
    mov bl, bounce_wall_attribute
    mov al, bounce_wall_symbol
    call draw
    ret
endp

draw_portal_wall proc
    mov bl, portal_wall_attribute
    mov al, portal_wall_symbol
    call draw
    ret
endp

draw_top_wall proc
    mov bl, top_wall_attribute
    mov al, top_wall_symbol
    call draw
    ret
endp

draw_collision_object proc
    mov bl, collision_object_attribute
    mov al, collision_object_symbol
    call draw
    ret
endp

; dh = row
; dl = column
set_cursor proc
    mov bh, current_page
    mov ah, 02h
    int 10h
    ret
endp

get_object proc
    push dx 
    push ax
    push bx 
    mov bh, current_page
    mov ah, 08h
    int 10h
    mov collision_object_symbol, al
    mov collision_object_attribute, ah
    pop bx
    pop ax
    pop dx
    ret
endp

;if find,then dx = coordinates + ax = 0
;else ax = 1, dx = old coordinates
check_snake proc
    mov cl, snake_length
    dec cl
    mov di, dx
    mov ax, [di] ; ax = tail coordinate
    mov si, offset snake
check_tail_loop:
    cmp ax, [si]
    je find
    add si, 2
    dec cl
    jnz check_tail_loop
    mov ax, 1
    ret
find: 
    xor ax, ax
    mov dx, [si]
    ret
endp

; al = symbol
; bl = attribute
draw proc
    push ax
    push bx
    push cx
    mov ah, 09h
    mov bh, current_page
    mov cx, 1
    int 10h
    pop cx
    pop bx
    pop ax
    ret
endp

hide proc
    mov al, 0
    mov bl, 0
    call draw
    ret
endp

dispose proc
    xor ah, ah      ;|
    mov al, old_mode;|  Set graphics mode
    int 10h         ;|

    mov ah, 05h          ;|
    mov al, old_page     ;|  Set graphics page
    int 10h              ;|

    ret
endp

snake_attribute db 01100010b
snake_head_attribute db 01100010b
snake_head_symbol = 2
snake_tail_attribute db 01100010b
snake_tail_symbol = '@'
snake_symbol = '@'

apple_attribute db 10001010b
apple_symbol = 3

scissors_attribute db 00000100b
scissors_symbol = 11

collision_object_symbol db 0
collision_object_attribute db 0

bomb_attribute db 00001110b
bomb_symbol = 2

dead_wall_attribute db 00000101b
dead_wall_symbol = 23

bounce_wall_attribute db 00001100b
bounce_wall_symbol = 21

portal_wall_attribute db 00001001b
portal_wall_symbol = 10


top_wall_attribute db 00001100b
top_wall_symbol db 21

old_mode db 0
old_page db 0
current_page db 0

cursor_x equ dl
cursor_y equ dh

