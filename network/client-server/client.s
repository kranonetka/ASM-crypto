;socket
;connect
;send
global _start
section .bss
	socket: resb 4
	buffer: resb 4096
	bufflen equ $ - buffer

section .text
_start:
	call _socket
	call _connect
xor eax,eax
inc eax
xor ebx,ebx
int 0x80

_socket:
	mov eax,102
	xor ebx,ebx
	inc ebx	;ebx=1 - socket
	push dword 0	;0(arg 3)
	push dword 1	;SOCK_STREAM(arg 2)
	push dword 2	;PF_INET(arg 1)
	mov ecx,esp
	int 0x80
	call printReg
	mov [socket],eax
	add esp,12
	ret

_connect:
	mov eax,102
	xor ebx,ebx
	times 3 inc ebx	;ebx=2 - bind
	push dword 0x0100007f	;server IP(127.0.0.1)
	push word 0x8f8f	;server PORT
	push word 2	;INET
	mov ecx,esp
	push dword 16	;sockaddr_len(arg 3)
	push ecx	;sockaddr_ptr(arg 2)
	push dword [socket]	;socket_fd(arg 1)
	mov ecx,esp
	int 0x80
	call printReg
	add esp,20
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
