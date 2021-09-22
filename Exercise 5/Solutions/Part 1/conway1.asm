; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; conway1.asm
; due to 15/06/2021
; Tomer griba  325105625
; Ido Sar Shalom   212410146
; Description: This code handles the selection mode of the Conway's Game of Life, 
; and measures the time from the beginning of the selection mode until the player has finished.
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.model small

.data
	;************************ Variables for part 1 ************************
	;initial location of coordinates is to the middle of the DOS-screen 
	row dw 1920d ;12th row (out of 25) - y cordinate
	column dw 60d ;30th column (out of 60) - x cordinate
	color db 0Fh ;color of the symbol 
	saveColor db 0Fh ;color of previous location of the symbol 
	flag db 0h 
	start_hour db 0h
	start_minute db 0h
	start_seconed db 0h
	end_hour db 0h
	end_minute db 0h
	end_seconed db 0h
	flag_1 db 0h
	Dictionary_1 db '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
	;**********************************************************************
	
.stack 100h

.code	
START:
	mov ax, @data
	mov ds, ax
	
	;setting extra segment to screen memory 
	mov ax, 0b800h
	mov es, ax
	
	call PrintStart 
	
	call selectionState

	mov ax, 4c00h
	int 21h
	
	;Inputs: None
	;Outputs: paint the Conway's Game of Life beginning on the DOS-screen
	;Assumes es set to screen memory 
	printStart proc near 
	push ax 
	push si
	push bx

	mov al, 219d ;ascii code of the char █
	mov ah, 0Fh ;white symbol code 
		
	mov si, 0h
	mov bx, 0h
	
	LoopInsideLoop:
	
	cmp si, 120d
	jne WhiteSymbol
	
	SepratorSign:
	mov ah, 06h ;orange-brown symbol code 
	mov word ptr es:[si+bx], ax ;writing to screen memory
	mov ah, 0Fh ;get back to white symbol code  
	jmp LabelAlways1
	
	WhiteSymbol:
	mov word ptr es:[si+bx], ax ;writing to screen memory
	
	LabelAlways1:	
	add si, 02h ;inc to next position in the screen 
	cmp si, 160d ;end of the column 
	jne LoopInsideLoop
	
	mov si, 0h ;initiate the value to next iteration 
	add bx, 160d ;next row 
	cmp bx, 4000d ;end of the DOS-screen
	jne LoopInsideLoop
	
	PrintSymbol:
	mov ds:[color], 04h ;red symbol code 
	call printPoint
	
	;retrive the original values of the registers (re-entrance)
	pop bx
	pop si
	pop ax
	ret 
	printStart endp 	
	
	
	;Inputs: color variable contains the ascii color value
	;Outputs: print the symbol █ in the x,y coordinates (according to row and column variables)
	;Assumes es set to screen memory
	printPoint proc near
	push si 
	push ax 
	push bx 
	
	mov al, 219d ;ascii code of the char █
	mov ah, byte ptr ds:[color] ;the ascii color value
	mov si, ds:[row] ;y coordinate
	mov bx, ds:[column] ;x coordinate
	mov word ptr es:[si+bx], ax ;symbol in current place (writing to screen memory)
	
	pop bx 
	pop ax
	pop si
	ret
	printPoint endp 	

		
	;Inputs: row and column variables (x and y coordinates of the symbol) from the data segment
	;color variable contains the ascii color value for printing in the current place 
	;Outputs: mov right the symbol of the player 
	;Assumes es set to screen memory, overrides the color variable and column variable (move to next position)
	movRight proc near 
	
	cmp ds:[column], 118d 
	je EdgeCase1
	
	PrintSymbolInCurrentPlace1:
	call printPoint ;color variable already contains the right value
	
	;Modify to the new coordinates
	add ds:[column], 02h ;x coordinate + 1
	
	call colorByLocation ;save the color of the current position
	
	PrintRedSymbolInCurrentPlace1:
	mov ds:[color], 04h ;red symbol code 
	call printPoint
	
	EdgeCase1:
	ret
	movRight endp
	
	
	;Inputs/Outputs: Similar to movRight function
	movLeft proc near 
	
	cmp ds:[column], 0d 
	je EdgeCase2
		
	PrintSymbolInCurrentPlace2:
	call printPoint ;color variable already contains the right value
	
	;Modify to the new coordinates
	sub ds:[column], 02h ;x coordinate - 1
	
	call colorByLocation ;save the color of the current position
	
	PrintRedSymbolInCurrentPlace2:
	mov ds:[color], 04h ;red symbol code 
	call printPoint
		
	EdgeCase2:
	ret
	movLeft endp
	
	
	;Inputs/Outputs: Similar to movRight function
	movUp proc near 

	cmp ds:[row], 0d 
	je EdgeCase3
		
	mov al, 219d ;ascii code of the char █
	
	PrintSymbolInCurrentPlace3:
	call printPoint ;color variable already contains the right value
	
	;Modify to the new coordinates
	sub ds:[row], 160d ;y coordinate - 1
	
	call colorByLocation ;save the color of the current position
	
	PrintRedSymbolInCurrentPlace3:
	mov ds:[color], 04h ;red symbol code 
	call printPoint
		
	EdgeCase3:
	ret
	movUp endp
	
	
	;Inputs/Outputs: Similar to movRight function
	movDown proc near 
	
	cmp ds:[row], 3840d 
	je EdgeCase4
			
	PrintSymbolInCurrentPlace4:
	call printPoint ;color variable already contains the right value
	
	;Modify to the new coordinates
	add ds:[row], 160d ;y coordinate + 1
	
	call colorByLocation ;save the color of the current position
	
	PrintRedSymbolInCurrentPlace4:
	mov ds:[color], 04h ;red symbol code 
	call printPoint
		
	EdgeCase4:
	ret
	movDown endp
	
	
	;Inputs: row and column variables (x and y coordinates of the symbol) from the data segment
	;Outputs: changes the saveColor variable to the color of the specific location 
	;Assumes es set to screen memory, overrides the saveColor variable
	colorByLocation proc near 
	push si 
	push bx 
	push cx 
	
	mov si, ds:[row] ;y coordinate
	mov bx, ds:[column] ;x coordinate
	mov cx, word ptr es:[si+bx] ;symbol in current place (writing to screen memory)
	
	mov ds:[saveColor], ch ;move to saveColor variable the color of the specific location
	
	pop cx 
	pop bx
	pop si
	ret
	colorByLocation endp
	
	
	;Inputs: the variables: color, saveColor
	;Outputs: transfer the content of saveColor variable to color variable
	;overrides the variable: color
	previousColorToColor proc near
	push dx 
	
	mov dh, byte ptr ds:[saveColor]
	mov byte ptr ds:[color], dh
	
	pop dx
	ret 
	previousColorToColor endp
	
	
	;Inputs: real time clock port (RTC) - the measured time is from the beginning of the program until e pressed
	;Outputs: save the current hour, minute, second in the variables: start_hour, start_minute, start_seconed
	;overrides the variable: start_hour, start_minute, start_seconed
	startClock proc near
	push ax 
		
	xor ax, ax
	;get starting hour
	mov al, 04h
	out 70h, al
	in al, 71h
	mov ds:[start_hour], al
	
	;get starting minute
	mov al, 02h
	out 70h, al
	in al, 71h
	mov ds:[start_minute], al
	
	;get starting seconed
	mov al, 00h
	out 70h, al
	in al, 71h
	mov ds:[start_seconed], al
	
	pop ax
	ret 
	startClock endp
	
	
	;Inputs: real time clock port (RTC) - the measured time is from the beginning of the program until e pressed
	;Outputs: save the current hour, minute, second in the variables: end_hour, end_minute, end_seconed
	;And print the time in seconds (Hexadecimal representation) to the DOS-screen
	;overrides the variable: start_hour, start_minute, start_seconed, end_hour, end_minute, end_seconed, flag_1
	endClock proc near 
	push ax 
	push bx 
	push cx 
	push si 
	push di 
	
	;get End hour
	mov al, 04h
	out 70h, al
	in al, 71h
	mov ds:[end_hour], al
	
	;get End minute
	mov al, 02h
	out 70h, al
	in al, 71h
	mov ds:[end_minute], al
	
	;get End seconed
	mov al, 00h
	out 70h, al
	in al, 71h
	mov ds:[end_seconed], al
	
	;change the variables (end_hour,start_hour,end_minute,start_minute,end_seconed,start_seconed) to show the real parammeters (hour, minute, second) in hex
	
	xor cx,cx
	mov cl, 4d
	mov al, ds:[end_hour]
	shr al, cl
	and al, 0Fh
	mov cx, 10d
	mul cl
	mov ah, ds:[end_hour]
	and ah, 0Fh
	add al, ah
	mov ds:[end_hour], al
	
	xor ax, ax
	xor cx, cx
	mov cl, 4d
	mov al, ds:[start_hour]
	shr al, cl
	and al, 0Fh
	mov cx, 10d
	mul cl
	mov ah, ds:[start_hour]
	and ah, 0Fh
	add al, ah
	mov ds:[start_hour], al
	
	xor ax, ax
	xor cx,cx
	mov cl, 4d
	mov al, ds:[end_minute]
	shr al, cl
	and al, 0Fh
	mov cx, 10d
	mul cl
	mov ah, ds:[end_minute]
	and ah, 0Fh
	add al, ah
	mov ds:[end_minute], al
	
	xor ax, ax
	xor cx, cx
	mov cl, 4d
	mov al, ds:[start_minute]
	shr al, cl
	and al, 0Fh
	mov cx, 10d
	mul cl
	mov ah, ds:[start_minute]
	and ah, 0Fh
	add al, ah
	mov ds:[start_minute], al
	
	
	xor cx,cx
	xor ax, ax
	
	mov cl, 4d
	mov al, ds:[end_seconed]
	shr al, cl
	and al, 0Fh
	mov cx, 10d
	mul cl
	mov ah, ds:[end_seconed]
	and ah, 0Fh
	add al, ah
	mov ds:[end_seconed], al
	
	xor ax, ax
	xor cx, cx
	mov cl, 4d
	mov al, ds:[start_seconed]
	shr al, cl
	and al, 0Fh
	mov cx, 10d
	mul cl
	mov ah, ds:[start_seconed]
	and ah, 0Fh
	add al, ah
	mov ds:[start_seconed], al
	
	;calculate the amount of seconds 
	
	; calculate the difference between the ending seconds and the starting seconds
	mov al, ds:[end_seconed]
	mov ah, ds:[start_seconed]
	cmp al, ah
	jae end_sec_bigger_than_start_sec ;Ending second bigger than starting second
	cmp ds:[end_minute], 0d
	jne end_minute_not_zero ;Ending minutes are not zero
	sub ds:[end_hour], 1h
	add ds:[end_minute], 60d
