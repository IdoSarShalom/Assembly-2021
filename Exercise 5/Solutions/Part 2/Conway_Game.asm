; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; conway2.asm
; due to 20/06/2021
; Tomer griba  325105625
; Ido Sar Shalom   212410146
; Description: This code handles the full game of Conway Game of Life.
; Includes everything in it: the selection mode, measures the time from the beginning of the selection mode until the player has finished.
; modify each generation of the game, handles the keyboard in the game(press p to Pause the game, and e to exit the game). 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.model small

.data
	;************************ Variables ***********************************
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
	time_message db 'ST1 TIME:$'
	sec_message db '[sec]$'
	Dictionary_1 db '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
	Old_int_off dw 0h
	Old_int_seg dw 0h
	counter db 0h ; count 1 second 
	countAlive db 0h ; count the amount neighbor alive cells near a specific given cell 
	nextStateArray db 1500d dup (0d) ; each element in the array is correlate to a location in the Conway-screen, and thus it contains the cells in Conway-screen to the next generation
	nextStateIndex dw 0h ; index of the next state array 
	game_mode db 0h ; 0 ---> The game is on, pause it ! , 1 ---> the is game paused, resume it !
	;**********************************************************************
.stack 100h

.code	
START:
	mov ax, @data
	mov ds, ax
	
	;setting extra segment to screen memory 
	mov ax, 0b800h
	mov es, ax
	
	;part 1 of the game
	call PrintStart 
	call selectionState
		
	mov ax,0h ; location of IVT is 0000
	mov es,ax
	
	cli ; block interrupts
	xor ax, ax
	
	;Save the CS:IP values of the old ISR8 to Old_int_seg and Old_int_seg variables
	mov ax,es:[8h*4] ;copy old ISR8 IP to Old_int_off
	mov ds:[Old_int_off], ax
	mov ax,es:[8h*4+2] ;copy old ISR8 CS to Old_int_seg
	mov ds:[Old_int_seg],ax
	
	;moving ISR_New_int8 into IVT8
	mov ax,offset ISR_New_int8 ;copy the IP of ISR_New_int8 to IVT8
	mov es:[8h*4],ax
	mov ax,seg ISR_New_int8 ;copy CS of ISR_New_int8 into IVT8
	mov es:[8h*4+2],ax
	
	sti ; set interrupts
	
	;setting extra segment to screen memory 
	mov ax, 0b800h
	mov es, ax	
	
	InfiniteLoop:
	in al, 64h ; Read keyboard status port
	test al, 00000001b ; LSB inidicate if a keyboard button was pushed/released 
	je InfiniteLoop ; Wait until data available	
	in al, 60h ; Get keyboard data
	cmp al, 19h ; Is it the 'p' key ?
	jne p_not_Pressed1
	
	pPressed1:
	cmp ds:[game_mode], 0h ; the game is on, pause it ! 
	je PauseGameLabel
	
	ResumeGameLabel:
	mov ds:[game_mode], 0h ; the game is paused, resume it ! 
	jmp InfiniteLoop

	
	PauseGameLabel:	
	mov ds:[game_mode], 1h ; the game is on, pause it ! 
	jmp InfiniteLoop
	
	p_not_Pressed1:

	cmp al, 12h ; Is it the 'e' key ?
	je ExitGame ; exit the game !
		
	jmp InfiniteLoop
	
