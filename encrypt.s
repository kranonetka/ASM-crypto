global _start
section .data
	filename: db "filename: "
	filename_len: equ $-filename
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
	
	xor [terminal_params+12],byte 8
	
	mov eax,54
	inc ecx
	int 0x80
	
	xor eax,eax
	times 3 inc eax
	mov ecx,key
	mov edx,key_size
	int 0x80

	mov edx,eax
	mov eax,4
	inc ebx
	int 0x80

	xor [terminal_params+12],byte 8
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