end_minute_not_zero: ;Ending minutes are not zero
	sub ds:[end_minute], 1d				;transform 1 minute to 60 seconds
	add al, 60d
end_sec_bigger_than_start_sec: ;Ending second bigger than starting second 
	sub al, ah			; al has the amount of secondes
	xor ah, ah
	
	xor bx, bx		
	mov bx, ax			;bx holds the amount of seconds
	
	
	; calculate the difference between the ending seconds and the starting seconds
	mov al, ds:[end_minute]
	mov ah, ds:[start_minute]
	cmp al, ah
	jae ending_minute_bigger_than_starting_minute ;Ending minute bigger than starting minute
	sub ds:[end_hour], 1h		;transform 1 hour to 60 minutes
	add ds:[end_minute], 60d
ending_minute_bigger_than_starting_minute: ;Ending minute bigger than starting minute
	sub al, ah			; al has the amount of secondes
	xor ah, ah
	
	
	mov cl, 60d			; 1 minute = 60 seconds
	mul cl
	
	add bx, ax
	
	mov al, ds:[end_hour]
	mov ah, ds:[start_hour]
	sub al, ah			; amount of hours passed
	xor dx, dx
	xor ah, ah
	mov cx, 3600d
	mul cx					;AX has "low" minutes  DX has "high" minutes
	
	add ax, bx
	jnc no_overflow
	add dx, 1d
	
