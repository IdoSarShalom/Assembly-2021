; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; factor0F.asm
; due to 13/05/2021
; Ido Sar Shalom   
; Description: this code calculate and print to the screen the result of the sum(1! + 2! + ....+16!)
; This code uses external loop and internal loop to calculate the sum 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.model small
.data

Dictionary_1 db '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'

.stack 100h
.code
START:
	;setting data segment
	mov ax, @data
	mov ds, ax

	;setting extra segment to screen memory
	mov ax, 0b800h 
	mov es, ax
	xor dx,	dx
	xor ax,	ax
	xor cx, cx
	xor dx, dx
	
	mov cx, 16d
	
	mov bx,0d
	
	OUTLOOP:
		push ax	; first word										; stack: ax
		push bx ; seconed word										; stack: bx, ax
		push dx ; third word									; stack: dx, bx, ax
		
		push cx	; counter											; stack: cx, dx, bx, ax
		;initialize
		xor dx, dx		; dx = 0
		xor bx, bx
		mov ax, 1d	; ax = 1
		INLOOP:
			push ax		; ax into stack								; stack: ax, cx, dx, bx, ax
			mov ax, dx	; ax = dx									; dx contains the third word, and we multipile it with cx 
			mul cx
			mov si, ax
			mov ax, bx												; bx contains the seconed word, and we multipile it with cx
			mul cx
			add si, dx		;  third word							; si has the third word and we sum it with the overflow from the mul
			mov bx, ax
			
			pop ax													;  stack: cx, dx, bx, ax
			mul cx													; ax contains the first word 
			add bx, dx												; sum the seconed word with the overflow from mul
			jnc NoOverFlow_1										; if the sum creates overflow, do increase si by 1 (si contains the third word)
			inc si
			NoOverFlow_1:
			; ax = first word
			; bx = seconed word
			; si = third word
			mov dx, si
			; dx = third word

			LOOP INLOOP
		; sum the new resualts with the old resualts (of ax, bx, dx) 
		pop cx														; stack dx, bx, ax
		mov si, bx					; new bx into si
		pop bx														; stack bx, ax
		add dx,bx	; new dx  into dx
		
		pop bx														; old bx	, stack ax										
		add bx, si	; new bx into bx
		jnc NoOverFlow			; if the sum creates overflow, increase dx
		inc dx
		NoOverFlow:
		pop si
		add ax, si		; new ax into ax
		jnc NoOverFlow_2		; if the sum creates overflow, increase bx
		inc bx
		NoOverFlow_2:
		
		LOOP OUTLOOP
		
		; print to screen (used the code of part 1 with changes and modifications)
		; Please note that the numbers near the push, pop represents the number of registers in the stack and wether or not it went up in the last time (+/-)
		push ax											;1+
		push bx											;2+
		push dx 										;3+			`; stack: dx, bx, ax
	 
		mov cx,0h
		mov cl,12d
		mov di,780h
		mov ah,46d
		mov al, 'A'
		mov es:[di], ax
		add di,2h
		mov al, 'X'
		mov es:[di], ax
		add di,2h
		mov al, ' '
		mov es:[di], ax
		add di,2h
		mov al, '='
		mov es:[di], ax
		add di,2h
		mov al, ' '
		mov es:[di], ax
		add di,2h
		mov ax, dx
	LOP:
		push ax											; 4+			
		
		mov bx, 0Fh
		shl bx, cl
		and ax, bx
		shr ax, cl
		mov si, ax
		mov ax,0h
		mov ah, 46d
		mov al, Dictionary_1[si]
		mov es:[di], ax
		pop ax											;3-
		add di, 2h
		sub cl, 4d
		
		JNZ LOP
		
		pop ax												;2-		stack: bx, ax
		and ax, 000Fh
		mov si, ax
		mov ax,0h
		mov ah, 46d
		mov al, Dictionary_1[si]
		mov es:[di], ax
		add di, 2
		
		pop ax												;1-				; stack: ax				
		push ax		;1+														; stack: bx, ax
		mov cx,0h				
		mov cl,12d
	LOP1:
		push ax													;2+
		mov bx, 0Fh
		shl bx, cl
		and ax, bx
		shr ax, cl
		mov si, ax
		mov ax,0h
		mov ah, 46d
		mov al, Dictionary_1[si]
		mov es:[di], ax
		pop ax														;1-
		add di, 2h
		sub cl, 4d
		
		JNZ LOP1
		
		pop ax														;0-
		and ax, 000Fh
		mov si, ax
		mov ax,0h
		mov ah, 46d
		mov al, Dictionary_1[si]
		mov es:[di], ax
		add di, 2
		
		pop ax												;1-				; stack: ax				
		push ax		;1+														; stack: bx, ax
		mov cx,0h				
		mov cl,12d
	LOP2:
		push ax													;2+
		mov bx, 0Fh
		shl bx, cl
		and ax, bx
		shr ax, cl
		mov si, ax
		mov ax,0h
		mov ah, 46d
		mov al, Dictionary_1[si]
		mov es:[di], ax
		pop ax														;1-
		add di, 2h
		sub cl, 4d
		
		JNZ LOP2
		
		pop ax														;0-
		and ax, 000Fh
		mov si, ax
		mov ax,0h
		mov ah, 46d
		mov al, Dictionary_1[si]
		mov es:[di], ax
		add di, 2
		mov ah,46d
		mov al, 'h'
		mov es:[di], ax
		
	mov ax, 4c00h
	int 21h
end START
