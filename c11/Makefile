all: 
# 这里不用orig指令也行
	nasm -f bin c11_mbr.asm -o c11_mbr_1.bin  
	nasm -F dwarf -felf32 c11_mbr.asm -o c11_mbr_1.o 

	dd if=/dev/zero of=c11_mbr_1.img count=1
	dd if=c11_mbr_1.bin of=c11_mbr_1.img conv=notrunc
	# qemu-system-i386 -drive file=c11_mbr_1.img,format=raw

clean:
	rm -rf *.bin *.img *.o

# ==========================================================================
# 因为代码中cs:超越前缀寻址的的问题，下面的手工链接出现了地址问题
# ==========================================================================
test1: 
	nasm -F dwarf -felf32 c11_mbr.asm -o c11_mbr_2.o 
	i686-elf-ld -m elf_i386 -N -e start -Ttext 0x7c00 -o c11_mbr_2.bin c11_mbr_2.o --oformat binary 

	# dd if=/dev/zero of=c11_mbr_2.img count=1
	# dd if=c11_mbr_2.bin of=c11_mbr_2.img conv=notrunc
	# # qemu-system-i386 -drive file=c11_mbr_2.img,format=raw

