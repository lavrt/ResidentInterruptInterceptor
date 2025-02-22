        .model  tiny
        .code
        org     100h

Start:
        mov     ax, 0
        mov     es, ax
        mov     bx, 09h*4

        mov     ax, es:[bx]
        mov     OldHandlerOfs, ax
        mov     ax, es:[bx+2]
        mov     OldHandlerSeg, ax

        cli
        mov     es:[bx], offset Handler
        push    cs
        pop     ax
        mov     es:[bx+2], ax
        sti
        mov     ax, 3100h
        mov     dx, offset EndOfProgram
        shr     dx, 4
        inc     dx
        int     21h
Handler:
        push    ax bx es
        mov     ax, 0b800h
        mov     es, ax
        mov     ah, 4eh
        mov     bx, 5*80*2+40*2
        cli
        in      al, 60h
        mov     es:[bx], ax
        pop     es bx ax
        db      0eah
OldHandlerOfs   dw 0
OldHandlerSeg   dw 0
EndOfProgram:
        end     Start
