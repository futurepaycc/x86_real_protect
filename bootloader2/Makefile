all:
	nasm -F dwarf -felf32 boot.asm -o boot.o
	nasm -F dwarf -felf32 kernel.asm -o kernel.o
	i686-elf-gcc -static -m32 -ffreestanding -nostdlib -g -T linker.ld boot.o kernel.o -o mykernel.elf -lgcc
	qemu-system-i386 -kernel mykernel.elf
