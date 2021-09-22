; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; printAXd.asm
; due to 13/05/2021
; Tomer griba  325105625
; Ido Sar Shalom   212410146
; Description: This code prints the value of register AX in decimal representation signed value 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.model small

.data
	Dictionary 	db '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
	array db 5d dup (?) ;create an array contains all the digits to print to screen and uninitialize it  		
	operand dw 10d 
	
.stack 100h

.code	
START:
	mov ax, @data
	mov ds, ax
	
	; setting extra segment to screen memory 
	mov ax, 0B800h
	mov es, ax
	
	; reset the value of ax,bx,cx,dx,si,di to zero 		
	xor ax,ax 
	xor cx,cx 	
	xor bx,bx 
	xor si,si 
	xor di,di 
		
	;print to screen 'AX = ' 
	mov dh, 46d ;green background code 
	mov di,370h ;locate the where to print on the screen  
	mov dl, 'A' ;A ascii code 
	mov es:[di], dx ;writing to screen memory 
	add di, 02h	;next position to print 
	mov dl, 'X' ;X ascii code 
	mov es:[di], dx ;writing to screen memory 
	add di, 02h	
	mov dl, ' ' ;print space 
	mov es:[di], dx ;writing to screen memory 
	add di, 02h	
	mov dl, '=' ;= ascii code 
	mov es:[di], dx ;writing to screen memory 
	add di, 02h	
	mov dl, ' ' ;print space 
	mov es:[di], dx ;writing to screen memory 
	add di, 02h

	; initialize the value of register ax
	mov ax, 0F12Ch ;7980d
	
	; test if the number is possitive or negative 
	test ax, 1000000000000000b
	jz POSITIVE_NUMBER

	NEGATIVE_NUMBER: 
	mov dl, '-' ;print negative sign 
	mov es:[di], dx ;writing to screen memory 
	add di, 02h
	neg ax ; reference the number as positive  
	
	POSITIVE_NUMBER:
	
	xor dx,dx
	
	MAIN: 	
	div WORD PTR ds:[operand]
	
	mov bx,dx 
	mov cl, BYTE PTR ds:[Dictionary+bx]
	mov ds:[array + si], cl	
	inc si 
	xor bx,bx 
	xor dx,dx 
		
	cmp ax, 0 
	jnz MAIN
	
	dec si
	mov dh, 46d ;green background code 
	LOOP_ARRAY: 
	mov dl,ds:[array+si]
	mov es:[di], dx ;writing to screen memory 
	add di, 02h
	dec si
	cmp si,-1d
	jnz LOOP_ARRAY
	
	mov dl, 'd' ;print 'd' for decimal number  
	mov es:[di], dx ;writing to screen memory 

	mov ax, 4c00h
	int 21h
end START