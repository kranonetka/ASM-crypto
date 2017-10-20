global _start
section .data
	msg_string: db "string: "
	msg_string_len: equ $-msg_string
	msg_substring: db "substring for search: "
	msg_substring_len: equ $-msg_substring
section .bss
	input_str: resb 4096
	input_str_size: equ $-input_str
	input_substr: resb 4096
	input_substr_size: equ $-input_substr
	string_len: resd 1
	substring_len: resd 1
section .text
_start:

	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,msg_string
	mov edx,msg_string_len
	int 0x80

	xor eax,eax
	times 3 inc eax
	xor ebx,ebx
	mov edi,input_str
	mov ecx,edi
	mov edx,input_str_size
	int 0x80
	dec eax
	and byte [edi+eax],0

;;;;;;;;TEST
	call strlen
	mov eax,ecx
	call printReg
	mov eax,1
	mov ebx,0
	int 0x80
;;;;;;;;


	
	mov eax,4
	inc ebx
	mov ecx,msg_substring
	mov edx,msg_substring_len
	int 0x80

	xor eax,eax
	times 3 inc eax
	xor ebx,ebx
	mov esi,input_substr
	mov ecx,esi
	mov edx,input_substr_size
	int 0x80
	dec eax
	and byte [esi+eax],0
	
	;edi - string
	;esi - substring
	call substrsearch

	;eax - start pos of match (-1 if no match)
	call printReg

	xor eax,eax
	inc eax
	xor ebx,ebx
	int 0x80

strlen:
;edi - string address
push eax
	xor eax,eax
	xor ecx,ecx
	dec ecx
	cld
	repne scasb
	neg ecx
pop eax
	ret


substrsearch:
;edi - source string
;esi - substring for search
push edi
push esi
push ecx
	xor eax,eax
	xor ecx,ecx
	dec ecx ;ecx - max 32bit value
	cld
push edi
	repne scasb ;compare with '\0'
pop edi
	neg ecx ;ecx - count of symbols in string
	mov [string_len],ecx
	xor ecx,ecx
	dec ecx
push edi
	mov edi,esi
	repne scasb
pop edi
	neg ecx ;ecx - count of symbols in substring
	dec ecx
	mov [substring_len],ecx

	;edi - string address
	;esi - substring address

	mov edx,edi ;save string address

	lodsb ;read first symbol from substring (esi)
	mov ebx,esi ;address of second symbol
._loop:
	mov esi,ebx
	mov ecx,[string_len]
	repne scasb
	jz ._mb_found
pop ecx
pop esi
pop edi
	xor eax,eax
	dec eax
	ret
._mb_found:
	mov [string_len],ecx
	mov ecx,[substring_len]
	repe cmpsb
	jnz ._loop
	sub edi,edx
	sub edi,[substring_len]
	mov eax,edi
pop ecx
pop esi
pop edi
ret

printReg:
;eax - register with value
	xor ecx,ecx
	mov bx,10
	sub esp,14
._stack_fill:
	mov esi,esp
	xor edx,edx
	div bx
	add dl,'0'
	sub esi,ecx
	mov [esi],dl
	inc ecx
	test eax,eax
	jnz ._stack_fill
	
	mov edx,ecx
	mov eax,4
	mov ebx,1
	mov ecx,esi
	int 0x80
	add esp,14
ret
	
