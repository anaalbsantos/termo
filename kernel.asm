org 0x7e00
jmp 0x0000:start


data:
    string db "00000",0
    resposta db "navio",0
    
    char0_aux db 0
    char1_aux db 0
    char2_aux db 0
    char3_aux db 0
    char4_aux db 0
    
    termoo db "TERMOO", 0
    
    verde db 10
    roxo db 5
    branco db 15
    asterisco db 42
    
    flag db 0
    linha db 0
    coluna db 17
    venceu db 0
    derrota db "PERDEU TUDO!", 0


    a_green db 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
            db 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
            db 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
            db 11, 11, 11, 11, 11, 11, 15,  0,  0,  0,  0,  0,  0, 11, 11, 11, 
            db 11, 11, 11, 11, 11, 15,  0,  0,  0,  0,  0,  0,  0,  0, 11, 11, 
            db 11, 11, 11, 11, 11, 15,  0,  0, 11, 11, 11, 15,  0,  0, 11, 11, 
            db 11, 11, 11, 11, 11, 15,  0,  0, 11, 11, 11, 15,  0,  0, 11, 11, 
            db 11, 11, 11, 11, 11, 15,  0,  0, 15, 15, 15, 15,  0,  0, 11, 11,
            db 11, 11, 11, 11, 11, 15,  0,  0,  0,  0,  0,  0,  0,  0, 11, 11, 
            db 11, 11, 11, 11, 11, 15,  0,  0,  0,  0,  0,  0,  0,  0, 11, 11, 
            db 11, 11, 11, 11, 11, 15,  0,  0, 11, 11, 11, 15,  0,  0, 11, 11, 
            db 11, 11, 11, 11, 11, 15,  0,  0, 11, 11, 11, 15,  0,  0, 11, 11, 
            db 11, 11, 11, 11, 11, 15,  0,  0, 11, 11, 11, 15,  0,  0, 11, 11, 
            db 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
            db 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 
            db 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 

start:
    xor ax, ax
    xor dx, dx  
    mov ds, ax
    mov es, ax

    call modoVideo

    mov dh, 4
    mov dl, 17
    call setcursor

    call termo
    
    call getchar

    cmp al, 49
    jne start

    xor dx, dx
    xor ax, ax
    call clear
    call looping

    mov dh, 10
    mov dl, 13
    call setcursor

    mov si, derrota
    call prints

    call getchar

    call fim


termo:
    call delay
    mov al, 'T'
    call printchar

    call delay
    mov al, 'E'
    call printchar

    call delay
    mov al, 'R'
    call printchar

    call delay
    mov al, 'M'
    call printchar

    call delay
    mov al, 'O'
    call printchar
    ret


loop_letras:

    mov dx, 0
    mov cx, 0
    inc dx
    cmp dx, 16
    je .done

    .loop1:

        lodsb
        mov ah, 0ch
        inc cx
        int 10h
        cmp cx, 16
        je loop_letras
        jmp .loop1

    .done:
        jmp $


looping: 
    .loop:

        inc byte[linha]
        mov byte[coluna], 17
        mov di, string  
        mov bl, 15
        
        push dx

        mov dl, 17
        mov dh, byte[linha]
        call setcursor

        call gets
        call endl

        inc byte[flag]

        pop dx
        inc dx

        push dx
        

        call search_green
        call search_purple
        
        pop dx 
        
        mov byte[char0_aux], 0
        mov byte[char1_aux], 0
        mov byte[char2_aux], 0
        mov byte[char3_aux], 0
        mov byte[char4_aux], 0

        cmp dx, 7
        jne .loop

    ret 

modoVideo:
    mov ah, 0
    mov al, 13h
    int 10h

    ;letra maior
    mov ah, 11h
    mov al, 03h

    mov ah, 4Ch
    int 21h

    mov bh, 0
    mov bl, 15 ;cor
    int 10h
    
    ret

clear:                
    ; set the cursor to top left-most corner of screen
    mov dx, 0 
    mov bh, 0      
    mov ah, 0x2
    int 0x10

    ; print 2000 blank chars to clean  
    mov cx, 2000 
    mov bh, 0
    mov al, 0x20 ; blank char
    mov ah, 0x9
    int 0x10
    
    ; reset cursor to top left-most corner of screen
    mov dx, 0 
    mov bh, 0      
    mov ah, 0x2
    int 0x10
    ret


gets:
    xor cx, cx ;contador = 0
    mov al,0
    .loop:
        call getchar

        cmp al,0x08
        je .backspace

        cmp al, 0x0d ;0x0d = 13 = enter
        je .pre_done

        jmp .checa_limite

        .pre_done:
            cmp cx, 5
            je .done

            jmp .loop
            
        .checa_limite:

            cmp cx, 5
                je .loop
            
            inc cx
            stosb

            call printchar
            jmp .loop

        .backspace:
            cmp cl,0
            je .loop
            dec di
            dec cl
            mov byte[di],0
            call delchar
            jmp .loop
            
        .done:
            call printchar
            mov al, 0
            stosb

            ret

prints:
    lodsb
    cmp al, 0
    je .end 
    call printchar
    jmp prints
    
    .end:
        ret


