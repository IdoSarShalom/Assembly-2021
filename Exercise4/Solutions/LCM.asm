; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; LCM.asm
; due to 04/06/2021
; Ido Sar Shalom   
; Description: This code finds the longest common subsequence of two strings
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.model small

.data

	M db 'Message 1 goes here!'
	N db 'Message 2 will be here :)'
	
	MSize dw 20d ;the size of M string 
	NSize dw 25d ;the size of N string
	
.stack 180h

.code	
START:	
	mov ax, @data
	mov ds, ax
	
	call lcs_launcher

	mov ax, 4c00h
	int 21h
	
	;Inputs: the lengthes of the M and N strings 
	;Outputs: retrun via lcs procedure the longest common subsequence via cx register
	;Note that the procedure preserves the registers si di and all other registers, cx is the returned value
	lcs_launcher proc near 
	
	push si 
	push di 
		
	xor si, si
	xor di, di
	xor cx, cx

	call lcs 
	
	pop di 
	pop si
	
	ret 
	lcs_launcher endp


	;Inputs: the lengthes of the M and N strings, si di registers as indexes in the strings, cx is the counter of lcs all initiated to zero 
	;Outputs: retrun via cx register the size of the longest common subsequence
	;Note that the procedure overrides the registers si di, cx is the returned value (besides that save all other registes)
	lcs proc near

	;stopCondition
	cmp si, ds:[Msize]
	je stopCondition
	
	cmp di, ds:[Nsize]
	je stopCondition
	
	push ax ;auxiliary register 
	
	mov al, byte ptr ds:[M+si] ;pass to ax the content of the si'th index in the string M
	mov ah, byte ptr ds:[N+di] ;pass to bx the content of the di'th index in the string N

	cmp al, ah ;compare the contents	
	je equalChar 

	
	notEqualChar:
	
	;save the last state 
	push si 
	push di 
	push cx 
	
	inc si
	
	call lcs 
	;cx contains the modified value 
	
	mov ax, cx ;save the value of cx from the above call to the lcs procedure  
	
	;retrieve previous state  
	pop cx
	pop di 
	pop si 
	
	;prepare for next recursion step, as previous 
	push di 
	push si 
	
	inc di
	
	call lcs 
	
	;retrieve previous state  
	pop si
	pop di 
	
	;take the maximum value of the two recursion steps
	cmp cx, ax 
	ja firstCase
	
	secondCase:
	;ax is bigger therfore, move the value of ax to cx 
	mov cx, ax
	pop ax 
	ret 

	firstCase:
	pop ax 

	ret 

	equalChar: 
	pop ax 
	
	;prepare for recursion step 
	inc cx 
	inc si 
	inc di
	
	call lcs 
	;cx contains the modified value 	
	ret  
		
	stopCondition:
	ret 
	lcs endp
	
end START
