 mov ax, 0x07C0  ; set up segments
   mov ds, ax
   mov es, ax
 
   mov si, welcome
   call print_string
   
   mov si, cmdwelcomeprompt
   call print_string
 
 mainloop:
   mov si, prompt
   call print_string
 
   mov di, buffer
   call get_string
 
   mov si, buffer
   cmp byte [si], 0  ; blank line?
   je mainloop       ; if so, ignore
 
   mov si, buffer
   mov di, cmd_hi  ; "hi" command
   call strcmp
   jc .helloworld
 
   mov si, buffer
   mov di, cmd_help  ; "help" command
   call strcmp
   jc .help
   
   mov si, buffer
   mov di, cmd_a  ; "add" command
   call strcmp
   jc .add
   
   mov si, buffer
   mov di, cmd_s  ; "sub" command
   call strcmp
   jc .sub
   
   mov si, buffer
   mov di, cmd_m  ; "mul" command
   call strcmp
   jc .mul
   
   mov si, buffer
   mov di, cmd_d  ; "div" command
   call strcmp
   jc .div
 
   mov si,badcommand
   call print_string 
   jmp mainloop  
 
 .helloworld:
   mov si, msg_helloworld
   call print_string
 
   jmp mainloop
 
 .help:
   mov si, msg_help
   call print_string
 
   jmp mainloop
;===========================================
 .add:
   mov si, msg_first  ;Ask for first #
   call print_string

   mov eax, buffer  ;Assign first # to eax
   call get_string

   mov si, msg_second  ;Ask for second #
   call print_string 
   
   mov ebx, buffer  ;Assign first # to ebx
   call get_string
   
   sub eax, '0'  ;ASCII > DEC
   sub ebx, '0'
   
   add eax, ebx ;dest, source OR source, dest? TEST
   add eax, '0' ;DEC> ASCII
   call print_string ;should print the number, we will see
 
 .sub:
   mov si, msg_first
   call print_string

   mov eax, buffer
   call get_string   

   mov si, msg_second
   call print_string

   mov ebx, buffer
   call get_string

   sub eax, '0'  ;ASCII > DEC
   sub ebx, '0'  

   sub eax, ebx ;dest, source OR source, dest?
   add eax, '0' ;DEC> ASCII
   call print_string ;should print the number, we will see
 
 .mul:
 
   mov si, warning ;warning, only accepting numbers <16 bit (DEC 65535)
   call print_string
 
   mov si, msg_first
   call print_string 
   
   mov ax, buffer
   call get_string 

   mov si, msg_second
   call print_string

   mov dx, buffer
   call get_string

   sub ax, '0'  ;ASCII > DEC
   sub dx, '0'

   imul dx
   add ax, '0' ;DEC> ASCII
   add dx, '0' ;not sure if needed, since results are stored in dx:ax
   call print_string
;dx:ax = ax* arg where arg is imul arg   
   
   
 
 .div:
   mov si, warning ;warning, only accepting numbers <16 bit (DEC 65535)
   call print_string
 
   mov si, msg_first
   call print_string 
   
   mov ax, buffer
   call get_string 

   mov si, msg_second
   call print_string

   mov dx, buffer
   call get_string

   sub ax, '0'  ;ASCII > DEC
   sub dx, '0'

   idiv dx
   
   mov si, msg_quotient
   call print_string
   
   add ax, '0' ;DEC> ASCII
   call print_string
   
   mov si, msg_remainder
   call print_string
   add dx, '0' ;not sure if needed, since results are stored in dx:ax
   call print_string
   
;============================================

 welcome db 'Welcome to SnairOS!', 0x0D, 0x0A, 0
 cmdwelcomeprompt db 'Enter a Command: (Type help for a list of commands)', 0x0D, 0x0A, 0
 msg_helloworld db 'Hello OSDev World!', 0x0D, 0x0A, 0
 msg_first db 'Enter first number:', 0x0D, 0x0A, 0
 msg_second db 'Enter second number:', 0x0D, 0x0A, 0
 warning db 'Warning: all numbers must be less than 65535 when multiplying or dividing', 0x0D, 0x0A, 0
 badcommand db 'Bad command entered.', 0x0D, 0x0A, 0
 msg_quotient db 'Quotient:', 0x0D, 0x0A, 0
 msg_remainder db 'Remainder:', 0x0D, 0x0A, 0
 prompt db '>', 0
 cmd_hi db 'hi', 0
 cmd_help db 'help', 0
 cmd_a db 'a', 0
 cmd_s db 's', 0
 cmd_m db 'm', 0
 cmd_d db 'd', 0
 msg_help db 'Commands: hi, help, (a)dd, (s)ubtract, (m)ultiply, (d)ivide', 0x0D, 0x0A, 0
 buffer times 64 db 0
 
 ; =====
 ; calls
 ; =====
 
 print_string:
   lodsb        ; byte from SI
 
   or al, al  ; logical or AL by itself
   jz .done   ; if the result is zero, leave
 
   mov ah, 0x0E
   int 0x10      ; otherwise, print out the character!
 
   jmp print_string
 
 .done:
   ret
 
 get_string:
   xor cl, cl
 
 .loop:
   mov ah, 0
   int 0x16   ; wait for keypress
 
   cmp al, 0x08    ; backspace pressed?
   je .backspace 
 
   cmp al, 0x0D  ; enter pressed?
   je .done      
 
   cmp cl, 0x3F  ; 63 chars inputted?
   je .loop      ; yes, only let in backspace and enter
 
   mov ah, 0x0E
   int 0x10      ; print out character
 
   stosb  ; put character in buffer
   inc cl
   jmp .loop
 
 .backspace:
   cmp cl, 0	; beginning of string?
   je .loop	; yes, ignore the key
 
   dec di
   mov byte [di], 0	; delete character
   dec cl		; decrement counter as well
 
   mov ah, 0x0E
   mov al, 0x08
   int 10h		; backspace on the screen
 
   mov al, ' '
   int 10h		; blank character out
 
   mov al, 0x08
   int 10h		; backspace again
 
   jmp .loop	; go to the main loop
 
 .done:
   mov al, 0	; null terminator
   stosb
 
   mov ah, 0x0E
   mov al, 0x0D
   int 0x10
   mov al, 0x0A
   int 0x10		; newline
 
   ret
 
 strcmp:
 .loop:
   mov al, [si]   ; grab a byte from SI
   mov bl, [di]   ; grab a byte from DI
   cmp al, bl     ; are they equal?
   jne .notequal  ; nope, we're done.
 
   cmp al, 0  ; are both bytes (they were equal before) null?
   je .done   ; yes, we're done.
 
   inc di     ; increment DI
   inc si     ; increment SI
   jmp .loop  ; loop!
 
 .notequal:
   clc  ; not equal, clear the carry flag
   ret
 
 .done: 	
   stc  ; equal, set the carry flag
   ret
 
   times 510-($-$$) db 0
   dw 0AA55h ; some BIOSes require this signature