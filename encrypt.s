global _start
section .data
	filename: db "filename: "
	filename_len: equ $-filename
	secret_char: db '#'
section .bss
	terminal_params: resb 36
	buffer: resb 4096
	buffer_size: equ $-buffer
	text_len: resb 2
	key: resb 80
	key_size: equ $-key
	key_len: resb 1
section .text
_start:
	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,filename
	mov edx,filename_len
	int 0x80

	xor eax,eax
	times 3 inc eax
	xor ebx,ebx
	mov ecx,buffer
	mov edx,buffer_size
	int 0x80
	and [buffer+eax-1], byte 0	;replace enter to '\0'

	mov eax,5
	mov ebx,buffer
	xor ecx,ecx
	int 0x80
	push eax

	xor eax,eax
	times 3 inc eax
	mov ebx,dword [esp]
	mov ecx,buffer
	mov edx,buffer_size
	int 0x80

	mov [text_len],ax
	mov edx,eax
	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,buffer
	int 0x80

	mov eax,54
	xor ebx,ebx
	mov ecx,0x5401
	mov edx,terminal_params
	int 0x80
		
	mov eax,[terminal_params+12]
	push eax
	and eax,dword ~(2+8)
	mov [terminal_params+12],eax
	
	mov eax,54
	inc ecx
	int 0x80

	push esi
	xor esi,esi
	xor edx,edx
	inc edx
._loop:
	xor eax,eax
	times 3 inc eax
	xor ebx,ebx
	mov ecx,key
	add ecx,esi
	int 0x80	;read 1byte from keyboard
	mov eax,4
	inc ebx
	mov ecx,secret_char
	int 0x80	;echo *
	mov ecx,key
	add ecx,esi
	inc esi
	cmp esi,key_size
	je ._key_input_done
	cmp [ecx],byte 10
	jne ._loop
._key_input_done:
	mov edx,esi
	pop esi
	mov [key_len],dl
	mov eax,4
	inc ebx
	mov ecx,key
	int 0x80

	pop dword [terminal_params+12]
	mov eax,54
	xor ebx,ebx
	mov ecx,0x5402
	mov edx,terminal_params
	int 0x80

	mov eax,6
	pop ebx
	int 0x80

	mov eax,1
	xor ebx,ebx
	int 0x80

;buffer - readed text
;text_len - count of symbols in text (2 bytes)
;key - key
;key_len - count of symbols in key (1 byte)
encrypt:
	pushad
	xor ecx,ecx	;ecx - pos of cur char in text (stars from 0)
	xor ebx,ebx
	mov bl,[key_len] ;bl - lenght of key
._loop:
	mov ax,cx
	div bl	;al - pos of char in key for encryption

	popad
