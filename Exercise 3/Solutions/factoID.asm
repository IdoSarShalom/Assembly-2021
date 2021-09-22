; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; factoID.asm
; due to 13/05/2021
; Tomer griba  325105625
; Ido Sar Shalom   212410146
; Description: This code calculates the sum of the series (x+1)! from n1 to n2 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.model small

.data
	n1 dw 0002h ; minimun value = 2  [n1 = 2 or 3]
	n2 dw 0005h ; maximum value = 7 
	; maximum value = 3!+4!+5!+6!+7!+8! = 46230d = B496h < 65535d ---> the multiply result can be presented with 16 bits (1word)
	sum dw 0000h ; summerize the factorial series  
	
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
	
	; reset the value of ax,cx,dx,si to zero 		
	xor ax,ax 	
	xor dx,dx 
	xor cx,cx 
	xor si,si 
		 
	inc WORD PTR ds:[n1] ; n1++
	inc WORD PTR ds:[n2] ; n2++
	
	; compute (n1+1)! 
	mov cx, WORD PTR ds:[n1] ;copy to cx the content of n1 
	mov ax, 0001h 
	
	FACTORIAL_LOOP:
	mul cx ; multiply ax*cx = cx 
	; multipy result: dx:ax = highBits:lowBits	
	loop FACTORIAL_LOOP ; dec cx, jmp FACTORIAL_LOOP if cx!=0 
	
	add WORD PTR ds:[sum], ax ;save the result to sum 
	
	; (n1+1)! = dx:ax 
	
	; in case of n1=n2: 
	N1_EQUAL_N2:
	mov si, WORD PTR ds:[n1] ; si = n1+1 
	cmp si, WORD PTR ds:[n2] ; (n1+1) - (n2+1) 
	jz END_OPERATION	
	
	; (n1+1)! + (n1+2)! + (n1+3)! + ... + (n2+1)!
	
	MUL_LOOP:
	inc BYTE PTR ds:[n1] ; n1+2 
	mul ds:[n1]
	; ax = (n1+2)!
	
	add WORD PTR ds:[sum],  ax ; (n1+1)! + (n1+2)!
	
	mov si, WORD PTR ds:[n1] ; si = n1+k 
	cmp si, WORD PTR ds:[n2] ; (n1+k) - (n2+1) 
	jnz MUL_LOOP
	
	
	END_OPERATION:
	mov ax, ds:[sum] ; mov to ax the summarize result of the factorial series and print it 
	
	;*************PRINT AX VALUE TO SCREEN - EX1*************
	
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
	
	mov dl, 'h' ;print the char 'h' 
	mov es:[0382h], dx ;writing to screen memory 
	
	;*********************************************************	

	mov ax, 4c00h
	int 21h
end START