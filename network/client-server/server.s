;Создать сокет eax=102, ebx=1 - int socket(int domain, int type, int protocol)
;сокет сохранить
;Забиндить сокет eax=102, ebx=2 - int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
;Начать слушать eax=102, ebx=4 - int listen(int sockfd, int backlog)
global _start
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

		.read_loop:
			call _read
			call _echo

			cmp dword [read_count],0
			je .read_complete

		jmp .read_loop

	.read_complete:
	call _close_socket
	mov dword [client],0
	jmp .main_loop
	

xor eax,eax
inc eax	;sys_exit
xor ebx,ebx	;err_code == 0
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

_bind:
	mov eax,102
	xor ebx,ebx
	times 2 inc ebx	;ebx=2 - bind
	push dword 0	;IP(0.0.0.0)
	push word 0x8f8f	;PORT
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
	call printReg
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
	call printReg
	mov [client],eax
	add esp,12
	ret

_read:
	xor eax,eax
	mov ebx,[client]
	mov ecx,buffer
	mov edx,bufflen
	int 0x80
	call printReg
	mov [read_count],eax
	ret

_echo:
	xor eax,eax
	inc eax
	mov ebx,[client]
	mov ecx,buffer
	mov edx,[read_count]
	int 0x80
	call printReg
	ret

_close_socket:
	xor eax,eax
	times 3 inc eax
	mov ebx,[client]
	int 0x80
	call printReg
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
