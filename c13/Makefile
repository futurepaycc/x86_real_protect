all:c13_mbr.asm
	nasm -f bin c13_mbr.asm -o mbr.bin
	nasm -f bin c13_core.asm -o core.bin
	nasm -f bin c13.asm -o c13.bin

	nasm -F dwarf -felf32 c13_mbr.asm -o c13_mbr.o
	# nasm -F dwarf -felf32 c13_core.asm -o c13_core.o #无法编译: 用了一些bin格式才支持的特殊指令
	# nasm -F dwarf -felf32 c13.asm -o c13.o 

	dd if=/dev/zero of=mbr.img count=10000
	dd if=mbr.bin of=mbr.img conv=notrunc
	dd if=core.bin of=mbr.img seek=1  conv=notrunc
	dd if=c13.bin of=mbr.img seek=50  conv=notrunc
	dd if=diskdata.txt of=mbr.img seek=100  conv=notrunc

bochs_debug:
	bochs \
		-qf /dev/null \
		'ata0-master: type=disk, path="mbr.img", mode=flat, cylinders=1, heads=1, spt=1' \
		'boot: disk' \
		'display_library: x' \
		'megs: 128'

run:
	qemu-system-i386 -drive file=mbr.img,format=raw

clean:
	rm -rf *.bin

# ==========================================================================
# 下面是debug源码的参考方式, nasm的bin模式调试就是恶梦
# ==========================================================================
debug: all_test3

debug_test1: 
	nasm -F dwarf -felf32 c13_mbr.asm -o c13_mbr.o 
	i686-elf-ld -m elf_i386 -N -e start -o c13_mbr.bin c13_mbr.o --oformat binary 

	# FIXME 只能 nasm c13_core.asm -o c13_core.o  编译， 但是下面链接又会出错
	nasm -F dwarf -felf32 c13_core.asm -o c13_core.o 
	i686-elf-ld -m elf_i386 -N -e start -o c13_core.bin c13_core.o --oformat binary 
	
	nasm -F dwarf -felf32 c13.asm -o c13.o 
	i686-elf-ld -m elf_i386 -N -e start -o c13.bin c13.o --oformat binary 


	dd if=/dev/zero of=mbr.img count=10000
	dd if=mbr.bin of=mbr.img conv=notrunc
	dd if=core.bin of=mbr.img seek=1  conv=notrunc
	dd if=c13.bin of=mbr.img seek=50  conv=notrunc
	dd if=diskdata.txt of=mbr.img seek=100  conv=notrunc



