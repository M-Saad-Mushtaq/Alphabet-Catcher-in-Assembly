[org 0x0100] 
jmp start 

oldisr : dd 0
oldisr1 : dd 0
boxpos : dw 3920
score: dw 0
deaths: dw 0
total: dw 0
s1: times 10 dw 0
s1size: dw 0
s1pos: times 10 dw 0
s2: times 10 dw 0
s2size: dw 0
s2pos: times 10 dw 0
s3: times 10 dw 0
s3size: dw 0
s3pos: times 10 dw 0
s4: times 10 dw 0
s4size: dw 0
s4pos: times 10 dw 0
s5: times 10 dw 0
s5size: dw 0
s5pos: times 10 dw 0
speed1: dw 33
speed2: dw 23
speed3: dw 19
speed4: dw 15
speed5: dw 7

newgen: dw 8


rand: dw 0
randnum: dw 0

tickcount: dw 0



timeisr: pusha

	inc word [cs:tickcount]; increment tick count

	mov ax , [tickcount]
	mov cx , [newgen]
	mov dx , 0
	div cx

	
	

	call catcheds1

	cmp dx , 0
	jne move1

	genrate:
		call generateAlpha
	
	move1:
		mov ax , [tickcount]
		mov cx , [speed1]
		mov dx , 0
		div cx

		cmp dx , 0
		jne scond2

	scond1:
		
		call s1disp
		jmp timeisrRet
	scond2:
		mov ax , [tickcount]
		mov cx , [speed2]
		mov dx , 0
		div cx

		cmp dx , 0
		jne scond3
		
		call s2disp
		jmp timeisrRet
	scond3:
		mov ax , [tickcount]
		mov cx , [speed3]
		mov dx , 0
		div cx

		cmp dx , 0
		jne scond4
		
		call s3disp
	
		jmp timeisrRet
	scond4:
		mov ax , [tickcount]
		mov cx , [speed4]
		mov dx , 0
		div cx

		cmp dx , 0
		jne scond5
		
		call s4disp

		jmp timeisrRet
	scond5:
		mov ax , [tickcount]
		mov cx , [speed5]
		mov dx , 0
		div cx

		cmp dx , 0
		jne timeisrRet
		
		call s5disp

timeisrRet:
	mov ah , 0
	mov al, 0x20
	out 0x20, al ; end of interrupt
	popa
	iret ; return from interrupt


printnum: push bp
	mov bp, sp
	push es
	push ax
	push bx
	push cx
	push dx
	push di
	mov ax, 0xb800
	mov es, ax ; point es to video base
	mov ax, [bp+4] ; load number in ax
	mov bx, 10 ; use base 10 for division
	mov cx, 0 ; initialize count of digits
nextdigit: mov dx, 0 ; zero upper half of dividend
	div bx ; divide by 10
	add dl, 0x30 ; convert digit into ascii value
	push dx ; save ascii value on stack
	inc cx ; increment count of values
	cmp ax, 0 ; is the quotient zero
	jnz nextdigit ; if no divide it again
	mov di, 14 ; point di to 70th column
nextpos: pop dx ; remove a digit from the stack
	mov dh, 0x07 ; use normal attribute
	mov [es:di], dx ; print char on screen
	add di, 2 ; move to next screen location
	loop nextpos ; repeat for all digits on stack
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	pop bp
	ret 2

printnum1: push bp
	mov bp, sp
	push es
	push ax
	push bx
	push cx
	push dx
	push di
	mov ax, 0xb800
	mov es, ax ; point es to video base
	mov ax, [bp+4] ; load number in ax
	mov bx, 10 ; use base 10 for division
	mov cx, 0 ; initialize count of digits
nextdigit1: mov dx, 0 ; zero upper half of dividend
	div bx ; divide by 10
	add dl, 0x30 ; convert digit into ascii value
	push dx ; save ascii value on stack
	inc cx ; increment count of values
	cmp ax, 0 ; is the quotient zero
	jnz nextdigit1 ; if no divide it again
	mov di, 36 ; point di to 70th column
