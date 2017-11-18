global shiftreg
global global_state
section .data
	global_state: db 0x7f, 0x0a, 0x66, 0xef
section .text
shiftreg:
	mov dword eax,[global_state]
	xor ebx,ebx
	inc ebx
	and ebx,eax
	shr eax,1
	xor ecx,ecx
	inc ecx
	and ecx,eax
	xor ebx,ecx
	shl ebx,30
	xor eax,ebx
	mov dword [global_state],eax
	retn
