; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; factoID.asm
; due to 13/05/2021
; Ido Sar Shalom   
; Description: This code calculates the sum of the series (x+1)! from 0 to 9 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.model small

.data
	
	n1 dw 0000h   
	n2 dw 0009h 
	
	mulOperand dw 0000h 	
	
	; calculate: 1!+2!+3!+4!+5!+6!+7!+8!+9!+10! = 4,037,913d = 3D9D19h > 65535d ---> the multiply result CAN NOT (!) be presented with 16 bits (1word)
	; we'll use DOUBLE WORD (32 bits) to represent the multiply result so the maximum value is 2^(32)-1 = 4,294,967,295
	
	sum dd 00000000h
	
	;*************EX1 - VARIBALES*************
	Dictionary 	db '0', '1', '2', '3', '4', '5', '6', '7', '8', "9", 'A', 'B', 'C', 'D', 'E', 'F'
	lowBits db 00001111b  ;4 low bits of 1byte   
	highBits db 11110000b  ;4 high bits of 1byte
	num dw 1d dup (?) ;create a number variable and uninitialize it  
	;*****************************************
	
.stack 100h

.code	
START:
	mov ax, @data
	mov ds, ax
	
	;***************************INITIALIZE THE PROGRAM*********************	
	; reset the value of ax,bx,cx,dx,si,di to zero 		
	xor ax,ax 	
	xor cx,cx 
	xor dx,dx 
		
	inc WORD PTR ds:[n1] ; n1++
	inc WORD PTR ds:[n2] ; n2++	
	;***********************************************************************
	
	; calculate n! recursively by the formula n! = n * (n-1)! , 1! is given and equal to 1 (no need to calculate it)
	
	mov cx, 000Ah ; loop iterates for 10 times 
	
	; iterate the loop 10 times 
	MulLoop:
	
	cmp ds:[n1], 0001h 
	jz FirstIteration
		
	cmp ds:[n1], 0009h 
	jz OneBeforeTheLast
		
	cmp ds:[n1], 000Ah 
	jz LastIteration
	
	
	;************ ITERATIONS NUMBER 2-8 ************
	MainLabel:
	
	mov ax, WORD PTR ds:[n1] ; ax = n 
	mul WORD PTR ds:[mulOperand] ; mulOperand = (n-1)!
	
	; dx:ax = n*(n-1)! = n! 
	; multiplication result stores in dx:ax 
	
	mov WORD PTR ds:[mulOperand], ax ; modify mulOperand = n! for next iteration 
	add WORD PTR ds:[sum], ax ; sum = sum + n!
	
	jmp LabelAlways
	;***********************************************

	;************ ITERATION NUMBER 9 ************
	OneBeforeTheLast: ; iteration 9 
	
	mov ax, WORD PTR ds:[n1] ; ax = n ,  (n = 9)
	mul WORD PTR ds:[mulOperand] ; mulOperand = (n-1)!, (mulOperand = 8!) 
	
	; dx:ax == 9*8! = 9! = 362880d = 00058980h ===> dx:ax = 0005:8980	
	
	add WORD PTR ds:[sum], ax ; sum = sum + n!

	adc WORD PTR ds:[sum+02h], dx ; addding the carry out to dx 

	jmp LabelAlways ;jump to LabelAlways
	;********************************************

	;************ ITERATION NUMBER 10 ************
	LastIteration: ; iteration 10 
	; using the trick : 10! = 10 * 9! =  10 * 9 * 8! =  90 * 8!	
	mov ax, WORD PTR ds:[n1] ; ax = n ,  (n = 10)
	mov dx, 0009h
	mul dx ; ax contain 90d (9*10)
	mul WORD PTR ds:[mulOperand] ; mulOperand = (n-1)!, (mulOperand = 8!) 
	
	add WORD PTR ds:[sum], ax ; sum = sum + n!

	adc WORD PTR ds:[sum+02h], dx 
	
	jmp LabelAlways
	;*********************************************
	
	;************ ITERATION NUMBER 1 ************
	FirstIteration:	
	inc WORD PTR ds:[sum] ; the first element of the series is 1! = 1 
	mov ax, ds:[n1] 	; copy to mulOperand the value of n1 for next iteration to calculate (2! = 1!*2)
	mov ds:[mulOperand], ax 
	;********************************************
	
	LabelAlways: 
	inc ds:[n1] ;increment n1 to next iteration 
	xor ax,ax ;reset the values of dx:ax 
	xor dx,dx
	
	loop MulLoop
	
	;*************PRINT THE FIRST AND THE SECOND WORD OF SUM VARIABLE TO THE SCREEN USING EX1*************
	mov ax, WORD PTR ds:[sum+02h] 
		
	; save the value of ax to num 
	mov num, ax
	
	; reset the value of cx,bx to zero 
	xor cx, cx 
	xor bx, bx
	
	; setting extra segment to screen memory 
	mov si, 0B800h
	mov es, si
	
	mov dh, 46d ;green background code  
	
	; set the value of cl to 4, in order to shift right the bits 4 places
	mov cl, 04h 
	
	; 4 bits = 1 hexadecimal 
	
	; get the first digit to print to screen (4 high bits of the ah register) 	
	and ah, highBits
	
	; shift right the bits 4 places
	shr ah, cl 
	
	; copy the digit 
	mov bl, ah
	
	; get the ascii value of the digit using the Dictionary array 
	mov dl, ds:[Dictionary + bx] 
	
	; writing to screen memory 
	mov es:[037Ah], dx
	
	; repeat the process to print all the digits of the hexadecimal number 
	mov ax, num 
	
	; get the second digit to print to screen (4 low bits of the ah register) 	
	and ah, lowBits
	
	; copy the digit 
	mov bl, ah
	
	; get the ascii value of the digit using the Dictionary array 
	mov dl, ds:[Dictionary + bx] 
	
	; writing to screen memory 
	mov es:[037Ch], dx
	
	; get the third digit to print to screen (4 high bits of the al register)
	and al, highBits
	
	; shift right the bits 4 places
	shr al, cl
	
	; copy the digit 
	mov bl, al
		
	; get the ascii value of the digit using the Dictionary array 
	mov dl, ds:[Dictionary + bx] 
	
	; writing to screen memory 
	mov es:[037Eh], dx
		
	; get the fourth digit to print to screen (4 low bits of the al register)
	mov ax, num 	
	and al, lowBits
	
	; copy the digit 
	mov bl, al
		
	; get the ascii value of the digit using the Dictionary array 
	mov dl, ds:[Dictionary + bx] 
	
	; writing to screen memory 
	mov es:[0380h], dx
	
	;*************PRINT THE SECOND WORD OF SUM VARIABLE TO THE SCREEN USING EX1*************
	mov ax, WORD PTR ds:[sum] 

	; save the value of ax to num 
	mov num, ax
	
	; reset the value of cx,bx to zero 
	xor cx, cx 
	xor bx, bx
	
	; setting extra segment to screen memory 
	mov si, 0B800h
	mov es, si
	
	mov dh, 46d ;green background code  
	
	; set the value of cl to 4, in order to shift right the bits 4 places
	mov cl, 04h 
	
	; 4 bits = 1 hexadecimal 
	
	; get the first digit to print to screen (4 high bits of the ah register) 	
	and ah, highBits
	
	; shift right the bits 4 places
	shr ah, cl 
	
	; copy the digit 
	mov bl, ah
	
	; get the ascii value of the digit using the Dictionary array 
	mov dl, ds:[Dictionary + bx] 
	
	; writing to screen memory 
	mov es:[0382h], dx
	
	; repeat the process to print all the digits of the hexadecimal number 
	mov ax, num 
	
	; get the second digit to print to screen (4 low bits of the ah register) 	
	and ah, lowBits
	
	; copy the digit 
	mov bl, ah
	
	; get the ascii value of the digit using the Dictionary array 
	mov dl, ds:[Dictionary + bx] 
	
	; writing to screen memory 
	mov es:[0384h], dx
	
	; get the third digit to print to screen (4 high bits of the al register)
	and al, highBits
	
	; shift right the bits 4 places
	shr al, cl
	
	; copy the digit 
	mov bl, al
		
	; get the ascii value of the digit using the Dictionary array 
	mov dl, ds:[Dictionary + bx] 
	
	; writing to screen memory 
	mov es:[0386h], dx
		
	; get the fourth digit to print to screen (4 low bits of the al register)
	mov ax, num 	
	and al, lowBits
	
	; copy the digit 
	mov bl, al
		
	; get the ascii value of the digit using the Dictionary array 
	mov dl, ds:[Dictionary + bx] 
	
	; writing to screen memory 
	mov es:[0388h], dx
	
	mov dl, 'h' ;print the char 'h' 
	mov es:[038Ah], dx ;writing to screen memory 
		
	;*****************************************************************
	
	mov ax, 4c00h
	int 21h
end START
