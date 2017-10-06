encrypt: encrypt.s
	nasm -f elf encrypt.s
	ld -m elf_i386 encrypt.o -o encrypt
substrsearch: substrsearch.s
	nasm -f elf substrsearch.s
	ld -m elf_i386 substrsearch.o -o substrsearch
