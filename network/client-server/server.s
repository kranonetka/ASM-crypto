;Создать сокет(вызов функции сокета 102(1,семейство адресов,протокол(4 байта), транспортный протокол==1, 0)
;сокет сохранить
;bind функция (номер сокета;адрес памяти, где хранится локальный адрес(16 байт) первые 2: тип сети(2), 2 байта:номер порта(программы),IP адрес(на сервере 0.0.0.0); число 16(размер сетевого адреса))
;функция listen(дескриптор сокета, размер очереди(3 или 5)) 
global _start
section .data
	socket_args:
		dd 2	;PF_INET 
		dd 1	;SOCK_STREAM
		dd 0 	;0
	bind_args:
		socket: resd 0
		sockaddr:
			dw 2	;sa_family - ????
			db 0xaa, 0xaa	;port
			db 0, 0, 0, 0	;IP(0.0.0.0)
			dd 16	;sockaddr_size
section .bss
section .text
_start:
	mov eax,102	;sys_socketcall
	xor ebx,ebx
	inc ebx		;socket
	mov ecx,socket_args	;args
	int 0x80
	mov [socket],eax	;socket descriptor at socket

	mov eax,102	;sys_socketcall
	inc ebx	;2 - bind
	mov ecx,bind_args	;args
	int 0x80

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
