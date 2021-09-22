; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; printAXh.asm
; due to 13/05/2021
; Ido Sar Shalom   
; Description: This code prints the value of register AX in Hexadecimal representation 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.model small

.data
	Dictionary 	db '0', '1', '2', '3', '4', '5', '6', '7', '8', "9", 'A', 'B', 'C', 'D', 'E', 'F'
	lowBits db 00001111b  ;4 low bits of 1byte   
	highBits db 11110000b  ;4 high bits of 1byte
	num dw 1d dup (?) ;create a number variable and uninitialize it  		
	
.stack 100h

.code
START:
	mov ax, @data
	mov ds, ax
	
	; setting extra segment to screen memory 
	mov ax, 0B800h
	mov es, ax
	
	; print to screen 'AX = ' 
	mov dl, 'A' ;A ascii code 
	mov dh, 46d ;green background code 
	
	mov es:[0370h], dx ;writing to screen memory 
	
	mov dl, 'X' ;X ascii code 
	mov es:[0372h], dx ;writing to screen memory 
	
	mov dl, ' ' ;print space 
	mov es:[0374h], dx ;writing to screen memory 
	
	mov dl, '=' ;= ascii code 
	mov es:[0376h], dx ;writing to screen memory 
	
	mov dl, ' ' ;print space 
	mov es:[0378h], dx ;writing to screen memory 
	
	;*************************************************
	; initialize the value of register ax
	mov ax, 1F2Ch 
	;*************************************************
	
	; save the value of ax to num 
	mov num, ax
	
	; reset the value of cx,bx to zero 
	xor cx, cx 
	xor bx, bx
	
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
	
	mov ax, 4c00h
	int 21h
end START
