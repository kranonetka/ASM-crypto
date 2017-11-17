global shiftreg
section .data
	current_state: db 0xff, 0x0a, 0x66, 0xef
section .text
shiftreg:
	push ebp
	mov ebp,esp
	mov dword eax,[current_state]
	xor ebx,ebx
	inc ebx
	and ebx,eax
	shr eax,1
	xor ecx,ecx
	inc ecx
	and ecx,eax
	xor ebx,ecx
	shl ebx,31
	and eax,ebx
	mov dword [current_state],eax
	pop ebp
	retn
