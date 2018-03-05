server: server.s
	nasm -f elf server.s
	ld -m elf_i386 server.o -o server
	@echo ===Server compiled===
client: client.s
	nasm -f elf client.s
	ld -m elf_i386 client.o -o client
	@echo ==Client compiled===
all: server client
	@echo ===All compiled===
