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
	mov esi,input_str
	mov ecx,esi ;esi - string
	mov edx,input_str_size
	int 0x80
	dec eax
	and byte [esi+eax],0

	mov eax,4
	inc ebx
	mov ecx,msg_substring
	mov edx,msg_substring_len
	int 0x80

	xor eax,eax
	times 3 inc eax
	xor ebx,ebx
	mov edi,input_substr
	mov ecx,edi ;edi - substring
	mov edx,input_substr_size
	int 0x80
	dec eax
	and byte [edi+eax],0

	;esi - string
	;edi - substring
	call substrsearch

	;eax - start pos of match (-1 if no match)
	call printReg

	xor eax,eax
	inc eax
	xor ebx,ebx
	int 0x80

substrsearch:
;esi - string
;edi - substring
push ebx
push ecx
push edx
	call strlen
	dec eax
	mov [substring_len],eax ;[substring_len] == substring.size() - 1
	xchg edi,esi
	call strlen
	mov [string_len],eax ;[string_len] == string.size()
;edi - string
;esi - substring
	lodsb ;search for 1st symbol of substring
	mov ebx,esi ;save address of 2nd symbol of substring
	mov edx,edi ;save address of 1st symbol of string
._loop:
	mov esi,ebx
	mov ecx,[string_len]
	repne scasb ;search for 1st symbol from substring in string
	jz ._maybe_found
mov edi,edx
mov esi,ebx
dec esi
pop edx
pop ecx
pop ebx
xor eax,eax
dec eax
ret ;return -1(4294967295) if not found
._maybe_found:
	mov [string_len],ecx
	mov ecx,[substring_len]
	repe cmpsb
	jz ._found
	dec edi
	jmp ._loop
._found:
	sub edi,edx
	sub edi,[substring_len]
	mov eax,edi
mov edi,edx
mov esi,ebx
dec esi
pop edx
pop ecx
pop ebx
ret ;return pos of start matching

strlen:
;edi - string
push ecx
push edi
	xor eax,eax ;search for '0'
	xor ecx,ecx
	dec ecx
	repne scasb
	mov eax,edi
pop edi
	sub eax,edi
	dec eax
pop ecx
ret

printReg:
;eax - register with value
pushad
	xor ecx,ecx
	mov ebx,10
	mov edi,esp
	dec edi
	mov byte [edi],10
	inc ecx
._stack_fill:
	xor edx,edx
	div ebx
	add dl,'0'
	dec edi
	mov byte [edi],dl
	inc ecx
	test eax,eax
	jnz ._stack_fill
	mov eax,4
	xor ebx,ebx
	inc ebx
	mov edx,ecx
	mov ecx,edi
	int 0x80
popad
ret
