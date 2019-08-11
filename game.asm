run proc
main_loop:
    ; mov _current_sound, move_sound
    call generate_content
    call render
    call get_action
    cmp gameIsOver, 1
    je _finish_
    cmp is_pause, 0
    jnz main_loop
    call move
    call collision_analize
    mov ax, _current_sound
    call Sound
    call delay
    call No_Sound
    cmp gameIsOver, 1
    jne main_loop
_finish_:
    call game_over
    ret
endp

init_game_settings proc
    mov snake, 0C0Ch
    mov snake_length, 10
    mov is_need_to_create_apple, 1
    mov is_need_to_create_bomb, 1
    mov is_need_to_create_scissors, 1
    mov gameIsOver, 0
    mov snake_direction, right
    mov scores, 0
    ret
endp

collision_analize proc
    mov cursor_x, byte ptr snake
    mov cursor_y, byte ptr snake+1
    call set_cursor
    call get_object
apple:
    cmp collision_object_symbol, apple_symbol
    jne _snake_
    call eat_apple
    jmp @@end@@
_snake_:
    cmp collision_object_symbol, snake_symbol
    jne _scissors_
    call snake_cross
    jmp @@end@@
_scissors_:
    cmp collision_object_symbol, scissors_symbol
    jne _bomb_
    call eat_scissors
    jmp @@end@@
_bomb_:
    cmp collision_object_symbol, bomb_symbol
    jne _dead_wall_
    call eat_bomb
    jmp @@end@@
_dead_wall_:
    cmp collision_object_symbol, dead_wall_symbol
    jne _bounce_wall_
    mov gameIsOver, 1
    jmp @@end@@
_bounce_wall_:
    cmp collision_object_symbol, bounce_wall_symbol
    jne _portal_wall_
    call bounce
    jmp @@end@@
_portal_wall_:
    cmp collision_object_symbol, portal_wall_symbol
    jne @@end@@
    call portal_wall_action
    jmp @@end@@
@@end@@:
    mov cursor_x, 80
    mov cursor_y, 25
    call set_cursor
    ret
endp

portal_wall_action proc
    mov _current_sound, portal_sound
    mov ax, snake
    cmp al, 0
    je jmp_to_right
    mov al, 1
    mov snake, ax
    mov snake_direction, right
    ret
jmp_to_right:
    mov al, byte ptr _width
    dec al 
    dec al
    dec al
    mov snake, ax
    mov snake_direction, left
    ret
endp

snake_cross proc
    cmp cross_mode, 1
    jne cutting
    mov gameIsOver, 1
    ret
cutting:
    cmp cross_mode, 2
    jne go_through
    call snake_cut
    ret
go_through:
    ret
endp

snake_cut proc
    mov si, offset snake
    xor cx, cx
snake_cut_loop:
    inc cl
    add si, 2
    mov dx, [si]
    cmp dx, snake
    jne snake_cut_loop
    push cx
snake_tail_hide_loop:
    inc cl
    add si, 2
    mov cursor_x, [si]
    mov cursor_y, [si+1]
    call set_cursor
    call hide
    cmp cl, snake_length
    jng snake_tail_hide_loop
    pop cx
    mov snake_length, cl
    dec snake_length
    ret
endp

bounce proc
    mov si, offset snake
    xor cx, cx
    mov cl, snake_length
    ; dec cl
    shl cx, 1
    mov di, offset snake
    add di, cx
    shr cx, 2
swap:
    mov ax, [si]
    push ax
    mov ax, [di]
    mov [si], ax
    pop ax
    mov [di], ax
    add si, 2
    sub di, 2
    dec cx
    jnz swap
    cmp snake_direction, right
    jne left_
    mov snake_direction, left
    jmp exit_
left_:
    cmp snake_direction, left
    jne up
    mov snake_direction, right
    jmp exit_
up:
    cmp snake_direction, top
    jne down_
    mov snake_direction, down
    jmp exit_
down_:
    cmp snake_direction, down
    jne exit_
    mov snake_direction, top
    jmp exit_
exit_:
    mov _current_sound, bounce_sound
    call move
    ret
endp

eat_apple proc
    inc snake_length
    mov is_need_to_create_apple, 1
    inc scores
    mov dx, max_scores
    cmp dx, scores
    jg next1
    inc dx
    mov max_scores, dx
next1:
    xor dx, dx
    mov ax, scores
    mov bl, scissors_factor
    div bl
    test ah, ah
    jz no_create_scissors
    mov is_need_to_create_scissors, 1
