global _start
section .data
	string: db "string: "
	string_len: equ $-string
	substring: db "substring for search: "
	substring_len: equ $-substring
section .bss
	input_str: resb 4096
	input_str_size: equ $-input_str
	input_substr: resb 4096
	input_substr_size: equ $-input_substr
section .text
_start:
	mov esi,input_str
	mov edi,input_substr

	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,string
	mov edx,string_len
	int 0x80

	xor eax,eax
	times 3 inc eax
	xor ebx,ebx
	mov ecx,esi
	mov edx,input_str_size
	int 0x80
	dec eax
	and byte [esi+eax],0
	
	mov eax,4
	inc ebx
	mov ecx,substring
	mov edx,substring_len
	int 0x80

	xor eax,eax
	times 3 inc eax
	xor ebx,ebx
	mov ecx,edi
	mov edx,input_substr_size
	int 0x80
	dec eax
	and byte [edi+eax],0
	
	;call substrsearch

	xor eax,eax
	inc eax
	int 0x80

substrsearch:
;esi - source string
;edi - substring for search
	push edi
	xor eax,eax
	xor ecx,ecx
	dec ecx
	cld
	repne scasb	;compare with al=0
	neg ecx
	mov edx,ecx	;edx - substrnig length

	xor ecx,ecx
	dec ecx
	mov edi,esi
	repne scasb	;compare with al=0
	neg ecx	;ecx - src string length
	
	pop edi

	;esi - src string
	;edi - substring
	;ecx - src string length
	;edx - substring length
	
	cmp edx,ecx	;substr len ? srcstr len
	jle length_ok	;if substring length less or equal
			;than src string length
	
	dec eax
	ret	;if substr len greater than
		;src string len return eax=-1
length_ok:
	push edi
	push esi

	mov byte al,[edi] ;al contains first symbol from substr

	xchg esi,edi
	;esi - substring
	;edi - src string
