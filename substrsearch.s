global _start
section .data
	string: db "string: "
	string_len: equ $-string
	substring: db "substring for search: "
	substring_len: equ $-substring
section .bss
	input1: resb 256
	input1_size: equ $-input1
	input2: resb 256
	input2_size: equ $-input2
section .text
_start:
	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,string
	mov edx,string_len
	int 0x80

	xor eax,eax
	times 3 inc eax
	xor ebx,ebx
	mov ecx,input1
	mov edx,input1_size
	int 0x80
	and byte [input1+eax-1],0
	
	mov eax,4
	inc ebx
	mov ecx,substring
	mov edx,substring_len
	int 0x80

	xor eax,eax
	times 3 inc eax
	xor ebx,ebx
	mov ecx,input2
	mov edx,input2_size
	int 0x80
	and byte [input2+eax-1],0

	xor eax,eax
	inc eax
	int 0x80
