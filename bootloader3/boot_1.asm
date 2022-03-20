bits 16
; org 0x7c00
section .text
global boot

boot:
	mov si,hello ;移动到栈
	mov ah, 0x0e
.loop:
	lodsb
	or al,al
	jz halt
	int 0x10
	jmp .loop ;这里断点，逐字打印，用的bios中断显示
halt:
	cli
	hlt
hello: db "Hello world!",0

times 510 - ($-$$) db 0
dw 0xaa55