ExitGame:
	mov ax, 0h	; location of IVT is 0000
	mov es, ax
	
	; move the Old ISR8 address back to the appropriate cell IVT8 
	cli ; block interrupts
	mov ax, Old_int_off
	mov es:[8h*4], ax
	mov ax, Old_int_seg
	mov es:[8h*4+2], ax
	sti ; set interrupts
	
	; Report the end of the interrupt to the pic 
	mov al, 20h
	out 20h, al	
	
	; Grant access to interrupts from keyboard
	in al, 21h
	and al, 0FDh ;set on zero the second bit of al 
	out 21h, al	
	
	; Terminate program
	mov ax, 4c00h 
	int 21h
	
	
	;Inputs: register di contains the current location  
	;Outputs: modify di to the right location and call CheckIfAlive proc
	checkLeft proc near uses di
	sub di, 02h ; modify to the appropriate location
	call CheckIfAlive	
	ret
	checkLeft endp 
	
	;Inputs/Outputs: Similar to checkLeft function
	checkLeftUpperCorner proc near uses di
	sub di, 02h ; modify to the appropriate location
	sub di, 160d 
	call CheckIfAlive		
	ret
	checkLeftUpperCorner endp 

	;Inputs/Outputs: Similar to checkLeft function
	checkLeftDownCorner proc near uses di
	sub di, 02h ; modify to the appropriate location
	add di, 160d 
	call CheckIfAlive		
	ret
	checkLeftDownCorner endp 
	
	;Inputs/Outputs: Similar to checkLeft function	
	checkRight proc near uses di
	add di, 02h ; modify to the appropriate location
	call CheckIfAlive		
	ret
	checkRight endp 
	
	;Inputs/Outputs: Similar to checkLeft function
	checkRightUpperCorner proc near uses di
	add di, 02h ; modify to the appropriate location
	sub di, 160d 
	call CheckIfAlive		
	ret
	checkRightUpperCorner endp 
	
	;Inputs/Outputs: Similar to checkLeft function
	checkRightDownCorner proc near uses di
	add di, 02h ; modify to the appropriate location
	add di, 160d 
	call CheckIfAlive		
	ret
	checkRightDownCorner endp 
	
	;Inputs/Outputs: Similar to checkLeft function
	checkUp proc near uses di
	sub di, 160d ; modify to the appropriate location
	call CheckIfAlive		
	ret
	checkUp endp 
	
	;Inputs/Outputs: Similar to checkLeft function
	checkDown proc near uses di
	add di, 160d ; modify to the appropriate location
	call CheckIfAlive		
	ret
	checkDown endp 
	
	;Inputs: register di contains the current location  
	;Outputs: increment the variable countAlive if the current cell is alive 
	CheckIfAlive proc near uses ax di

	mov ax, es:[di] 
	cmp ah, 0h 	;black symbol code 

	jnz LabelNotAlive
	inc ds:[countAlive]
	
	LabelNotAlive:	
	ret 
	CheckIfAlive endp
	
	;Inputs: nextStateArray variable 
	;Outputs: check the middle screen cells in the Conway-screen and modify the nextStateArray variable in the appropriate index
	;overrides the nextStateArray variable and nextStateIndex variable
	middleScreen proc near uses dx di ax cx
	
	mov di, 1*160 + 2 ; initial location on the screen
	mov cx, 23d
	mov ds:[nextStateIndex], 61d	 				;the appropriate index in the nextStateArray
	LoopScreen1:	
	mov dx, 58d 
	LoopScreen2:
	
	; Check all the neighboors of the cell  
	call checkLeft
	call checkLeftUpperCorner
	call checkLeftDownCorner
	call checkRight
	call checkRightUpperCorner
	call checkRightDownCorner
	call checkUp
	call checkDown
	
	; modify the next state of the cell
	call ConwayRules
	
	add di, 02h
	inc ds:[nextStateIndex]
	; check condition loop 
	sub dx, 01h	
	jnz LoopScreen2
	
	add di, 44d 
	add ds:[nextStateIndex], 02h
	loop LoopScreen1

	ret
	middleScreen endp 
	
	;Inputs: nextStateArray variable 
	;Outputs: check the first row cells in the Conway-screen and modify the nextStateArray variable in the appropriate index
	;overrides the nextStateArray variable and nextStateIndex variable
	firstRow proc near uses dx di	
	mov di, 02h ; initial location on the screen
	
	mov ds:[nextStateIndex], 1d 				;the appropriate index in the nextStateArray 

	mov dx, 58d ; counter of the loop  
	IterateFirstRow:
	
	; Check all the neighboors of the cell  
	call checkLeft
	call checkLeftDownCorner
	call checkRight
	call checkRightDownCorner
	call checkDown
	
	; modify the next state of the cell
	call ConwayRules
	
	add di, 02h
	
	inc ds:[nextStateIndex] ; next position 
	
	sub dx, 01h	
	jnz IterateFirstRow
	ret	
	firstRow endp 
	
	;Inputs: nextStateArray variable 
	;Outputs: check the last row cells in the Conway-screen and modify the nextStateArray variable in the appropriate index
	;overrides the nextStateArray variable and nextStateIndex variable
	lastRow proc near uses dx di
		
	mov di, 160*24+2 ; initial location on the screen
	
	mov ds:[nextStateIndex],1441d  				;the appropriate index in the nextStateArray
	
	mov dx, 58d 
	IterateLastRow:
	
	; Check all the neighboors of the cell  
	call checkLeft
	call checkLeftUpperCorner
	call checkRight
	call checkRightUpperCorner
	call checkUp
	
	; modify the next state of the cell
	call ConwayRules
	
	; Next position on the Conway-screen 
	add di, 02h	
	inc ds:[nextStateIndex]

	sub dx, 01h	
	jnz IterateLastRow
	
	ret
	lastRow endp 
	
	;Inputs: nextStateArray variable
	;Outputs: check the first column cells in the Conway-screen and modify the nextStateArray variable in the appropriate index
	;overrides the nextStateArray variable and nextStateIndex variable
	firstColumn proc near uses dx di 
		
	mov di, 160d ; initial location on the screen
	mov ds:[nextStateIndex], 60d 				;the appropriate index in the nextStateArray
	
	mov dx, 23d 
	IteratefirstColumn:
	
	; Check all the neighboors of the cell
	call checkUp
	call checkDown
	call checkRight
	call checkRightDownCorner
	call checkRightUpperCorner
	; modify the next state of the cell
	call ConwayRules
	
	; Next position on the Conway-screen
	add di, 160d
	add ds:[nextStateIndex],60d

	sub dx, 01h	
	jnz IteratefirstColumn
	
	ret
	firstColumn endp

	;Inputs: nextStateArray variable
	;Outputs: check the last column cells in the Conway-screen and modify the nextStateArray variable in the appropriate index
	;overrides the nextStateArray variable and nextStateIndex variable
	lastColumn proc near uses dx di 
		
	mov di, 160+118 ; initial location on the screen
	
	mov ds:[nextStateIndex],119d		;the appropriate index in the nextStateArray
	
	mov dx, 23d 
	IterateLastColumn:
	; Check all the neighboors of the cell
	call checkUp
	call checkDown
	call checkLeft
	call checkLeftDownCorner
	call checkLeftUpperCorner
	; modify the next state of the cell
	call ConwayRules
	
	; Next position on the Conway-screen
	add di, 160d
	add ds:[nextStateIndex],60d		

	sub dx, 01h	
	jnz IterateLastColumn
	
	ret
	lastColumn endp
	
	;Inputs: nextStateArray variable
	;Outputs: check the corners cells in the Conway-screen and modify the nextStateArray variable in the appropriate index
	;overrides the nextStateArray variable and nextStateIndex variable
	corners proc near uses di 	
	; Check all the corners in the Conway-screen
	mov di, 0h ; Left up corner
	mov ds:[nextStateIndex],0d		;the appropriate index in the nextStateArray
	call checkRight
	call checkRightDownCorner
	call checkDown	
	call ConwayRules

	mov di, 160*24 ; Left down corner
	mov ds:[nextStateIndex],1440d		;the appropriate index in the nextStateArray
	call checkUp
	call checkRight
	call checkRightUpperCorner	
	call ConwayRules
	
	mov di, 118 ; Right up corner
	mov ds:[nextStateIndex],59d		;the appropriate index in the nextStateArray
	call checkDown
	call checkLeft
	call checkLeftDownCorner	
	call ConwayRules
	
	mov di, 160*24+118 ; Right down corner	
	mov ds:[nextStateIndex],1499d		;the appropriate index in the nextStateArray
	call checkUp
	call checkLeft
	call checkLeftUpperCorner	
	call ConwayRules
	
	ret
	corners endp
	
	;Inputs: nextStateArray variable , nextStateIndex variable and di as coordinate in the Conway-screen
	;Outputs: regulate if the specific given cell coordinate is alive or dead in next generation of the Conway game
	;overrides the nextStateArray variable and nextStateIndex variable
	ConwayRules proc near uses ax bx di
	
	; Check if the cell is alive/dead
	mov bx, ds:[nextStateIndex] ; get the appropriate index
	; Check if the cell is alive/dead
	mov ax, es:[di] 
	cmp ah, 0h 	;black symbol code 
	jne labelDead
	
	mov ds:[nextStateArray + bx], 1d		;the appropriate index in the nextStateArray
	cmp ds:[countAlive], 01h ; die from solitude 
	ja NextCase   
	
	Solitude:
	mov ds:[nextStateArray + bx], 0d
	jmp exitConway
	
	NextCase:
	cmp ds:[countAlive], 03h 
	ja dieFromCrowding
	jmp exitConway
	
	dieFromCrowding:
	mov ds:[nextStateArray + bx], 0d
	jmp exitConway
	
	labelDead: ;white symbol code
	mov ds:[nextStateArray + bx], 0d
	
	; If dead and there are exacly three neighboors then he is alive 
	cmp ds:[countAlive], 03h
	jne exitConway
	
	mov ds:[nextStateArray + bx], 1d ; alive 
		
	exitConway:
	mov ds:[countAlive], 0h
	ret 
	ConwayRules endp
	
	printStart_1 proc near 
	push ax 
	push si
	push bx

	mov al, 219d ;ascii code of the char █
		
	mov si, 0h
	mov bx, 0h
	mov cx, 0h


	; ;retrive the original values of the registers (re-entrance)
	pop bx
	pop si
	pop ax
	ret 
	printStart_1 endp 	
	
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
	
	;Inputs: real time clock port (RTC)
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
	
	;Inputs: real time clock port (RTC)
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

	; Print STR1 TIME to the Conway-screen
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

	; Print P-pause, e-Exit to the Conway-screen
	mov di, 160*2 + 130
	
	mov ah,46d	
	mov al, 'p'
	mov es:[di], ax
	
	mov al, '-'
	add di, 02h
	mov es:[di], ax

	mov al, 'P'
	add di, 02h
	mov es:[di], ax
	
	mov al, 'A'
	add di, 02h
	mov es:[di], ax

	mov al, 'U'
	add di, 02h
	mov es:[di], ax

	mov al, 'S'
	add di, 02h
	mov es:[di], ax

	mov al, 'E'
	add di, 02h
	mov es:[di], ax
	
	mov di, 160*3 + 130
	mov al, 'e'
	mov es:[di], ax
	
	mov al, '-'
	add di, 02h
	mov es:[di], ax

	mov al, 'E'
	add di, 02h
	mov es:[di], ax
	
	mov al, 'X'
	add di, 02h
	mov es:[di], ax
	
	mov al, 'I'
	add di, 02h
	mov es:[di], ax
	
	mov al, 'T'
	add di, 02h
	mov es:[di], ax
	
	pop ax 

