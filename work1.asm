data segment                                ;数据段
    number      db 'Zero $One $Two $Three $Four $Five $Six $Seven $Eight $Nine $'
    Big_letter  db 'Apple $Banana $Cake $Dessert $Egg $Fig $Grape $Honey $Icecream $Juice $Kiwi $Lemon $Mango $Nut $Orange $Peach $Quarenden $Radish $Strawberry $Tangerine $Udon $Veal $Watermelon $Xacuti $Yam $Zucchini $'
    Sma_letter  db 'apple $banana $cake $dessert $egg $fig $grape $honey $icecream $juice $kiwi $lemon $mango $nut $orange $peach $quarenden $radish $strawberry $tangerine $udon $veal $watermelon $xacuti $yam $zucchini $'
    myid  db 'ID:1900013100 $'              ;姓名和学号           
    myname db 'NAME:Wan Chengzhi $'
    ;下面记录了数字和大小写字母字符串相对应的偏移，需要人工进行计数
    number_off  dw 0, 6, 11,16, 23, 29, 35, 40, 47, 54                          
    big_off  dw 0, 7, 15, 21, 30, 35, 40, 47, 54, 64, 71, 77, 84, 91, 96, 104 , 111, 122 , 130 , 142,153,159,165,177,185,190,200
    small_off  dw 0, 7, 15, 21, 30, 35, 40, 47, 54, 64, 71, 77, 84, 91, 96, 104 , 111, 122 , 130 ,142, 153,159,165,177,185,190,200
    sp1 db 'Spark $'                        ;对于这三种符号采用特殊处理的方案
    sp2 db 'At $'
    sp3 db 'And $'
    
data ends

stack segment stack                     ;堆栈段
    sta db 50 dup(?)
    top equ length sta
stack ends                              ;堆栈段结束

code segment
    assume CS:code, DS:data, SS:stack

    begin:  mov ax,data                 ;一些赋值和初始化工作
            mov ds,ax
            mov ax,stack
            mov ss,ax
            mov ax,top
            mov sp,ax

    keyboard: 
            mov ah,07H
            int 21h

            cmp al, 1bH                 ;将输入与esc进行比较
            je  stop                    ;如果相等，转跳至stop，否则进行如下处理

    handle: cmp al,'*'
            je  Spark_handle
            cmp al,'&'
            je  And_handle
            cmp al,'@'
            je  At_handle
            cmp al, '9'                 ;与9进行比较，小于则进入数字比较
            jle number_handle
            cmp al, 'Z'                 ;与大写Z进行比较，小于则属于大写字母
            jle big_handle
            cmp al, 'z'                 ;与小写z进行比较，小于则属于小写字母
            jle small_handle

            jmp others

    Spark_handle:                       ;这下面是三种特殊字符情况的分析，‘*’情况
            mov dx,offset sp1
            mov ah,09H
            int 21h
            jmp keyboard

    And_handle:
            mov dx,offset sp3            ;该部分为‘&’情况
            mov ah,09H
            int 21h
            jmp keyboard

    At_handle:
            mov dx,offset sp2             ;该部分为‘@’情况
            mov ah,09H
            int 21h
            jmp keyboard
            
    number_handle: 
            cmp al, 30H
            jl others
            mov cx, 0AH             ;由于数字共计十个，故而cx赋值为10，采用偏移查询的方法
    number_loop: 
            dec cx
            js others
            mov dx, 30H
            add dx, cx
            cmp al, dl
            jne number_loop

            mov ax, cx
            add ax, ax
            mov bx, offset number_off
            add bx, ax
            mov ax, [bx]
            mov dx, offset number   ;进行相关输出
            add dx, ax              
            mov AH, 09H
            int 21H
            jmp keyboard

    big_handle:  
            cmp al, 'A'             ;与‘A'进行比较，小于则说明是其他字符
            jl others
            mov cx, 1BH
    big_loop:   
            dec cx                 ;由于字母表共26个字母，故而给cx赋值1bh
            js others
            mov dx, 41H
            add dx, cx
            cmp al, dl
            jne big_loop
            mov ax, cx
            add ax, ax
            mov bx, offset big_off
            add bx, ax
            mov ax, [bx]
            mov dx, offset Big_letter
            add dx, ax
            mov AH, 09H
            int 21H
            jmp keyboard

    small_handle: 
            cmp al, 'a'             ;与小写a进行比较，小于则说明是其他字符
            jl others
            mov cx, 1BH

    small_loop:    
            dec cx                  ;由于字母表共26个字母，故而给cx赋值1bh,采用偏移方法进行查询
            js others
            mov dx, 61H
            add dx, cx
            cmp al, dl
            jne small_loop      
            mov ax, cx
            add ax, ax
            mov bx, offset small_off    
            add bx, ax
            mov ax, [bx]
            mov dx, offset Sma_letter
            add dx, ax
            mov ah, 09H
            int 21H
            jmp keyboard

    others:                         ;最终的特殊情况，对于其他字符的输出
            mov dl, '?'
            mov ah, 02H
            int 21h
            jmp keyboard

    stop:       
            mov dl,0dh                  ;输出回车
            mov ah,2
            int 21h
            mov dl,0ah                  ;输出换行
            mov ah,2
            int 21h 

            mov dx,offset myid          ;显示学号
            mov ah,09h  
            int 21h

            mov dl,0dh                  ;输出回车
            mov ah,2
            int 21h
            mov dl,0ah                  ;输出换行
            mov ah,2
            int 21h
            mov dx,offset myname        ;显示姓名
            mov ah,09h  
            int 21h

            mov ax,4c00h                ;带返回码结束，al=返回码
            int 21h

code ends
    end begin