no_create_scissors:
    xor dx, dx
    mov ax, scores
    mov bl, bomb_factor
    div bl
    test ah, ah
    jz no_create_bomb
    mov is_need_to_create_bomb, 1
no_create_bomb:
    mov _current_sound, apple_sound
    ret
endp

eat_scissors proc
    cmp snake_length, 2
    jle cut_finish
    call hide_tail
    dec snake_length
    mov _current_sound, scissors_sound
cut_finish:    
    ret
endp

eat_bomb proc
    mov gameIsOver, 1
    mov _current_sound, bomb_sound
    ret
endp

game_over proc
    call play_melody
    call flush
    call show_dialog
    xor ax, ax
    int 16h
    cmp ah, 57
    jne @@@end
    jmp start
@@@end:
    call flush
    mov ax, 004ch
    int 21h
    ret
endp

play_melody proc
    mov si, offset game_over_melody
    mov cl, game_over_melody_length
    shr cx, 1
melody_loop:
    mov ax, [si]
    call Sound
    call delay
    add si, 2
    dec cl
    jnz melody_loop
    call No_Sound
    ret
endp

get_action proc
    mov ah, 1h
    int 16h
    jz @@finish
    cmp ah, 77
    jne _not_right
    cmp snake_direction, left
    je @@end
    mov snake_direction, right
    jmp @@end
_not_right: 
    cmp ah, 75
    jne _not_left
    cmp snake_direction, right
    je @@end
    mov snake_direction, left
    jmp @@end 
_not_left: 
    cmp ah, 72
    jne _not_top
    cmp snake_direction, down
    je @@end
    mov snake_direction, top
    jmp @@end 
_not_top: 
    cmp ah, 80
    jne _not_bottom
    cmp snake_direction, top
    je @@end
    mov snake_direction, down
    jmp @@end 
_not_bottom:
    cmp al, 27
    jne not_exit
    mov gameIsOver, 1
not_exit:
    cmp al, '='
    jne not_speed_down
    mov ax, speed
    sub ax, 25
    test ax, ax
    jz @@end
    mov speed, ax
    jmp @@end
not_speed_down:
    cmp al, '-'
    jne _pause
    mov ax, speed
    add ax, 25
    cmp ax, max_speed
    je @@end
    mov speed, ax
    jmp @@end
_pause:
    cmp al, ' '
    jne @@end
    cmp is_pause, 0
    jnz _resume
    mov is_pause, 1
    jmp @@end
_resume:
    mov is_pause, 0
    jmp @@end
@@end:
    xor ax, ax
    int 16h
@@finish:
    ret
endp

delay proc
    push cx
    xor dx, dx
    mov ax, speed_factor
    mov bx, speed
    mul bx
    mov cx, ax
delay_loop:
    mov al, 0
    mov ah, 0
    push ax
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    pop ax
    dec cx
    jnz delay_loop
    pop cx
    ret
endp

delay_sound proc
    xor dx, dx
    mov ax, speed_factor
    mov bx, speed
    shr bx, 2
    mul bx
    mov cx, ax
delay__sound_loop:
    mov al, 0
    mov ah, 0
    push ax
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    pop ax
    dec cx
    jnz delay_loop
    ret
endp
init_snake proc
    mov ax, snake
    mov di, offset snake
    mov cl, snake_length
snake_init_loop:
    add di, 2
    dec al
    mov [di], ax
    dec cl    
    jnz snake_init_loop
    ret
endp

render proc
    call hide_tail
    mov si, offset snake
    mov cl, snake_length
    ; inc cl
    dec cl
draw_head:
    mov cursor_x, [si]
    mov cursor_y, [si+1]
    call set_cursor
    call draw_snake_head_segment
    add si, 2
    dec cl
draw_snake_loop:
    mov cursor_x, [si]
    mov cursor_y, [si+1]
    call set_cursor
    call draw_snake_segment
    add si, 2
    dec cl
    jnz draw_snake_loop
draw_tail:
    mov cursor_x, [si]
    mov cursor_y, [si+1]
    call set_cursor
    call draw_snake_tail_segment
    add si, 2
    dec cl
__scores__:
    mov ax, scores
    mov di, offset scores_place
    call ToString

    mov ax, max_scores
    mov di, offset max_place
    call ToString

    xor ax, ax
    mov al, snake_length
    mov di, offset length_place
    call ToString
    call draw_scores_bottom
    ret
