;Created			:	16-02-2025
;Last Update			:	17-02-2025
;Description			:	A program for converting stdin ASCII characters to uppercase.NASM 2.14.02
;Make				:	uppercaserv2: uppercaserv2.o
;				:		ld -o uppercaserv2 uppercaserv2.o
;				:	uppercaserv2.o: uppercaserv2.asm
;				:		nasm -f elf64 -g -F dwarf uppercaserv2.asm
;Architecture			:	X86-64
;CPU				:	Intel® Core™2 Duo CPU T6570 @ 2.10GHz × 2


SECTION .bss			;	Section containing uninitialised data

	BUFFLEN EQU 256		;	Lenght of buffer
	BUFF: RESB BUFFLEN 	;	Text buffer

SECTION .data			;	Section containing initialised data

SECTION .text			;	Section containing code

	global _start		;	Linker entry point

	_start:
		MOV RBP,RSP	;	Debugging allowance

;Read a buffer full of text from stdin:

		READ:
			MOV RAX,0	;Specify sys_raed call
			MOV RDI,0	;stdin fd into rdi
			MOV RSI,BUFF	;Pass *offset* of buffer to read *to*
			MOV RDX,BUFFLEN	;Pass # of bytes to read on a single pass
			SYSCALL		;Call sys_read, at ring 0 ,to fill the buffer

			MOV R12,RAX	;sys_read returns the number of bytes read through rax!
			CMP RAX,0	;If rax = 0, EOF was reached by sys_read on stdin
			JE DONE

;Set up registers for buffer step.
;
;			MOV RBX,RAX	;Place the # of bytes read into rbx
;			MOV R13,BUFF	;Place addy of buffer into r13
;			DEC R13		;Adjust count to offest (i.e avoid off by one error)

;Go through the buffer and convert characters to uppercase

;		SCAN:
;			CMP BYTE [R13+RBX],0X61	;Test char against 'a'
;			JB .NEXT		;If below 'a' in ASCII, not lowercase
;			CMP BYTE [R13+RBX],0X7A	;Test char against 'z'
;			JA .NEXT		;If above 'z' in ASCII, not lowercase
;Thus we have filtered for lowercase chars:

;			SUB BYTE [R13+RBX],0X20	;Subtract 0x20 to give upper case

;		.NEXT:
;			DEC RBX			;Decrement counter
;			CMP RBX,0
;			JNZ SCAN		;Loopback for remaining chars

;Write buffer full of processed text to stdout

;Setup registers for the process buffer step

			MOV RBX,RAX
			MOV R13,BUFF
;			DEC R13

;Go through the buffer and convert lowercase chars to uppercase chars

		SCAN:
			CMP BYTE [R13-1+RBX],61H
			JB  NEXT
			CMP BYTE [R13-1+RBX],7AH
			JA  NEXT

			SUB BYTE [R13-1+RBX],20H

		NEXT:
			DEC RBX
			JNZ SCAN


		WRITE:
			MOV RAX,1		;Specify sys_write call
			MOV RDI,1		;Specify stdout fd
			MOV RSI,BUFF		;Pass offset of the buffer
			MOV RDX,R12		;Pass # of bytes of data in the buffer
			SYSCALL			;Make kernel call
			JMP READ		;Loop back and load another buffer full

;It is done (Dune Herald of the change voice)

		DONE:
			MOV RAX, 60		; 60 = EXIT THE PROGRAM
			MOV RDI,0		; RETURN VALUE
			SYSCALL			; AUF WIEDERSEHEN
