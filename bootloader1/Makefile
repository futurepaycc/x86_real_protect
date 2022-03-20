all:
	nasm boot1.asm -o boot1.bin
	dd if=boot1.bin of=boot1.img bs=512 count=1
	qemu-system-i386 -drive file=boot1.img,format=raw 
