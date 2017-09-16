all:
	nasm -f elf encrypt.s
	ld -m elf_i386 encrypt.o -o encrypt
	rm encrypt.o
