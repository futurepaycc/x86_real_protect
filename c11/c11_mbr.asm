section .text
global start
start:
         [bits 16]
         ;代码清单11-1
         ;文件名：c11_mbr.asm
         ;文件说明：硬盘主引导扇区代码 
         ;创建日期：2011-5-16 19:54

         ;设置堆栈段和栈指针: cs-> 代码段, ss-> 堆栈段, sp-> 栈指针
         mov ax,cs      
         mov ss,ax
         mov sp,0x7c00
      
         ;计算GDT所在的逻辑段地址,FIXME 下面就是手工link发生错误的地方 超越前缀访问： 间接寻址取值，从本代码段中取值，相当于高级语言的反射功能
         ; 参考: https://blog.csdn.net/for_cxc/article/details/89255194
         ; 应该考虑将gdt_base拆分成high,low两部分
         mov ax,[cs:gdt_base+0x7c00]        ;  取gdt_base的低16位 ;  mov ax,7e00h ;低16位  直接bin与ld对比|对: mov    ax,cs:0x7d0c          错: mov    ax,cs:0xf90c
         mov dx,[cs:gdt_base+0x7c00+0x02]   ;  取gdt_base的高16位 ;  mov dx,0000h ;高16位  直接bin与ld对比|对: mov    dx,WORD PTR cs:0x7d0e 错: mov    dx,WORD PTR cs:0xf90e

         mov bx,16                          ;
         div bx                             ; 线性地址 => 逻辑地址, 这个指令有点搞，目的是将ax除以16: 0x7e00 -> 0x7e0
         mov ds,ax                          ; 令DS指向该段以进行操作
         mov bx,dx                          ; 段内起始偏移地址 

     ;     ---------------------------------------------
     ;         gdt表定义
     ;     ---------------------------------------------
         ;创建0#描述符，它是空描述符，这是处理器的要求
         mov dword [bx+0x00],0x00
         mov dword [bx+0x04],0x00  

         ;创建#1描述符，保护模式下的代码段描述符, 本代码段本身: 长度为512, 基地址为0x7c00
         mov dword [bx+0x08],0x7c0001ff     
         mov dword [bx+0x0c],0x00409800     

         ;创建#2描述符，保护模式下的数据段描述符（NOTE:显示缓冲区直接当作数据段） 
         mov dword [bx+0x10],0x8000ffff     
         mov dword [bx+0x14],0x0040920b     

         ;创建#3描述符，保护模式下的堆栈段描述符: 向下减小方向至0x07a00
         mov dword [bx+0x18],0x00007a00      ;[段址前16|段长前16]
         mov dword [bx+0x1c],0x00409600      ;[8段址|4位属性|段长４位|8位属性|段址8位]

         ;初始化描述符表寄存器GDTR FIXME 代码内存地址: 0x7c56
         mov word [cs: gdt_size+0x7c00],31  ;描述符表的界限（总字节数减一）   ; mov    word [cs:0x7d07],0x1

     ;     ---------------------------------------------
     ;         gdt表使用
     ;     ---------------------------------------------
         lgdt [cs: gdt_size+0x7c00]         ; lgdt  [cs:0x7d07]
      
         in al,0x92                         ;南桥芯片内的端口 
         or al,0000_0010B
         out 0x92,al                        ;打开A20

         cli                                ;保护模式下中断机制尚未建立，应 
                                            ;禁止中断 
         mov eax,cr0
         or eax,1
         mov cr0,eax                        ;设置PE位
      
         ;以下进入保护模式... ...0x0008本代码段自身的选择子(写成了16进制)，flush是偏移
         jmp dword 0x0008:flush             ;16位的描述符选择子：32位偏移 ;    jmp    0x8:0x7b
                                            ;清流水线并串行化处理器 
         [bits 32] 
; 下面借助符号文件也无法段qemu点，强制会弄死vscode
; bochs内存断点位置: b 0x7c7e
    flush:
         mov cx,00000000000_10_0_00B         ;加载数据段选择子，[索引12位|全局本地1位|特权2位]加载数据段选择子(0x10)
         mov ds,cx

         ;移动数据进入数据段就会显示了，以下在屏幕上显示"Protect mode OK." 
         mov byte [0x00],'P'  
         mov byte [0x02],'r'
         mov byte [0x04],'o'
         mov byte [0x06],'t'
         mov byte [0x08],'e'
         mov byte [0x0a],'c'
         mov byte [0x0c],'t'
         mov byte [0x0e],' '
         mov byte [0x10],'m'
         mov byte [0x12],'o'
         mov byte [0x14],'d'
         mov byte [0x16],'e'
         mov byte [0x18],' '
         mov byte [0x1a],'O'
         mov byte [0x1c],'K'

         ;以下用简单的示例来帮助阐述32位保护模式下的堆栈操作 
         mov cx,00000000000_11_0_00B         ;加载堆栈段选择子
         mov ss,cx                           ;段选择子存入ss
         mov esp,0x7c00                      ;栈指针的初始位置存入esp

         mov ebp,esp                        ;保存堆栈指针 
         push byte '.'                      ;压入立即数（字节<->双字）
         
         sub ebp,4
         cmp ebp,esp                        ;判断压入立即数时，ESP是否减4 
         jnz ghalt                          ;不等就halt
         pop eax                            ;等就执行下面显示句点
         mov [0x1e],al                      ;显示句点 
      
  ghalt:     
         hlt                                ;已经禁止中断，将不会被唤醒 

;-------------------------------------------------------------------------------
          ;lgdt会加载下面６个字节
         gdt_size         dw 0              ;cs:反射时这里会写成31;db 字节, dw 字(两字节16位), dd 双字(4字节)
         gdt_base         dd 0x00007e00     ;GDT的物理地址 
                             
         times 510-($-$$) db 0              ; $当前行，$$当前段
                          db 0x55,0xaa