;this code is similar to the one we wrote few assignments back , but with few changes
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
	; Change the color of the sign symbol 
	call previousColorToColor
	call printPoint
	
	call endClock ; Stop the clock 
	
	pop ax
	ret
	selectionState endp
	
	;Inputs: The variable nextStateArray
	;Outputs: iterates through the next state array and print the next generation to the Conway-screen
	;Assumes es set to screen memory
	printNextGeneration proc uses ax bx si cx di bp 
	xor ax, ax
	mov al, 219d ; the rectangle scan code 
	
	mov si, 0h
	mov bx, 0h
	mov di, 0h 
	
	LoopInsideLoop1:
	; Print the symbol if dead or alive ! 
	cmp ds:[nextStateArray + di], 0h ; dead ! 
	jnz PrintAlive 
	
	PrindDead: 
	mov ah, 0Fh ; White code symbol
	mov es:[bx + si], ax
	
	jmp LabelAlways9
	
	PrintAlive: 
	mov ah, 0h ; Black code symbol
	mov es:[bx + si], ax
	
	LabelAlways9:	
	add di, 01h 
	
	add si, 02h ;inc to next position in the screen 
	cmp si, 120d ;end of the column 
	jne LoopInsideLoop1
	
	NextRow:
	xor bp, bp 
	add bp, bx
	add bp, si 
	cmp bp, 3960d ;end of the Conway-screen
	je exitPrint1
	
	add bx, 160d ;next row 
	mov si, 0h ;initiate the value to next iteration 
	jmp LoopInsideLoop1
	
	exitPrint1:
	
	ret
	printNextGeneration endp
	
	;Inputs: the Conway's game variables 
	;Outputs: handles the conway game of life and modify the present state to the next state (next generation)
	;Assumes es set to screen memory
	gameHandler proc
	call middleScreen
	call firstRow
	call lastRow
	call firstColumn
	call lastColumn
	call corners
	call printNextGeneration ; Handle the next generation of the game 
	ret
	gameHandler endp
	
	;Inputs: the Conway's game variables 
	;Outputs: overrides the interrupt 8h as a new interrupt which handles the conway game of life
	ISR_New_int8 proc
	
	; Call the old ISR 8h
	pushf 
	call DWORD PTR [Old_int_off]
	
	cmp ds:[game_mode], 01h ; the game is paused
	je not_1_sec
	
	inc ds:[counter] ; a new generation of the game happens every 1 sec 
	cmp counter, 18d
	je after_1_sec
	
	jmp not_1_sec
after_1_sec:
	mov ds:[counter], 0h ; reset the counter 
	call gameHandler
not_1_sec:
	mov al, 20h ;report the end of the interrupt to the pic  
	out 20h, al
	iret
	ISR_New_int8 endp

end START