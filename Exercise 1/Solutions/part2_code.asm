; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Part2_Code.asm
; due to 05/04/2021
; Ido Sar Shalom  
; Description: This code generates in the middle of the DOS-BOX screen half rectangle below half rectangle 
; each rectangle accordinate to student id 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.model small
.stack 100h
.code
	 ;setting data segment
	 mov ax, @data
	 mov ds, ax

	 ;setting extra segment to screen memory
	 mov ax, 0b800h
	 mov es, ax

	 ;setting ax to represent '0' on green background
	 mov al, '0'
	 mov ah, 46d

	;writing to screen memory
	;Dos-Box matrix 25x80  
	mov al, '3'		; we have changed only the al, because the al contains the       ;number , and we wanted to keep the background and only change the number 
	mov es:[780h+4Ch], ax		; row = 12 (780h = 1920d = row_12),  column = 38 ;(4Ch = 76d =  column _38)
	mov al, '2'
	mov es:[780h+4Eh], ax	;column = 39 (4Eh = 78d)
	mov al, '5'
	mov es:[780h+50h], ax	;column = 40 (50h = 80d)
	mov al, '1'
	mov es:[780h+52h], ax	;column = 41 (52h = 82d)
	mov al, '0'
	mov es:[780h+54h], ax	;column = 42 (54h = 84d)
	mov al, '5'
	mov es:[820h+54h], ax	;column = 42 (54h = 78d) , row = 13 (820h = 2080d = ;row_13)
	mov al, '6'
	mov es:[8C0h+54h], ax	;row = 14 (8C0h = 2240d)
	mov al, '2'
	mov es:[960h+54h], ax	;row = 15 (960h = 2400d)
 
	mov al, '2'
	mov es:[820h+4Ah], ax	;column = 37 (4Ah = 74d) , row = 13 (820h = 2080d = ;row_13)
	mov al, '1'
	mov es:[820h+4Ch], ax	; column = 38 ;(4Ch = 76d)
	mov al, '2'
	mov es:[820h+4Eh], ax	;column = 39 (4Eh = 78d)
	mov al, '4'
	mov es:[820h+50h], ax	;column = 40 (50h = 80d)
	mov al, '1'
	mov es:[820h+52h], ax	;column = 41 (52h = 82d)
	mov al, '0'
	mov es:[8C0h+52h], ax	;column = 41 (52h = 82d), row = 14 (8C0h = 2240d)
	mov al, '1'
	mov es:[960h+52h], ax	;row = 15 (960h = 2400d)
	mov al, '4'
	mov es:[0A00h+52h], ax	;row = 16 (0A00h = 2560d)
 
 ;return to OS
 mov ax, 4c00h
 int 21h
end
