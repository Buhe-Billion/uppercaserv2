uppercaserv2: uppercaserv2.o
	ld -o uppercaserv2 uppercaserv2.o
uppercaserv2.o: uppercaserv2.asm
	nasm -f elf64 -g -F dwarf uppercaserv2.asm
