; флаги:
; x - тип самопересечения.
; w - тип верхней стенки.
; l - стартовая длина змейки (максимум 8).
; i - стартовое количество яблок(максимум 4).
; h - справка.



current_byte_pointer equ si
current_state equ al
current_byte equ ah
automat_pointer equ di

parse_args proc
    push cs
    pop ds
    mov cl, ds:[80h]
    cmp cl, 0
    je @@end_parse
    mov current_state, 0
    mov current_byte_pointer, 81h
read_next_byte:
    mov current_byte, [current_byte_pointer] ; si - current byte
    mov automat_pointer, offset automat
    mov dx, [automat_pointer]
next_state_failed:
    cmp ax, dx
    je next_state_success
    add automat_pointer, 3
    mov dx, [automat_pointer]
    cmp dl, 'd'
    je @@error
    jmp next_state_failed
next_state_success:
    mov current_state, [automat_pointer+2]
    call try_read_arg
    inc current_byte_pointer
    dec cl
    jnz read_next_byte
@@end_parse:
    ret
    endp

@@error:
    mov dx, offset error_message
    mov ah, 9
    int 21h
@@exit:
    mov ax, 4c01h
    int 21h
    ret


try_read_arg proc
    sub current_byte, 48
    cmp current_state, 1
    jne f1
    mov cross_mode, current_byte
    jmp switch
f1:
    cmp current_state, 2
    jne f2
    mov top_wall_type, current_byte
    jmp switch
f2:
    cmp current_state, 3
    jne f3
    mov snake_length, current_byte
    jmp switch
f3:
    cmp current_state, 4
    jne f4
    mov apple_count, current_byte
    jmp switch
f4:
    cmp current_state, 'h'
    jne switch
    call help
switch:
    ret
endp

help proc
    mov dx, offset error_message
    mov ah, 9
    int 21h
    jmp @@exit
    ret
endp

error_message db 'Incorrect params. If you want to see manual, call programm with -h param.$'
automat:
    db 0, ' ', 0
    db 0, '-', '-'

    db '-', 'x', 'x'
    db '-', 'w', 'w'
    db '-', 'l', 'l'
    db '-', 'i', 'i'
    db '-', 'h', 'h'
    
    db 'x', ' ' ,'x'
    db 'w', ' ' ,'w'
    db 'l', ' ' ,'l'
    db 'i', ' ' ,'i'

    db 'x', '1', 1
    db 'x', '2', 1
    db 'x', '3', 1

    db 'w', '1', 2
    db 'w', '2', 2

    db 'l', '3', 3
    db 'l', '4', 3
    db 'l', '5', 3
    db 'l', '6', 3
    db 'l', '7', 3
    db 'l', '8', 3

    db 'i', '1', 4
    db 'i', '2', 4
    db 'i', '3', 4
    db 'i', '4', 4

    db 1, ' ', 0
    db 2, ' ', 0
    db 3, ' ', 0
    db 4, ' ', 0

    db 'dead' 
    
cross_mode db 1
top_wall_type db 1
snake_length db 10
apple_count db 1
