bits 16
; org 0x7c00
section .text
global boot

; 使用bios功能打开A20地直线
boot:
	mov ax, 0x2401
	int 0x15
	mov ax, 0x3
	int 0x10
	cli
	lgdt [gdt_pointer] ; 从下面加载gdt_pointer指针到寄存器
	mov eax, cr0
	or eax,0x1
	mov cr0, eax
	jmp CODE_SEG:boot2
gdt_start:
	dq 0x0
; 《从实到保护模式:201》
gdt_code:
	dw 0xFFFF       ;段长前16位/20
	dw 0x0			;段址前16位/32
	db 0x0			;段址第3字节:16-24/32
	db 10011010b	;小4位为type属性,从[可执行,非特权依从，可读，未访问]，5位为段类型: 0->系统段,1->数据段|代码段, 6,7位特权级别: 00最高特权,8位: 段是否在内存存在
	db 11001111b	;小4位为段长后4位/20,5位avl无定义,6位:64位处理器保留, 7位: 默认栈指针(操作数:兼容模拟16位)大小-> 0->16位,1->32位 ,8位粒度: 0->字节，1->4k
	db 0x0			;段址第4字节:24-32/32
gdt_data:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10010010b 	;小4位type属性与代码段不同: [不可执行，向上扩展，可写，未访问]
	db 11001111b
	db 0x0
gdt_end:
gdt_pointer:
	dw gdt_end - gdt_start
	dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

bits 32
boot2:
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov esi,hello
	mov ebx,0xb8000	;保护模式下也可以访问bios文本显示系统, 这里断点可以逐字显示
.loop:
	lodsb
	or al,al
	jz halt
	or eax,0x0100
	mov word [ebx], ax
	add ebx,2
	jmp .loop
halt:
	cli
	hlt
hello: db "this is my own mbr!",0

times 510 - ($-$$) db 0
dw 0xaa55
