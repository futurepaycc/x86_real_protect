boot_1:
	nasm -f bin boot_1.asm -o bin/boot_1.bin
	dd if=bin/boot_1.bin of=bin/boot_1.img bs=512 count=1
	qemu-system-i386 -drive file=bin/boot_1.img,format=raw

boot_1_debug:
	nasm -g -F dwarf -felf32 boot_1.asm -o bin/boot_1.o 
	i686-elf-ld -m elf_i386 -N -e boot -Ttext 0x7c00 -o bin/boot_1.bin bin/boot_1.o --oformat binary 

	dd if=bin/boot_1.bin of=bin/boot_1.img bs=512 count=1
	qemu-system-i386 -drive file=bin/boot_1.img,format=raw


boot_2:
	nasm -f bin boot_2.asm -o bin/boot_2.bin
	dd if=bin/boot_2.bin of=bin/boot_2.img bs=512 count=1
	qemu-system-i386 -drive file=bin/boot_2.img,format=raw

boot_2_debug:
	nasm -g -F dwarf -felf32 boot_2.asm -o bin/boot_2.o 
	i686-elf-ld -m elf_i386 -N -e boot -Ttext 0x7c00 -o bin/boot_2.bin bin/boot_2.o --oformat binary 

	dd if=bin/boot_2.bin of=bin/boot_2.img bs=512 count=1
	qemu-system-i386 -drive file=bin/boot_2.img,format=raw

# 下面ld链接错误, g++链接成功
boot_3_debug1:
	nasm -g -F dwarf -felf32 boot_3.asm -o bin/boot_3.o 

	#i686-elf-g++ -gdwarf -c -nostdlib -ffreestanding -std=c++11 -mno-red-zone -fno-exceptions -nostdlib -fno-rtti -Wall -Wextra -Werror kmain.cpp -o bin/kmain.o
	#i686-elf-ld -m elf_i386 -N -e boot -Tlinker.ld -o bin/boot_3.bin bin/boot_3.o bin/kmain.o --oformat binary 

	i686-elf-g++ -gdwarf -m32 kmain.cpp bin/boot_3.o -o bin/boot_3_kernel.bin -nostdlib -ffreestanding -std=c++11 -mno-red-zone -fno-exceptions -nostdlib -fno-rtti -Wall -Wextra -Werror -T linker.ld

	dd if=bin/boot_3_kernel.bin of=bin/boot_3.img bs=512 count=2
	qemu-system-i386 -drive file=bin/boot_3.img,format=raw

# FIXME 调试问题说明: boot_3中boot段名改为txt可以调试，蛤kmain.cpp又不可以调试了  => 算出kmain函数的物理地址
boot_3_debug2:
	nasm -g -F dwarf -felf32 boot_3.asm -o bin/boot_3.o 
	i686-elf-g++ -gdwarf -c -nostdlib -ffreestanding -std=c++11 -mno-red-zone -fno-exceptions -nostdlib -fno-rtti -Wall -Wextra -Werror kmain.cpp -o bin/kmain.o
	#这个不是kernel, 启作位置不在0x100000(1m)上, 甚至不是标准的elf文件, readelf, objdump都不能操作
	i686-elf-ld -m elf_i386 -N -e boot -Tlinker.ld -o bin/boot_3.elf bin/kmain.o bin/boot_3.o 
	i686-elf-ld -m elf_i386 -N -e boot -Tlinker.ld -o bin/boot_3.bin bin/kmain.o bin/boot_3.o --oformat binary 

	# 这时使用了2个扇区了，也能正常用
	dd if=bin/boot_3_kernel.bin of=bin/boot_3.img bs=512 count=2
	qemu-system-i386 -drive file=bin/boot_3.img,format=raw