no_overflow:

;now, DX holds the high secondes and AX holds the low secondes
;we need to print it to the screen
; we use DX but we don't print it because the time that will pass for which DX!=0 is more than 18 hours

;this code is similar to the one we wrote few assignments back , but with few changes
	mov di, 160*21 + 130

	push ax 
	
	mov ah,46d	
	mov al, 'S'
	mov es:[di], ax
	
	mov al, 'T'
	add di, 02h
	mov es:[di], ax

	mov al, '1'
	add di, 02h
	mov es:[di], ax
	
	mov al, ' '
	add di, 02h
	mov es:[di], ax

	mov al, 'T'
	add di, 02h
	mov es:[di], ax

	mov al, 'I'
	add di, 02h
	mov es:[di], ax

	mov al, 'M'
	add di, 02h
	mov es:[di], ax
	
	mov al, 'E'
	add di, 02h
	mov es:[di], ax
	
	mov al, ':'
	add di, 02h
	mov es:[di], ax

	pop ax 
	
	mov di, 160*23 + 130

mov cx,12d
LOP2:
	push ax													
	mov bx, 0Fh
	shr ax, cl
	and ax, bx		;take only one 
	cmp flag_1, 0h		;we don't want to print zeros from the left (like 0011, we want to print 11)
	jne flag_not_zero ; flag_1 != 0
	cmp al, 0h
	je Dont_print
	mov ds:[flag_1],1h
