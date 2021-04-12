data segment                             ;数据段
    buf db 81                            ;缓冲区，这里意味着最高可以接受81字符长的字符串
        db 0    
    string db 81 dup(0)
    myid  db 'ID:1900013100 $'            ;姓名和学号           
    myname db 'NAME:Wan Chengzhi $'
    success db 'Last position : $'        ;一些关于查找成功与否的提示
    failure db 'Sorry!$'
    num		db '00 $'                   ;用于暂时存个数字
    count   db '00 $'
data ends                               ;数据段结束

stack segment stack                     ;堆栈段
    sta db 50 dup(?)
    top equ length sta

stack ends                              ;堆栈段结束

code segment                            ;代码段
    assume cs:code, ds:data, ss:stack
    begin:  mov ax,data
            mov ds,ax                   ;为ds赋
            mov ax,data
            mov es,ax                   ;为es赋值
            mov ax,stack
            mov ss,ax                   ;为ss赋值
            mov ax,top
            mov sp,ax                   ;为sp赋值

            mov dx,offset buf           ;从键盘输入字符串进入缓冲区       
            mov ah,0ah
            int 21h

            mov dl,0dh                  ;输出回车
            mov ah,2
            int 21h

            mov dl,0ah                  ;输出换行
            mov ah,2
            int 21h

    getkeyboard:

            mov ah,01h                  ;键盘输入字符
            int 21h
            mov cl,al
            mov dl,0dh                  ;输出回车
            mov ah,2
            int 21h

            mov dl,0ah                  ;输出换行
            mov ah,2
            int 21h

            cmp cl,1bh                  ;比较输入和esc
            jne handle
            jmp  stop                    ;如果是esc，则直接进入结束阶段
                                         ;如果不是，则进入处理阶段
    handle:
            mov al,cl
            mov di,offset string
            mov bx,offset buf
            inc bx
            mov cl,BYTE PTR[bx]
            mov ch,0h                   ;获取字符串长度存储在CX当中

            lea si,string

    cmp_loop:                           ;该部分用于统计该特定字符在字符串中出现的次数
            cmp al,[si]
            je cmp_handle
            dec cx
            inc si
            cmp cx,0                    ;cx=0时停止比较操作
            jg cmp_loop
            cmp bx,1                    ;如果bx>1则说明确实存在该字符串进行跳转
            jg exist
            jmp print_fail

    cmp_handle:                         ;这是两者不相等时的情况，区别在于bx没有增加，其余于以上保持一致
            dec cx
            inc si
            inc bx
            cmp cx,0                
            jge cmp_loop
            cmp bx,1
            jg exist
            jmp print_fail

    exist:
            mov dx,bx
            dec dx
            mov bl,al

    mod10_handle1:                       ;注意到由于本题中字符串位置可能超过10情况，一旦超过10，单次输出无法表示，故而采用模10方式加以解决
            cmp dx,09h
            jg  mod101
            add dx,30h
            mov ah,02H
            int 21H
            mov dl,0dh                  ;输出回车
            mov ah,2
            int 21h
            mov dl,0ah                  ;输出换行
            mov ah,2
            int 21h 
            jmp print_suc

    mod101:                             ;为了应对出现次数过多的极端情况，故而和采用了mod10的方法，该思路与下部分保持一致，由于这里是最后写的，所以注释参考位置的mod10注释即可
            mov ax,dx
            mov si,02d
            mov cl,10d
            
    mod10_loop1:
		    div cl
		    dec si
		    add ah, 30h
		    mov ds:[count + si], ah
		    mov ah, 00h
		    cmp al, 0
		    jnz mod10_loop1
		
		    mov dx, offset count
		    add dx, si
		    mov ah, 09h
		    int 21h
            mov dl,0dh                  ;输出回车
            mov ah,2
            int 21h
            mov dl,0ah                  ;输出换行
            mov ah,2
            int 21h 
            

    print_suc:
            mov al,bl
            mov di,offset string
            mov bx,offset buf
            inc bx
            mov cl,BYTE PTR[bx]
            mov ch,0h
            add di,cx
            std
            repne scasb

            mov dx,offset success       ;显示提示成功相关信息
            mov ah,09H
            int 21h

            mov dx,[bx]                 ;为了能够使用串扫描操作检索最后一个位置，这里采用的方法是在字符串初始位置加上字符串长度的偏移
            sub dx,cx                   ;然后使用了repne scasb指令进行进行扫描，注意在第143行使用了std进行反向操作，故而能够搜索到
            dec dx                      ;故而能够检索到该字符串最后一次出现的位置，然后借助CX和字符串长度等数据来计算位置
            add dx,30h
            mov ax,[bx]
            sub ax,dx
            mov dx,ax
            add dx,30h
            inc dx
            mov cl,10d
    mod10_handle:                       ;注意到由于本题中字符串位置可能超过10情况，一旦超过10，单次输出无法表示，故而采用模10方式加以解决
            cmp dx,09h
            jle  output
            mov ax,dx
            mov si,02d                  ;由于buf大小限制为81，故而最多为两位数，所以在此位数最多为2
    mod10_loop:                     
		    div cl
		    dec si
		    add ah, 30h             
		    mov ds:[num + si], ah       ;改变num中的相应位置字符串，待更改完毕之后便进行输出
		    mov ah, 00h
		    cmp al, 0                   ;当商为0时那么该操作停止
		    jnz mod10_loop
		
		    mov dx, offset num          ;进行相关的输出
		    add dx, si
		    mov ah, 09h
		    int 21h
            mov dl,0dh                  ;输出回车
            mov ah,2
            int 21h
            mov dl,0ah                  ;输出换行
            mov ah,2
            int 21h 
            jmp getkeyboard
        
    output:    
            add dx,30h                   ;对于位置为1-9情况，此时不需要进行模10除法，直接输出即可
            mov ah,02H
            int 21H

            mov dl,0dh                  ;输出回车
            mov ah,2
            int 21h
            mov dl,0ah                  ;输出换行
            mov ah,2
            int 21h

            jmp getkeyboard

    print_fail:
            mov dx,offset failure       ;显示提示失败相关信息
            mov ah,09H
            int 21h
            
            mov dl,0dh                  ;输出回车
            mov ah,2
            int 21h
            mov dl,0ah                  ;输出换行
            mov ah,2
            int 21h 

            jmp getkeyboard

    stop:   mov dx,offset myid          ;显示学号
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
    end begin                           ;程序结束