nextpos1: pop dx ; remove a digit from the stack
	mov dh, 0x07 ; use normal attribute
	mov [es:di], dx ; print char on screen
	add di, 2 ; move to next screen location
	loop nextpos1 ; repeat for all digits on stack
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	pop bp
	ret 2



; taking n as parameter, generate random number from 0 to n nad return in the stack
randG:
	push bp
	   mov bp, sp
	   pusha
	   cmp word [rand], 0
	   jne next

	  mov ah, 00h   ; interrupt to get system timer in CX:DX 
	  int 1ah
	  inc word [rand]
	  mov [randnum], dx
	  jmp next1

  next:
	  mov ax, 25173          ; LCG Multiplier
	  mul word  [randnum]     ; DX:AX = LCG multiplier * seed
	  add ax, 13849          ; Add LCG increment value
	  ; Modulo 65536, AX = (multiplier*seed+increment) mod 65536
	  mov [randnum], ax          ; Update seed = return value

 next1:xor dx, dx
	 mov ax, [randnum]
	 mov cx, [bp+4]
	 inc cx	
	 div cx
 
	 mov [bp+6], dx
	 popa
	 pop bp
	 ret 2


catcheds1:
	pusha
	push 0xb800
	pop es

	
	
	mov bx , 0
	cmp word [s1size] , 0
	je gotocatcheds1Ret2
	mov ax , [s1size]
	jmp loop2
	gotocatcheds1Ret2:
		jmp catcheds1Ret
	
	loop2:
		mov ax , bx
		mov dx , [s1pos + bx]
		mov cx , [boxpos]
		;add dx , 160
		mov di , dx
		cmp cx , di
		je catch
		cmp dx , 3998
		jbe cond2
		mov word [es:di-160] , 0x0720
		add word [deaths] , 1
		jmp loop3
		
		catch:
			mov word [es:di-160] , 0x0720
			mov si , [boxpos]
			mov word [es : si], 0x07DC
			add word [score] , 1
		
		loop3:
			mov dx , [s1pos + bx + 2]
			mov [s1pos + bx] , dx
			mov cx , [s1 + bx + 2]
			mov [s1 + bx] , cx
	
		cond3:
			add bx , 2
			cmp bx , [s1size]
			jne loop3

		sub word [s1size] , 2
		sub word [total] , 1
		mov bx , ax
			
	cond2:
		add bx , 2
		cmp bx , [s1size]
		jbe loop2

	mov bx , 0
	cmp word [s2size] , 0
	je gotocatcheds1Ret1
	mov ax , [s2size]
	jmp loop4
	gotocatcheds1Ret1:
		jmp catcheds1Ret
	
	loop4:
		mov ax , bx
		mov dx , [s2pos + bx]
		mov cx , [boxpos]
		;sub cx , 160
		mov di , dx
		cmp cx , di
		je catch1
		cmp dx , 3998
		jbe cond4
		mov word [es:di-160] , 0x0720
		add word [deaths] , 1
		jmp loop5
		
		catch1:
			mov word [es:di-160] , 0x0720
			mov si , [boxpos]
			mov word [es : si], 0x07DC
			add word [score] , 1
		
		loop5:
			mov dx , [s2pos + bx + 2]
			mov [s2pos + bx] , dx
			mov cx , [s2 + bx + 2]
			mov [s2 + bx] , cx
	
		cond5:
			add bx , 2
			cmp bx , [s2size]
			jne loop5

		sub word [s2size] , 2
		sub word [total] , 1
		mov bx , ax
			
	cond4:
		add bx , 2
		cmp bx , [s2size]
		jbe loop4

	mov bx , 0
	cmp word [s3size] , 0
	je gotocatcheds1Ret
	mov ax , [s3size]
	jmp loop7
	gotocatcheds1Ret:
		jmp catcheds1Ret
	
	loop7:
		mov ax , bx
		mov dx , [s3pos + bx]
		mov cx , [boxpos]
		;sub cx , 160
		mov di , dx
		cmp cx , di
		je catch2
		cmp dx , 3998
		jbe cond7
		mov word [es:di-160] , 0x0720
		add word [deaths] , 1
		jmp loop8
		
		catch2:
			mov word [es:di-160] , 0x0720
			mov si , [boxpos]
			mov word [es : si], 0x07DC
			add word [score] , 1
		
		loop8:
			mov dx , [s3pos + bx + 2]
			mov [s3pos + bx] , dx
			mov cx , [s3 + bx + 2]
			mov [s3 + bx] , cx
	
		cond8:
			add bx , 2
			cmp bx , [s3size]
			jne loop8

		sub word [s3size] , 2
		sub word [total] , 1
		mov bx , ax
			
	cond7:
		add bx , 2
		cmp bx , [s3size]
		jbe loop7

	mov bx , 0
	cmp word [s4size] , 0
	je gotocatcheds1Ret
	mov ax , [s4size]
	
	loop9:
		mov ax , bx
		mov dx , [s4pos + bx]
		mov cx , [boxpos]
		;sub cx , 160
		mov di , dx
		cmp cx , di
		je catch3
		cmp dx , 3998
		jbe cond9
		mov word [es:di-160] , 0x0720
		add word [deaths] , 1
		jmp loop10
		
		catch3:
			mov word [es:di-160] , 0x0720
			mov si , [boxpos]
			mov word [es : si], 0x07DC
			add word [score] , 1
		
		loop10:
			mov dx , [s4pos + bx + 2]
			mov [s4pos + bx] , dx
			mov cx , [s4 + bx + 2]
			mov [s4 + bx] , cx
	
		cond10:
			add bx , 2
			cmp bx , [s4size]
			jne loop10

		sub word [s4size] , 2
		sub word [total] , 1
		mov bx , ax
			
	cond9:
		add bx , 2
		cmp bx , [s4size]
		jbe loop9

	mov bx , 0
	cmp word [s5size] , 0
	je gotocatcheds1Ret
	mov ax , [s5size]
	
	loop11:
		mov ax , bx
		mov dx , [s5pos + bx]
		mov cx , [boxpos]
		;sub cx , 160
		mov di , dx
		cmp cx , di
		je catch4
		cmp dx , 3998
		jbe cond11
		mov word [es:di-160] , 0x0720
		add word [deaths] , 1
		jmp loop12
		
		catch4:
			mov word [es:di-160] , 0x0720
			mov si , [boxpos]
			mov word [es : si], 0x07DC
			add word [score] , 1
		
		loop12:
			mov dx , [s5pos + bx + 2]
			mov [s5pos + bx] , dx
			mov cx , [s5 + bx + 2]
			mov [s5 + bx] , cx
	
		cond12:
			add bx , 2
			cmp bx , [s5size]
			jne loop12

		sub word [s5size] , 2
		sub word [total] , 1
		mov bx , ax
			
	cond11:
		add bx , 2
		cmp bx , [s5size]
		jbe loop11


