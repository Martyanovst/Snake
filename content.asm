generate_content proc
    mov bl, is_need_to_create_apple
    test bl, bl 
    jz scissors
    call generate_apple
scissors:
    mov bl, is_need_to_create_scissors
    test bl, bl
    jz bomb
    call generate_scissors
bomb:
    mov bl, is_need_to_create_bomb
    test bl, bl
    jz @@generator_end
    call generate_bomb
@@generator_end:
    ret
endp

generate_apple proc
    call generate_cordinates
    call draw_apple
    mov is_need_to_create_apple, 0
    ret
endp

init_items proc
    mov cl, apple_count
generate_next_apple:
    call generate_apple
    dec cl
    jnz generate_next_apple
    ret
endp

generate_scissors proc
    call generate_cordinates
    call draw_scissors
    mov is_need_to_create_scissors, 0
    ret
endp

generate_bomb proc
    call generate_cordinates
    call draw_bomb
    mov is_need_to_create_bomb, 0
    ret
endp

random_number proc
	push	cx
	push	dx
	push	di
 
	mov	dx, word [seed]
	or	dx, dx
	jnz	@@1
	mov ax, word[ds:006ch]
	mov	dx, ax
    @@1:	
	mov	ax, word [seed2]
	or	ax, ax
	jnz	@@2
	in	ax, 40h
    @@2:		
	mul	dx
	inc	ax
	mov 	word [seed], dx
	mov	word [seed2], ax
 
	xor	dx, dx
	sub	di, si
	inc	di
	div	di
	mov	ax, dx
	add	ax, si
 
	pop	di
	pop	dx
	pop	cx
    ret
endp 

random_coordinates proc ; ax = (random x,random y)
    push si di dx
    mov si, 2
    mov di, 21
    call random_number
    mov dh, al

    mov si, 2
    mov di, 77
    call random_number
    mov dl, al

    mov ax, dx

    pop dx di si
    ret
random_coordinates endp

generate_cordinates proc
    generate_while_not_free_place:
    call random_coordinates
    mov cursor_x, al
    mov cursor_y, ah
    call set_cursor
    call get_object
    mov al, collision_object_symbol
    test al, al
    jz generate_while_not_free_place
    call draw_collision_object
    ret
endp
;ax = number
ToString proc
    push ax
    push dx
    push bx
    push cx
    mov bx, 10
    xor cx, cx
next:
    xor dx, dx
    div bx
    add dx, 48
    push dx
    inc cx
    cmp ax, 0
    jnz next
write:
    pop dx
    mov [di], dx
    inc di
    dec cx
    jnz write
    pop cx
    pop bx
    pop dx
    pop ax
    ret
endp

is_need_to_create_apple db 1
is_need_to_create_scissors db 1
is_need_to_create_bomb db 1

seed		dw 	0
seed2		dw	0

game_over_melody dw 100, 200, 300, 150, 100, 250, 25, 50, 400
game_over_melody_length equ $ - game_over_melody