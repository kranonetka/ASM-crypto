encrypt:
	nasm -f elf encrypt.s
	ld -m elf_i386 encrypt.o -o encrypt
	@echo ********ENCRYPT STARTS********
	@./encrypt
	@rm encrypt.o encrypt
test:
	nasm -f elf test.s
	ld -m elf_i386 test.o -o test
	@./test
	@rm test.o test
