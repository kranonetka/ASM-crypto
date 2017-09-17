global _start
section .data
	filename: db "filename: "
	filename_len: equ $-filename
	printCount: dw 95
section .bss
	descriptor: resb 4
	buffer: resb 4096
	buffer_size: equ $-buffer
	key: resb 80
	key_size equ $-key
section .text
_start:
	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,filename
	mov edx,filename_len
	int 0x80	;print("filename: ")

	xor eax,eax
	times 3 inc eax	;eax = 3 (read)
	xor ebx,ebx	;0 - keyboard
	mov ecx,buffer	;to buffer
	mov edx,buffer_size	;4Kb
	int 0x80	;read 4Kb from keyboard to buffer
	and byte [buffer+eax-1],0	;replaces 'enter' to '\0'

	mov eax,5 	;open file
	mov ebx,buffer	;filename
	xor ecx,ecx	;0 - read only
	int 0x80

	test eax,eax
	js err_open	;eax<0 - error

	mov [descriptor],eax ;save file descriptor
	
	xor eax,eax
	times 3 inc eax ;eax = 3(read)
	mov ebx,[descriptor]
	mov ecx,buffer	;read to buffer
	mov edx,buffer_size	;4Kb
	int 0x80 ;read 4Kb from file to buffer

	test eax,eax
	js err_read
	
	mov edx,eax
	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,buffer
	;dec edx
	int 0x80
	
	mov eax,6
	mov ebx,[descriptor]
	int 0x80

	call exit

section .data
	err_open_msg: db "ERROR OPENING FILE",10,0
	err_open_len: equ $-err_open_msg
	err_read_msg: db "ERROR READING FILE",10,0
	err_read_len: equ $-err_read_msg
section .text
err_open:
	mov eax,4
	xor ebx,ebx
	inc ebx
	mov ecx,err_open_msg
	mov edx,err_open_len
	int 0x80
	call exit
err_read:
	mov eax,4
	mov ebx,1
	mov ecx,err_read_msg
	mov edx,err_read_len
	int 0x80
	mov eax,6
	mov ebx,[descriptor]
	int 0x80
exit:
	xor eax,eax
	inc eax
	xor ebx,ebx
	int 0x80
