global _start
section .data
	filename_string: db "filename: "
	filename_len: equ $-filename_string
	password_string: db "password: "
	password_len: equ $-password_string
	buffer8: db '*'
	backspace: db 0x08, 0x20, 0x08
	print_count: dw 95
section .bss
	terminal_params: resb 36
	buffer: resb 4096
	buffer_size: equ $-buffer
	key: resb 80
	key_size: equ $-key
section .text
_start:
	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,filename_string
	mov edx,filename_len
	int 0x80	;print("filename: ")

	xor eax,eax
	times 3 inc eax
	xor ebx,ebx
	mov ecx,buffer
	mov edx,buffer_size
	int 0x80	;user input from keyboard
	mov [buffer+eax-1],byte 0	;replace enter to '\0'

	mov eax,5
	mov ebx,buffer
	xor ecx,ecx
	int 0x80	;open file with typed name

	mov ebx,eax
	xor eax,eax
	times 3 inc eax
	mov ecx,buffer
	mov edx,buffer_size
	int 0x80	;read from file to buffer
	dec eax

	push ebx	;descriptor at stack

	mov edx,eax
	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,buffer
	int 0x80	;print file content
	push edx

	mov eax,4
	mov ecx,password_string
	mov edx,password_len
	int 0x80
	
	mov eax,54	;syscall_ioctl
	xor ebx,ebx	;stdin
	mov ecx,0x5401	;TCGETS
	mov edx,terminal_params
	int 0x80
	
	push dword [terminal_params+12]	;save current terminal params

	and [terminal_params+12],dword ~10	;disable canonical and echo flags
	mov eax,54	;syscall_ioctl
	inc ecx	;TCSETS
	int 0x80

	xor esi,esi
	xor edx,edx
	inc edx
key_input:
	xor eax,eax
	times 3 inc eax
	xor ebx,ebx
	mov ecx,key
	add ecx,esi
	int 0x80	;read single char from keyboard
	cmp byte [ecx],10	;why test byte [ecx],10 doesn't work?
	je key_input_enter	;if (enter)
	cmp byte [ecx],127
	je key_input_backspace	;if (backspace)
	mov eax,4
	inc ebx	;ebx=1
	mov ecx,buffer8
	int 0x80
	inc esi
	cmp esi,key_size
	jl key_input
	jmp key_input_done
key_input_backspace:
	test esi,esi
	jz key_input
	mov eax,4
	inc ebx
	mov ecx,backspace
	times 2 inc edx
	int 0x80
	times 2 dec edx
	dec esi
	jmp key_input
key_input_enter:
	test esi,esi
	jz key_input
	mov [buffer8],byte 10
	mov eax,4
	inc ebx
	mov ecx,buffer8
	int 0x80
key_input_done:
	pop dword [terminal_params+12]
	mov eax,54	;syscall_ioctl
	xor ebx,ebx	;stdin
	mov ecx,0x5402	;TCSETS
	mov edx,terminal_params
	int 0x80

	mov edi,buffer	;text
	mov ebx,esi	;key lenght
	mov esi,key	;key
	pop eax	;text len
	call encrypt
	call decrypt

	mov edx,eax
	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,edi
	int 0x80

	mov eax,6
	pop ebx
	int 0x80	;close file

	xor eax,eax
	inc eax
	xor ebx,ebx
	int 0x80	;prog end

encrypt:
	;edi - text
	;esi - key
	;eax - text lenght
	;ebx - key lenght
	push ecx
	push edx
	push eax
	xor ecx,ecx	;ecx - pos of curr char in text (starts from 0)
._loop:
	xor edx,edx
	mov ax,cx	;DX:AX = CX (IN DX)
	div bx	;dx - pos of char in key 4 encrypting
	mov al,[edi+ecx]
	add al,[esi+edx]
	sub al,64
	xor ah,ah
	xor dx,dx	;DX:AX = AL = encrypted symbol without mod95
	div word [print_count] ;dl - encrypted symbol without +32
	add dl,32	;dl - encrypted symbol
	mov [edi+ecx],dl
	inc ecx
	cmp ecx,[esp]
	jl ._loop
pop eax
pop edx
pop ecx
ret

decrypt:
	;edi - text
	;esi - key
	;eax - text lenght
	;ebx - key lenght
	push ecx
	push edx
	push eax
	xor ecx,ecx	;ecx - pos of curr char 4 decrypt
._loop:
	xor edx,edx
	mov ax,cx	;DX:AX = CX (in AX)
	div bx	;dx - pos of char in key 4 decrypt
	mov al,[edi+ecx]	;al - encrypted symbol
	cmp al,[esi+edx]
	jge ._greater
	add al,95
._greater:
	sub al,[esi+edx]
	add al,32	;al - decrypted symbol
	mov [edi+ecx],al
	inc ecx
	cmp ecx,[esp]
	jl ._loop
pop eax
pop edx
pop ecx
ret