endp


hide_tail proc
    xor cx, cx
    mov cl, snake_length
    shl cl, 1
    mov di, offset snake
    add di, cx
    mov cursor_x, [di]
    mov cursor_y, [di+1]
    call set_cursor
    call check_snake
    test ax, ax
    jnz hide_
    ret
hide_:
    call hide
    ret
endp

move proc 
    call update_snake_array
    call try_move_snake
    mov snake, ax
    ret
endp

;ax= new coordinates
try_move_snake proc
    mov ax, snake
    cmp snake_direction, right
    jne not_right
    inc al
    ret
not_right:
    cmp snake_direction, left
    jne not_left
    dec al
    ret
not_left:
    cmp snake_direction, top
    jne not_top
    dec ah
    ret
not_top:
    inc ah
    ret
endp

update_snake_array proc
    mov di, offset snake
    xor cx, cx
    mov cl, snake_length
    shl cl, 1
    add di, cx
    shr cl, 1
update_snake_loop:
    mov ax, [di-2]
    mov [di], ax
    sub di, 2
    dec cl
    jnz update_snake_loop
    ret
endp

init_walls proc
    call init_dead_wall
    call init_portal_walls
    call init_top_wall
    ret
endp

init_dead_wall proc
    mov cursor_x, 0
    mov cursor_y, byte ptr height
    dec cursor_y
    dec cursor_y
    mov cx, _width
    dec cx
dead_wall_loop:
    call set_cursor
    call draw_dead_wall
    inc cursor_x
    dec cx
    jnz dead_wall_loop
    ret
endp

init_portal_walls proc
    mov cursor_x, 0
    mov cursor_y, 0
    mov cx, height
init_first_portal_wall_loop:
    call set_cursor
    call draw_portal_wall
    inc cursor_y
    dec cx
    jnz init_first_portal_wall_loop
    mov cursor_x,  byte ptr _width
    mov cursor_y, 0
    dec cursor_x
    dec cursor_x
    mov cx, height
init_second_portal_wall_loop:
    call set_cursor
    call draw_portal_wall
    inc cursor_y
    dec cx
    jnz init_second_portal_wall_loop
    ret
endp

init_top_wall proc
    mov cursor_x, 0
    mov cursor_y, 0
    mov cx, _width
    dec cx
bounce_wall_loop:
    call set_cursor
    call draw_top_wall
    inc cursor_x
    dec cx
    jnz bounce_wall_loop
    ret
endp

Sound      proc
            push cx
           push     ax        ;сохранить регистры
           push     bx
           push     dx
           mov      bx,ax     ;частота
           mov      ax,34DDh
           mov      dx,12h    ;(dx,ax)=1193181
           cmp      dx,bx     ;если bx < 18Гц, то выход
           jnb      Done      ;чтобы избежать переполнения
           div      bx        ;ax=(dx,ax)/bx
           mov      bx,ax     ;счетчик таймера
           in       al,61h    ;порт РВ
           or       al,3      ;установить биты 0-1
           out      61h,al
           mov      al,00001011b   ;управляющее слово таймера:
                                   ;канал 2, режим 3, двоичное слово
           mov      dx,43h
           out      dx,al     ;вывод в регистр режима
           dec      dx
           mov      al,bl
           out      dx,al     ;младший байт счетчика
           mov      al,bh
           out      dx,al     ;старший байт счетчика
Done:
           pop      dx        ;восстановить регистры
           pop      bx
           pop      ax
           pop cx
           ret
Sound      endp
           ;
           ;подпрограмма выключения звука
           ;
No_Sound   proc
           push     ax
           in       al,61h    ;порт РВ
           and      al,not 3  ;сброс битов 0-1
           out      61h,al
            mov _current_sound, 0
           pop      ax
           ret
No_Sound   endp


_current_sound dw 0
apple_sound = 180
scissors_sound = 200
portal_sound = 400
bounce_sound = 50
bomb_sound = 100
move_sound = 20

;           (X,Y)
;initial = (10,10)
;100 = undefined
snake dw 0C0Ch, 100 dup(100)
gameIsOver db 0
snake_direction db 0
right = 0
left = 1
top = 2
down = 3
speed dw 150
max_speed dw 325
min_speed db 25
speed_factor dw 150
apples dw 8 dup(0)
scores dw 0
scissors_factor db 3
bomb_factor db 5
is_pause db 0
max_scores dw 0
height dw 25
_width dw 80