flag_not_zero:  
	mov si, ax
	xor ax, ax
	mov ah, 46d
	mov al, Dictionary_1[si]
	mov es:[di], ax
	add di, 2h
Dont_print:
	pop ax														
	sub cx, 4d
	
	JNZ LOP2
	
	and ax, 000Fh
continue_6:
	mov si, ax
	xor ax, ax
	mov ah, 46d
	mov al, Dictionary_1[si]
	mov es:[di], ax
Dont_print_1:
	add di, 2d
	mov ah,46d
	mov al, 'h'
	mov es:[di], ax	
	
	mov al, '['
	add di, 04h
	mov es:[di], ax 
	
	mov al, 's'
	add di, 02h
	mov es:[di], ax
	
	mov al, 'e'
	add di, 02h
	mov es:[di], ax
	
	mov al, 'c'
	add di, 02h
	mov es:[di], ax
	
	mov al, ']'
	add di, 02h
	mov es:[di], ax
	
	
	pop di 
	pop si 
	pop cx 
	pop bx  
	pop ax 
	ret 
	endClock endp
	
	;Inputs: the variables: color, saveColor, flag, column, row from the data segment
	;Outputs: control and manage the flow of the selection state of the Conway's Game of Life
	;Assumes es set to screen memory, overrides the variables: color, saveColor, flag, column, row
	selectionState proc near 
	
	; Start clock 
	call startClock
	
	push ax;

	; Mask interrupts from keyboard
	in al, 21h
	or al, 02h
	out 21h, al	
	
	WaitForData1:
	in al, 64h ; Read keyboard status port
	test al, 00000001b ; LSB inidicate if a keyboard button was pushed/released 
	je WaitForData1 ; Wait until data available
	in al, 60h ; Get keyboard data
	
	cmp al, 20h ; Is it the 'd' key ?
	je dPressed1
	
	cmp al, 1Eh ; Is it the 'a' key ?
	je aPressed1
	
	cmp al, 11h ; Is it the 'w' key ?
	je wPressed1
	
	cmp al, 1Fh ; Is it the 's' key ?
	je sPressed1
	
	cmp al, 14h ; Is it the 't' key ?
	je tPressed1
	
	cmp al, 12h ; Is it the 'e' key ?
	je ePressed1
	
	jmp WaitForData1
	
	dPressed1: ;move right
	
	cmp flag, 01h ;t was pressed and the previous color was white
	je dLabel1
	cmp flag, 02h ;t was pressed and the previous color was black
	je dLabel2
	jmp dLabel3
	
	dLabel1:
	mov ds:[color], 0h ;black symbol code 
	jmp LabelAlways2
	
	dLabel2:
	mov ds:[color], 0Fh ;white symbol code 
	jmp LabelAlways2
	
	dLabel3:
	call previousColorToColor
	
	LabelAlways2:
	mov ds:[flag], 0h ;reset the flag
	call movRight
	jmp WaitForData1
		
	aPressed1: ;move left

	cmp flag, 01h ;t was pressed and the previous color was white
	je aLabel1
	cmp flag, 02h ;t was pressed and the previous color was black
	je aLabel2
	jmp aLabel3
	
	aLabel1:
	mov ds:[color], 0h ;black symbol code 
	jmp LabelAlways3
	
	aLabel2:
	mov ds:[color], 0Fh ;white symbol code 
	jmp LabelAlways3
	
	aLabel3:
	call previousColorToColor
	
	LabelAlways3:
	mov ds:[flag], 0h ;reset the flag
	call movLeft 
	jmp WaitForData1
	
	wPressed1: ;move up
	
	cmp flag, 01h ;t was pressed and the previous color was white
	je wLabel1
	cmp flag, 02h ;t was pressed and the previous color was black
	je wLabel2
	jmp wLabel3
	
	wLabel1:
	mov ds:[color], 0h ;black symbol code 
	jmp LabelAlways4
	
	wLabel2:
	mov ds:[color], 0Fh ;white symbol code 
	jmp LabelAlways4
	
	wLabel3:
	call previousColorToColor
	
	LabelAlways4:
	mov ds:[flag], 0h ;reset the flag
	call movUp
	jmp WaitForData1
	
	sPressed1: ;move down
	
	cmp flag, 01h ;t was pressed and the previous color was white
	je sLabel1
	cmp flag, 02h ;t was pressed and the previous color was black
	je sLabel2
	jmp sLabel3
	
	sLabel1:
	mov ds:[color], 0h ;black symbol code 
	jmp LabelAlways5
	
	sLabel2:
	mov ds:[color], 0Fh ;white symbol code 
	jmp LabelAlways5
	
	sLabel3:
	call previousColorToColor
	
	LabelAlways5:
	mov ds:[flag], 0h ;reset the flag
	call movDown
	jmp WaitForData1
	
	tPressed1: ;selection state 

	cmp ds:[saveColor], 0Fh ;white symbol code 
	mov ds:[saveColor], 0h ;flip the color to black save the previous color (in case of multiple t clicks)
	je case1
	
	cmp ds:[saveColor], 0h ;black symbol code 
	mov ds:[saveColor], 0Fh ;flip the color to white save the previous color (in case of multiple t clicks)
	je case2
	
	case1:
	mov ds:[flag], 01h
	jmp LabelAlways6
	
	case2:
	mov ds:[flag], 02h
	
	LabelAlways6:
	jmp WaitForData1

	ePressed1: ;exit selection mode
	
	call endClock ; Stop the clock 
		
	; Grant access to interrupts from keyboard
	in al, 21h
	and al, 0FDh ;set on zero the second bit of al 
	out 21h, al	
	
	pop ax
	ret
	selectionState endp
	
end START