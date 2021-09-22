; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; adfile.asm
; due to 30/06/2021
; Ido Sar Shalom   212410146
; Description: This code handles the ads in the game of Conway Game of Life.
; The ads appear in the middle of the DOS-screen when exiting the game
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.model tiny

.code
	
	org 100h

	jmp HERE ; jump over data declaration
	
	adCounter db 0h ; count 3 seconds
	flag db 0h ; 0 === > NOT BLINKING DO NOT PRINT, 1 === > BLINKING DO THE PRINT
	
	HERE:
	jmp IVT_REPLACE

	ISR_New proc near uses ax es

	int 80h ; Call the old ISR 8h
		
	;setting extra segment to screen memory 
	mov ax, 0b800h
	mov es, ax
	
	inc ds:[adCounter] ; a new generation of the game happens every 1 sec 
	cmp ds:[adCounter], 18*3
	jne LabelAlways10
	
	mov ds:[adCounter], 0h ;reset the adCounter

	cmp ds:[flag], 0h 
	je Ad
	
	jmp BlackAd	
	
	Ad:
	; Printing to screen 'Your Ad Goes Here'
	
	xor ds:[flag], 00000001b ; 0 <---> 1, flip the flag 	 
	
	mov ah, 0EAh
	
	mov al, 'Y'
	mov es:[160*12+60], ax
	
	mov al, 'o'
	mov es:[160*12+62], ax
	
	mov al, 'u'
	mov es:[160*12+64], ax
	
	mov al, 'r'
	mov es:[160*12+66], ax
	
	mov al, ' '
	mov es:[160*12+68], ax
	
	mov al, 'A'
	mov es:[160*12+70], ax
	
	mov al, 'd'
	mov es:[160*12+72], ax
	
	mov al, ' '
	mov es:[160*12+74], ax
	
	mov al, 'G'
	mov es:[160*12+76], ax
	
	mov al, 'o'
	mov es:[160*12+78], ax
	
	mov al, 'e'
	mov es:[160*12+80], ax
	
	mov al, 's'
	mov es:[160*12+82], ax
	
	mov al, ' '
	mov es:[160*12+84], ax
	
	mov al, 'H'
	mov es:[160*12+86], ax
	
	mov al, 'e'
	mov es:[160*12+88], ax
	
	mov al, 'r'
	mov es:[160*12+90], ax
	
	mov al, 'e'
	mov es:[160*12+92], ax
	
	jmp LabelAlways10
	
	BlackAd:
	
	xor ds:[flag], 00000001b ; 0 <---> 1, flip the flag 	 
		
	mov ah, 0h ;black symbol code
	mov al, 219d ; the rectangle scan code 
	
	mov es:[160*12+60], ax
	
	mov es:[160*12+62], ax
	
	mov es:[160*12+64], ax
	
	mov es:[160*12+66], ax
	
	mov es:[160*12+68], ax
	
	mov es:[160*12+70], ax
	
	mov es:[160*12+72], ax
	
	mov es:[160*12+74], ax
	
	mov es:[160*12+76], ax
	
	mov es:[160*12+78], ax
	
	mov es:[160*12+80], ax
	
	mov es:[160*12+82], ax
	
	mov es:[160*12+84], ax
	
	mov es:[160*12+86], ax
	
	mov es:[160*12+88], ax
	
	mov es:[160*12+90], ax
	
	mov es:[160*12+92], ax
	
	LabelAlways10:
	
	iret
	ISR_New endp

	public IVT_REPLACE
	IVT_REPLACE:
	mov ax,0h
	mov es,ax

	cli
	;moving Int8 into IVT[0a0h]
	mov ax,es:[8h*4]
	mov es:[80h*4],ax
	mov ax,es:[8h*4+2]
	mov es:[80h*4+2],ax
	
	;moving ISR_New into IVT[9]
	mov ax,offset ISR_New
	mov es:[8h*4],ax
	mov ax,cs
	mov es:[8h*4+2],ax
	sti

	mov dx, 01EEh  ; save the amount of bytes in the memory from the beginning of the PSP 
	int 27h
end HERE
