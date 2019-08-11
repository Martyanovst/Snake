Sound      proc
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
           pop      ax
           ret
No_Sound   endp


_current_sound dw 0
apple_sound = 130
scissors_sound = 200
move_sound = 100