catcheds1Ret:
	popa
	ret





s1disp:
	pusha
	push 0xb800
	pop es

	mov cx , 0
	cmp cx , [s1size]
	je s1dispRet
	loops1:
		
		mov bx , cx
		mov si , [s1pos + bx]
		add si , 160
		mov [s1pos + bx] , si
		sub si , 160
		mov di , [s1 + bx]
		mov bx , di
		mov bh , 0x07
		
		mov [es:si] , bx
		mov word [es:si - 160] , 0x0720
		add cx , 2
		cmp cx , [s1size]
		jne loops1


s1dispRet:
	popa
	ret

s2disp:
	pusha
	push 0xb800
	pop es

	mov cx , 0
	cmp cx , [s2size]
	je s2dispRet
	loops2:
		
		mov bx , cx
		mov si , [s2pos + bx]
		add si , 160
		mov [s2pos + bx] , si
		sub si , 160
		mov di , [s2 + bx]
		mov bx , di
		mov bh , 0x07
		
		mov [es:si] , bx
		mov word [es:si - 160] , 0x0720
		add cx , 2
		cmp cx , [s2size]
		jne loops2

s2dispRet:
	popa
	ret
s3disp:
	pusha
	push 0xb800
	pop es

	mov cx , 0
	cmp cx , [s3size]
	je s3dispRet
	loops3:
		
		mov bx , cx
		mov si , [s3pos + bx]
		add si , 160
		mov [s3pos + bx] , si
		sub si , 160
		mov di , [s3 + bx]
		mov bx , di
		mov bh , 0x07
		
		mov [es:si] , bx
		mov word [es:si - 160] , 0x0720
		add cx , 2
		cmp cx , [s3size]
		jne loops3

