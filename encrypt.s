global _start
section .data
	filename: db "filename: "
	filename_len: equ $-filename
section .bss
	descriptor: resb 4
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
	dec ebx
	mov ecx,buffer
	mov edx,buffer_size
	int 0x80
	and [buffer+eax-1], byte 0

	mov eax,5
	mov ebx,buffer
	xor ecx,ecx
	int 0x80

	push eax

	xor eax,eax
	times 3 inc eax
	pop ebx
	push ebx
	mov ecx,buffer
	mov edx,buffer_size
	int 0x80

	mov edx,eax
	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,buffer
	int 0x80

	mov eax,6
	pop ebx
	int 0x80

	mov eax,1
	xor ebx,ebx
	int 0x80
