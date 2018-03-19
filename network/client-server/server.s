global _start
section .data
	CONN_MSG: db "New client connected!",10,0
	CONN_MSG_LEN equ $ - CONN_MSG
	NEW_MSG: db "Message from client: ",0
	NEW_MSG_LEN equ $ - NEW_MSG
section .bss
	socket: resb 4
	client: resb 4
	buffer: resb 4096
	bufflen equ $ - buffer
	read_count: resb 4
section .text
_start:
		call _socket
		call _bind
		call _listen
	.main_loop:
		call _accept
		call _fork
		test eax,eax
		jnz .read
			call _close_socket
			jmp .main_loop
		.read:
			call _read
			test eax,eax
			jz .read_done
			mov eax,4
			mov ebx,1
			mov ecx,NEW_MSG
			mov edx,NEW_MSG_LEN
			int 0x80
			mov eax,4
			mov ecx,buffer
			mov edx,[read_count]
			int 0x80
			call _echo
			jmp .read
		.read_done:
			call _close_socket
			jmp .main_loop

_exit:
	xor eax,eax
	inc eax
	int 0x80

_fork:
	xor eax,eax
	times 2 inc eax
	int 0x80
	;call printReg
	ret

_socket:
	mov eax,102
	mov ebx,1	;ebx=1 - socket
	push dword 0	;0(arg 3)
	push dword 1	;SOCK_STREAM(arg 2)
	push dword 2	;PF_INET(arg 1)
	mov ecx,esp
	int 0x80
	;call printReg
	mov [socket],eax
	add esp,12
	ret

_bind:
	mov eax,102
	mov ebx,2	;ebx=2 - bind
	push dword 0	;IP(0.0.0.0)
	push word 0x8f8f	;PORT(36751)
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
	
_listen:
	mov eax,102
	mov ebx,4	;ebx=4 - listen
	push dword 5	;queue size
	push dword [socket]	;socket_fd
	int 0x80
	;call printReg
	add esp,8
	ret

_accept:
	mov eax,102
	mov ebx,5	;ebx=5 - accept
	push dword 0	;lenght(arg 3)
	push dword 0	;NULL ptr(arg 2)
	push dword [socket]	;socket_fd(arg 1)
	mov ecx,esp
	int 0x80
	;call printReg
	mov [client],eax
	mov eax,4
	mov ebx,1
	mov ecx,CONN_MSG
	mov edx,CONN_MSG_LEN
	int 0x80
	add esp,12
	ret

_read:
	mov eax,3
	mov ebx,[client]
	mov ecx,buffer
	mov edx,bufflen
	int 0x80
	mov [read_count],eax
	;call printReg
	ret

_echo:
	mov eax,4
	mov ebx,[client]
	mov ecx,buffer
	mov edx,[read_count]
	int 0x80
	;call printReg
	ret

_close_socket:
	mov eax,6
	mov ebx,[client]
	int 0x80
	mov dword [client],0
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