s3dispRet:
	popa
	ret
s4disp:
	pusha
	push 0xb800
	pop es

	mov cx , 0
	cmp cx , [s4size]
	je s4dispRet
	loops4:
		
		mov bx , cx
		mov si , [s4pos + bx]
		add si , 160
		mov [s4pos + bx] , si
		sub si , 160
		mov di , [s4 + bx]
		mov bx , di
		mov bh , 0x07
		
		mov [es:si] , bx
		mov word [es:si - 160] , 0x0720
		add cx , 2
		cmp cx , [s4size]
		jne loops4

s4dispRet:
	popa
	ret
s5disp:
	pusha
	push 0xb800
	pop es

	mov cx , 0
	cmp cx , [s5size]
	je s5dispRet
	loops5:
		
		mov bx , cx
		mov si , [s5pos + bx]
		add si , 160
		mov [s5pos + bx] , si
		sub si , 160
		mov di , [s5 + bx]
		mov bx , di
		mov bh , 0x07
		
		mov [es:si] , bx
		mov word [es:si - 160] , 0x0720
		add cx , 2
		cmp cx , [s5size]
		jne loops5

s5dispRet:
	popa
	ret


generateAlpha:
	pusha

	push 0xb800
	pop es

	mov word [es:0] , 0x0753
	mov word [es:2] , 0x0763
	mov word [es:4] , 0x076f
	mov word [es:6] , 0x0772
	mov word [es:8] , 0x0765
	mov word [es:10] , 0x073a
	mov word [es:12] , 0x0720
	
	mov ax , [score]
	push ax
	call printnum

	mov word [es:20] , 0x0744
	mov word [es:22] , 0x0765
	mov word [es:24] , 0x0761
	mov word [es:26] , 0x0774
	mov word [es:28] , 0x0768
	mov word [es:30] , 0x0773
	mov word [es:32] , 0x073a
	mov word [es:34] , 0x0720
	
	mov ax , [deaths]
	push ax
	call printnum1

	cmp word [total] , 15
	jne cnt
	jmp generateAlphaRet
	
	cnt:

	sub sp , 2
	push 25
	call randG
	pop dx

	add dl , 65
	mov dh , 0x07

	sub sp , 2
	push 4
	call randG
	pop bx

	
	sub sp , 2
	push 79
	call randG
	pop ax

	
	
	c1:
		cmp bx , 0
		jne c2

		cmp word [s1size] , 20
		je gotogenerateAlphaRet
		mov bx , [s1size]
		mov [s1 + bx] , dx
		mov cx , 2
		mul cx
		add ax , 160
		mov [s1pos + bx] , ax
		add word [s1size] , 2
		add word [total] , 1

	jmp checksize

	c2:
		cmp bx , 1
		jne c3

		cmp word [s2size] , 20
		je gotogenerateAlphaRet
		mov bx , [s2size]
		mov [s2 + bx] , dx
		mov cx , 2
		mul cx
		add ax , 160
		mov [s2pos + bx] , ax
		add word [s2size] , 2
		add word [total] , 1

	jmp checksize
	
	jmp c3
	gotogenerateAlphaRet:
		jmp generateAlphaRet
	

	c3:
		cmp bx ,2
		jne c4

		cmp word [s3size] , 20
		je gotogenerateAlphaRet
		mov bx , [s3size]
		mov [s3 + bx] , dx
		mov cx , 2
		mul cx
		add ax , 160
		mov [s3pos + bx] , ax
		add word [s3size] , 2
		add word [total] , 1

	jmp checksize

	c4:
		cmp bx , 3
		jne c5

		cmp word [s4size] , 20
		je gotogenerateAlphaRet
		mov bx , [s4size]
		mov [s4 + bx] , dx
		mov cx , 2
		mul cx
		add ax , 160
		mov [s4pos + bx] , ax
		add word [s4size] , 2
		add word [total] , 1

	jmp checksize

	c5:

		cmp word [s5size] , 20
		je gotogenerateAlphaRet
		mov bx , [s5size]
		mov [s5 + bx] , dx
		mov cx , 2
		mul cx
		add ax , 160
		mov [s5pos + bx] , ax
		add word [s5size] , 2
		add word [total] , 1


	checksize:

		;cmp word [total] , 5
		;ja generateAlphaRet
		;call generateAlpha

	
	

