.model tiny
.code
org 100h

;-------------------------------------------------
; Resident program
;-------------------------------------------------
Start:
    cli
	mov ax, 3508h      						; AH = 35h (get interrupt vector), AL = 08h (timer interrupt)
    int 21h
    mov word ptr oldHandler, bx  			; offset
    mov word ptr oldHandler + 2, es  		; segment

    mov ax, 2508h      						; AH = 25h (set interrupt vector), AL = 08h (timer interrupt)
    mov dx, offset NewHandler  				; DX = offset new handler
    int 21h
	sti

    mov dx, offset residentEnd
    shr dx, 4
	inc dx
    mov ax, 3100h       					; AH = 31h (terminate and stay resident), AL = 00h (completion code)
    int 21h

;-------------------------------------------------
; New interrupt handler
;-------------------------------------------------
NewHandler:
    push ds
    push es
    push si
    push di
	push dx
    push cx
    push bx
    push ax

    mov ax, cs
    mov ds, ax

	pop ax
	push ax

    call DrawRegisters

	pop ax
    pop bx
    pop cx
    pop dx
    pop di
    pop si
    pop es
    pop ds

    jmp cs:oldHandler

    iret
	endp

;-------------------------------------------------
; Draw a frame with registers
;-------------------------------------------------
DrawRegisters:
    push 0B800h
    pop es

	push cx
	push bx
	push ax

;---display register names------------------------
	mov ah, 21
	mov di, 3*80*2+34
	mov si, offset nameAX
	call PrintString

	mov di, 4*80*2+34
	mov si, offset nameBX
	call PrintString

	mov di, 5*80*2+34
	mov si, offset nameCX
	call PrintString

	mov di, 6*80*2+34
	mov si, offset nameDX
	call PrintString
;-------------------------------------------------

;---display register values-----------------------
	pop ax
	mov di, 3*80*2+44
	call PrintHex

	pop ax
	mov di, 4*80*2+44
	call PrintHex

	pop ax
	mov di, 5*80*2+44
	call PrintHex

	mov di, 6*80*2+44
	mov ax, dx
	call PrintHex
;-------------------------------------------------

;---display frame---------------------------------
	mov ah, 21
	mov si, offset style
	mov di, 32
	mov al, [si]
	stosw
	mov al, [si+1]
	mov bx, di
	add bx, 18
loop_1:
	stosw
	cmp di, bx
	jl loop_1
	mov al, [si+2]
	stosw
	add di, 138
	mov al, [si+3]
	stosw
	add di, 18
	stosw
	add di, 138
	mov al, [si]
	stosw
	mov al, [si+1]
	mov bx, di
	add bx, 18
loop_5:
	stosw
	cmp di, bx
	jl loop_5
	mov al, [si+2]
	stosw
	mov al, [si+3]
	mov cx, 4
loop_6:
	add di, 138
	stosw
	add di, 18
	stosw
	loop loop_6
	add di, 138
	mov al, [si+6]
	stosw
	mov al, [si+7]
	mov bx, di
	add bx, 18
loop_4:
	stosw
	cmp di, bx
	jl loop_4
	mov al, [si+8]
	stosw
;-------------------------------------------------

;---display text----------------------------------
	mov di, 80*2+34
    mov si, offset text
	call PrintString
;-------------------------------------------------

    ret

;-------------------------------------------------
; Display the hex value of the AX register
;-------------------------------------------------
PrintHex:
	mov bx, ax
	mov cx, 4
getNumber:
    mov ax, bx
    and ax, 0F000h              ; bitmask: 1111 0000 0000 0000
    shr ax, 12
    call ToASCII
    mov es:[di], al
    inc di
    mov byte ptr es:[di], 21
    inc di
    shl bx, 4
    loop getNumber
    ret
    endp

;-------------------------------------------------
; Convert the AL register to ASCII
;-------------------------------------------------
ToASCII:
    add al, '0'
    cmp al, '9'
    jbe doneASCII
    add al, 7
doneASCII:
    ret

;-------------------------------------------------
; Display a string from the SI register by the DI
; offset in the video memory segment.
;-------------------------------------------------
PrintString:
	lodsb
	cmp al, '$'
	je doneString
	stosw
	jmp PrintString
doneString:
	ret
	endp

;---------------------Data------------------------
oldHandler dd ?

style  db '+-+| |+-+$'
text   db 'Registers$'
nameAX db 'AX   $'
nameBX db 'BX   $'
nameCX db 'CX   $'
nameDX db 'DX   $'
;-------------------------------------------------

residentEnd:

end Start
