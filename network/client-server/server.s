;Создать сокет eax=102, ebx=1 - int socket(int domain, int type, int protocol)
;сокет сохранить
;Забиндить сокет eax=102, ebx=2 - int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
;Начать слушать eax=102, ebx=4 - int listen(int sockfd, int backlog)
global _start
section .data
	socket_args:
		dd 2	;PF_INET 
		dd 1	;SOCK_STREAM
		dd 0 	;0
	bind_args:
		.socket_fd: resd 0
		.sockaddr:
			dw 2	;INET
			dw 0x8f8f	;PORT
			dd 0	;IP(0.0.0.0)
			times 2 dd 0	;gap
		.bind_args_size:
			dd 16	;sockaddr size
	listen_args:
		.socket_fd: dd 0
		.queue_size: dd 5
section .text:
_start:
	mov eax,102	;sys_socketcall
	xor ebx,ebx
	inc ebx		;1 - int socket(int domain, int type, int protocol)
	mov ecx,socket_args	;socket args
	int 0x80
	call printReg
	mov [bind_args.socket_fd],eax	;save socket descriptor
	mov [listen_args.socket_fd],eax

	mov eax,102	;sys_socketcall
	inc ebx	;2 - int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
	mov ecx,bind_args	;bind args
	int 0x80	;bind socket
	call printReg

	mov eax,102
	times 2 inc ebx	;4 - int listen(int sockfd, int backlog)
	mov ecx,listen_args
	int 0x80
	call printReg
	
	xor eax,eax
	inc eax	;sys_exit
	xor ebx,ebx	;err_code == 0
	int 0x80

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
