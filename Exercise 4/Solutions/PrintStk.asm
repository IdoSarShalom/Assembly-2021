; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; PrintStk.asm
; due to 04/06/2021
; Tomer griba  325105625
; Ido Sar Shalom   212410146
; Description: This code prints the content of the stack to the DOS-BOX screen 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.model small

.data
	Dictionary 	db '0', '1', '2', '3', '4', '5', '6', '7', '8', "9", 'A', 'B', 'C', 'D', 'E', 'F'
	lowBits db 00001111b  ;4 low bits of 1byte   
	highBits db 11110000b  ;4 high bits of 1byte
	
.stack 100h

.code	
START:
	mov ax, @data
	mov ds, ax
	
	; setting extra segment to screen memory 
	mov ax, 0B800h
	mov es, ax
	
	mov ax, 0102h
	push ax
	
	mov ax, 0304h
	push ax

	mov ax, 0506h
	push ax
	
	mov ax, 0807h
	push ax
	
	mov ax, 0A09h
	push ax

	mov ax, 0C0Bh
	push ax
	
	mov ax, 0E0Dh
	push ax
	
	mov ax, 100Fh
	push ax
	
	mov ax, 1211h
	push ax

	mov ax, 1413h
	push ax
	
	mov bx, 50h
	
	mov ax, 20d
	
	call printStack
	
	mov ax, 4c00h
	int 21h
		
	;Inputs:  
	;ax - amount of bytes to print from the stack, bx - the located area in the DOS to print 
	;Outputs: print the content of each byte requested from the stack  
	;Assumes es set to screen memory 
	printStack proc near
	
	push bp
	mov bp, sp 

	push si
	push cx
	
	xor si, si
	mov si,04h 
	
	
	mov cx, ax ;counter of the loop 
	
	mainLoop:
	
	cmp cx, 01h 
	je lastIteration 
	
	baseCase: 
	mov ax, ss:[bp+si]
	add si,02h  
	call printWord
	sub cx, 02h
	jmp endIteration
	
	
	lastIteration:
	mov ax, ss:[bp+si]
	add si,02h  
	call printByte
	pop si
	pop cx
	pop bp
	ret 
	
	endIteration:
	
	cmp cx, 0h 
	jne mainLoop
	
	pop si
	pop cx
	pop bp
	
	ret 
	printStack endp
	
	
	;Inputs:  
	;al - low bits of ax register, bx - indicate where to print on the DOS-screen and inc bx to next position 
	;Outputs: print al latter (ascii) on the DOS-screen
	;Assumes es set to screen memory 
	printByte proc near 
	
	push dx 
	push cx
	push ax 
	
	mov ah, 46d ;green background code 	
	mov cl, 04h ;set the value of cl to 4, in order to shift right the bits 4 places
	
	and al, highBits ;get the first digit to print to screen (4 high bits of the al register) 	

	shr al, cl ;shift right the bits 4 places
	
	push bx
	xor bx,bx 
	mov bl, al	
	mov dl, ds:[Dictionary + bx] ; get the ascii value of the digit using the Dictionary array 
	mov al, dl 
	pop bx
	
	mov es:[bx], ax ;writing to screen memory 
	
	add bx, 02h
	
	;retrieve the value of al
	pop ax
	push ax 
	
	and al, lowBits ;get the second digit to print to screen (4 low bits of the al register) 	
	mov ah, 46d ;green background code 	


	push bx
	xor bx,bx 
	mov bl, al	
	mov dl, ds:[Dictionary + bx] ; get the ascii value of the digit using the Dictionary array 
	mov al, dl 
	pop bx

	mov es:[bx], ax ;writing to screen memory 
	
	add bx, 009Eh ;inc bx to the next row in order to print next latter
	
	pop ax
	pop cx
	pop dx 
	
	ret 
	printByte endp
	
	;Inputs:  
	;ax - register, bx - indicate where to print on the DOS-screen and inc bx to next position 
	;Outputs: print ax latter (ascii) on the DOS-screen
	;Assumes es set to screen memory 
	printWord proc near 
	
	push ax 
	call printByte
	
	mov al,ah 
	
	call printByte
	pop ax 
	ret 
	printWord endp
	
end START