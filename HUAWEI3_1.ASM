.model tiny
.code
org 100h

Start:
    mov ax, 3508h      						; AH = 35h (get interrupt vector), AL = 08h (timer interrupt)
    int 21h
    mov word ptr old_handler, bx  			; offset
    mov word ptr old_handler + 2, es  		; segment

    mov ax, 2508h      						; AH = 25h (set interrupt vector), AL = 08h (timer interrupt)
    mov dx, offset timer_handler  			; DX = offset new handler
    int 21h

    mov dx, offset resident_end
    shr dx, 4
	inc dx
    mov ax, 3100h       					; AH = 31h (terminate and stay resident), AL = 00h (completion code)
    int 21h

timer_handler:
    push ax
    push bx
    push cx
    push dx
    push ds
    push es
    push si
    push di

    mov ax, cs
    mov ds, ax

    call DrawText

    pop di
    pop si
    pop es
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax

    jmp cs:old_handler

    iret
	endp

DrawText:
    mov ax, 0B800h
    mov es, ax

    mov ah, 0Eh         					; yellow text on the black background

	mov si, offset style

	mov di, 8*80*2+24*2
	mov al, [si]
	stosw
	mov al, [si+1]
	mov bx, di
	add bx, 62
Loop_1:
	stosw
	cmp di, bx
	jl Loop_1
	mov al, [si+2]
	stosw

	add di, 94
Loop_3:
	mov al, [si+3]
	stosw
	mov al, [si+4]
	mov bx, di
	add bx, 62
Loop_2:
	stosw
	cmp di, bx
	jl Loop_2
	mov al, [si+5]
	stosw
	add di, 94
	cmp di, 16*80*2+24*2
	jl Loop_3

	mov al, [si+6]
	stosw
	mov al, [si+7]
	mov bx, di
	add bx, 62
Loop_4:
	stosw
	cmp di, bx
	jl Loop_4
	mov al, [si+8]
	stosw

	mov di, 12*80*2+34*2
    mov si, offset text
DrawLoop:
    lodsb
    cmp al, '$'
    je DrawEnd
    stosw
    jmp DrawLoop

DrawEnd:
    ret


old_handler dd ?
text db 'Hello, World!$'
style db '+-+| |+-+$'

resident_end:

end Start