getchar:
    mov ah, 0x00
    int 16h
    ret

printchar:
    mov ah, 0xe
    int 10h
    ret

delchar:
    mov al, 0x08
    call printchar
    mov al, ''
    call printchar
    mov al,0x08
    call printchar

    ret


endl:
    mov al, 0x0a
    call printchar
    mov al, 0x0d
    call printchar

    ret

search_green:

    mov si, string     ;caracteres em al
    mov dx, 0           ;dx como indice de string

    mov di, resposta    ;voltando ponteiro para o início de resposta
    mov cx, 0           ;cx como indice de resposta

    .loop:

        lodsb
        cmp dx, 5
        je .end
        cmp al, byte[di]
        je .green
        inc dx
        inc cx
        inc di
        jmp .loop

        .end:
            ret
        
        .green:

            cmp cx, 0
            je .char0
            cmp cx, 1
            je .char1
            cmp cx, 2
            je .char2
            cmp cx, 3
            je .char3
            cmp cx, 4
            je .char4

            .char0:
                mov byte[char0_aux], 42
                jmp .endgreen
            .char1:
                mov byte[char1_aux], 42
                jmp .endgreen
            .char2:
                mov byte[char2_aux], 42
                jmp .endgreen
            .char3:
                mov byte[char3_aux], 42
                jmp .endgreen
            .char4:
                mov byte[char4_aux], 42
                jmp .endgreen

            .endgreen:
                inc dx
                inc cx
                inc di
                jmp .loop


search_purple:
    mov si, string     ;caracteres em al
    mov dx, 0           ;dx como indice de string

    .loop_string:
        cmp dx, 5     ;cabou string
        je .end
        
        mov di, resposta    ;voltando ponteiro para o início de resposta
        mov cx, 0           ;cx como indice de resposta
        lodsb               ;pega próximo caracter de string e coloca em al
        call compare_char   ;comparar 1 caracter de string com resposta
        inc dx              ;incrementa contador de string  

        jmp .loop_string

        .end:
            call endl
            ret


compare_char: 
    cmp cx,5          ;cabou caracteres de resposta
    je .endcomp
    
    cmp al, byte[di]  ;al = caracter de string, di = caracter de resposta
    je .definecolor
    jmp .rodaloop 
    

    .endcomp:           ;se acabou e não printou letra verde ou 
        mov bh, 0       ;amarelo, printa a letra branca
        mov bl, [branco] 

        push dx
        xor dx, dx
        mov dl, byte[coluna]
        mov dh, byte[linha]
        call setcursor

        call printchar

        xor dx, dx
        inc byte[coluna]
        pop dx
        
        ret
    
    .rodaloop:
        inc di            ;próximo caracter de string
        inc cx            ;incrementa contador de resposta
        jmp compare_char 



    .definecolor:
        cmp dx, cx           ;se contadores são iguais: posição certa(verde)
        je .green           
        
        cmp cx, 0            ;se não está na posição certa, PODE ser roxo
        je .checkasteristico0
        cmp cx, 1            
        je .checkasteristico1
        cmp cx, 2
        je .checkasteristico2
        cmp cx, 3
        je .checkasteristico3
        cmp cx, 4 
        je .checkasteristico4

        .checkasteristico0:
            cmp byte[char0_aux], 42  ;se for * é pq é verde e já foi colocado
            je .rodaloop
            mov byte[char0_aux], 42
            ;push dx
            jmp .purple
        
        .checkasteristico1:
            cmp byte[char1_aux], 42  ;se for * é pq é verde e já foi colocado
            je .rodaloop
            mov byte[char1_aux], 42
            ;push dx
            jmp .purple
        
        .checkasteristico2:
            cmp byte[char2_aux], 42  ;se for * é pq é verde e já foi colocado
            je .rodaloop
            mov byte[char2_aux], 42
            ;push dx
            jmp .purple
        
        .checkasteristico3:
            cmp byte[char3_aux], 42  ;se for * é pq é verde e já foi colocado
            je .rodaloop
            mov byte[char3_aux], 42
            ;push dx
            jmp .purple
        
        .checkasteristico4:
            cmp byte[char4_aux], 42  ;se for * é pq é verde e já foi colocado
            je .rodaloop
            mov byte[char4_aux], 42
            ;push dx
            jmp .purple


        .purple:
            mov bh, 0
            mov bl, [roxo]
            
            push dx
            xor dx, dx
            mov dl, byte[coluna]
            mov dh, byte[linha]
            call setcursor

            call printchar
            inc byte[coluna]
            pop dx

            ret

        .green:
            mov bh, 0
            mov bl, [verde]

            push dx
            xor dx, dx
            mov dl, byte[coluna]
            mov dh, byte[linha]
            call setcursor

            call printchar
            inc byte[coluna]
            pop dx

            ret

         
delay:
   mov ah, 86h
   mov cx,5
   mov dx,500
   int 15h
ret

strcpy:
    .loop1:
        lodsb
        stosb
        cmp al, 0
        je .endloop1
        jmp .loop1

    .endloop1:
        ret


setcursor:
    mov ah, 2
    mov bh, 0
    int 10h
    ret

fim:
    jmp $