generateAlphaRet:
	popa
	ret


boxFunc:
	pusha
	push 0xb800
	pop es
	
	
	
	mov ax , 0
	
	in al, 0x60

	right:
		cmp al, 0x4D
		jne left
	
		mov si, [boxpos]
		add si , 2
		cmp si , 4000
		je rightbound
		mov word [es : si-2], 0x0720
		mov word [es : si], 0x07DC
		mov [boxpos], si
		jmp boxFuncRet

	left:
		cmp al, 0x4B
		jne boxFuncRet
	
		mov si, [boxpos]
		sub si , 2
		cmp si , 3838
		je leftbound
		mov word [es : si+2], 0x0720
		mov word [es : si], 0x07DC
		mov [boxpos], si
		jmp boxFuncRet



	rightbound:
		mov word [es : 3998], 0x07DC
		mov word [boxpos], 3998
		jmp boxFuncRet
	leftbound:
		mov word [es : 3840], 0x07DC
		mov word [boxpos], 3840
	


boxFuncRet:
	popa
	ret


kbisr : pusha
	mov ax, 0xb800
	mov es, ax

	call boxFunc
	


nomatch : ;mov al, 0x20
;out 0x20, al
popa
jmp far [cs:oldisr]
;iret

start : mov dx , 'Z'
	call clrscr
	xor ax, ax
	mov es, ax
	mov ax, [es: 9*4]
	mov[oldisr], ax
	mov ax, [es: 9*4 + 2]
	mov[oldisr + 2], ax
	cli
	mov word[es: 9*4], kbisr
	mov [es: 9*4 + 2], cs
	sti


	xor ax, ax
	mov es, ax
	mov ax, [es: 8*4]
	mov[oldisr1], ax
	mov ax, [es: 8*4 + 2]
	mov[oldisr1 + 2], ax

	cli ; disable interrupts
	mov word [es:8*4], timeisr; store offset at n*4
	mov [es:8*4+2], cs ; store segment at n*4+2
	sti ; enable interrupts

	

	
	;jne cnt
	;jmp end
	
	;cnt:
	

	

	l1 : 
		
		;mov ah, 0
		;int 0x16
		;cmp al, 27
		cmp word [deaths] , 10
		jne l1

		
	
		

end : 
	push 0
	pop es
	mov ax , [oldisr]
	mov bx , [oldisr + 2]
	cli ; disable interrupts
	mov word [es:9*4], ax; store offset at n*4
	mov [es:9*4+2], bx ; store segment at n*4+2
	sti ; enable interrupts

	mov ax , [oldisr1]
	mov bx , [oldisr1 + 2]
	cli ; disable interrupts
	mov word [es:8*4], ax; store offset at n*4
	mov [es:8*4+2], bx ; store segment at n*4+2
	sti ; enable interrupts


mov ax, 0x4c00
	int 21h

clrscr: push es 
	push ax 
	push cx 
	push di 
	mov ax, 0xb800 
	mov es, ax ; point es to video base 
	xor di, di ; point di to top left column 
	mov ax, 0x0720 ; space char in normal attribute 
	mov cx, 2000 ; number of screen locations 
	cld ; auto increment mode 
	rep stosw ; clear the whole screen 
	pop di 
	pop cx 
	pop ax 
	pop es 
	ret 


