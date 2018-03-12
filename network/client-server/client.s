;socket
;connect
;send
global _start
section .data
	msg: db "Message for server: ",0
	msg_len equ $ - msg

section .bss
	uinput_buffer: resb 4096
	uinput_bufflen equ $ - uinput_buffer
	uinput_read: resd 1
	socket: resd 1
	buffer: resb 4096
	bufflen equ $ - buffer

section .text
_start:
	call _socket

	call _connect
.loop:
	mov eax,4
	mov ebx,1
	mov ecx,msg
	mov edx,msg_len
	int 0x80

	mov eax,3
	xor ebx,ebx
	mov ecx,uinput_buffer
	mov edx,uinput_bufflen
	int 0x80
	mov [uinput_read],eax

	call _send

	call _read
jmp .loop
	call _close_socket

xor eax,eax
inc eax
xor ebx,ebx
int 0x80

_read:
	mov eax,3
	mov ebx,[socket]
	mov ecx,buffer
	mov edx,bufflen
	int 0x80
	;call printReg
	mov edx,eax
	mov eax,4
	mov ebx,1
	int 0x80
	ret

_send:
	mov eax,102
	mov ebx,9	;ebx=9 - send
	push dword 0
	push dword [uinput_read]
	push dword uinput_buffer
	push dword [socket]
	mov ecx,esp
	int 0x80
	;call printReg
	add esp,16
	ret

_socket:
	mov eax,102
	xor ebx,ebx
	inc ebx	;ebx=1 - socket
	push dword 0	;0(arg 3)
	push dword 1	;SOCK_STREAM(arg 2)
	push dword 2	;PF_INET(arg 1)
	mov ecx,esp
	int 0x80
	;call printReg
	mov [socket],eax
	add esp,12
	ret

_connect:
	mov eax,102
	mov ebx,3	;ebx=3 - connect
	push dword 0x0100007f	;server IP(127.0.0.1)
	push word 0x8f8f	;server PORT
	push word 2	;INET
	mov ecx,esp
	push dword 16	;sockaddr_len(arg 3)
	push ecx	;sockaddr_ptr(arg 2)
	push dword [socket]	;socket_fd(arg 1)
	mov ecx,esp
	int 0x80
	;call printReg
	add esp,20
	ret

_close_socket:
	mov eax,6
	mov ebx,[socket]
	int 0x80
	;call printReg
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
