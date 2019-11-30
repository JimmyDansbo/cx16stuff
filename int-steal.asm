;*************************************************************************
; Small program to demonstrate the effects of 'stealing' the IRQ vector
; Stealing refers to replacing the IRQ vector with an address to a new
; interrupt handler and not having that interrupt handler call the
; original interrupt handler
;
; Information on how to use the interrupt was found here:
; https://github.com/commanderx16/x16-emulator/wiki/(ASM-Programming)-Interrupts-and-interrupt-handling
; I used this example code to actually write the code:
; https://gist.github.com/rsbohn/316908bc9cfc6c2b03d8aa2192aa3d0b
; And finally I used the VERA documentation for information on the
; IEN and ISR ports.
; https://github.com/commanderx16/x16-docs/blob/master/VERA%20Programmer's%20Reference.md
;*************************************************************************
*=$0801
!byte $0C,$08,$0A,$00,$9E,$20,$32,$30,$36,$34,$00,$00,$00
*=$0810

; When this constant is 0, the program behaves nicely and continues to
; the original interrupt handler.
; When it is set to 1, the program just ends the IRQ.
Steal_IRQ 	= 0

vera_addr_low	= $9F20
vera_addr_mid	= $9F21
vera_addr_hi	= $9F22
vera_data0	= $9F23
vera_data1	= $9F24
vera_ctrl	= $9F25
vera_ien	= $9F26
vera_isr	= $9F27

CHRIN		= $FFCF
CHROUT		= $FFD2
GETJOY		= $FF06

; Location holding address of original IRQ handler
IRQ_Vector	= $0314

;*************************************************************************
; The main program will setup the VERA, set a new interrrupt handler
; and then run a loop that just reads the status of JOY1 and prints
; it as a hexadecimal number to screen.
;*************************************************************************
main:
	lda	#0			; Tell VERA that we will be
	sta	vera_ctrl		; using data port 0

	jsr	SetNewIRQ		; Set the new interrupt handler

.tloop:
	jsr	GETJOY			; Update Joystik information
	; According to the documentation, status for JOY1 should be
	; found at $02BB - This does not work
	; Looking at other code and debug'ing through the KERNAL I
	; found that JOY1 status is at $02BC
	lda	$02BC			; Load A with JOY1 status
	jsr	PrintHx			; Print contents of A as hex
	jmp	.tloop
	rts

;*************************************************************************
; This function saves the address to the original interrupt handler and
; replaces it with the address to MyIRQHandler
;*************************************************************************
SetNewIRQ:
	; Old_IRQ looks like this: JMP $FFFF
	; This is done to ease jumping forward to the original handler
	; It also means that we can not just write the original address
	; to Old_IRQ, because that would overwrite the JMP op-code.
	; Instead we write the low byte to Old_IRQ+1 and the high byte
	; to Old_IRQ+2
	lda	IRQ_Vector
	sta	Old_IRQ+1
	lda	IRQ_Vector+1
	sta	Old_IRQ+2

	sei				; Disable interrupts
	lda	#1			; Tell VERA that we want it to do
	sta	vera_ien		; VSYNC interrupts

	; Replace the original address with the address of MyIRQHandler
	lda	#<MyIRQHandler
	sta	IRQ_Vector
	lda	#>MyIRQHandler
	sta	IRQ_Vector+1
	cli				; Enable interrupts
	rts

;*************************************************************************
; This function increments the value in $00 and uses VERA to print the
; corresponding character in the upper right corner of the screen
; This assumes that we are running in 80 column mode.
;*************************************************************************
MyIRQHandler:
	lda	vera_isr		; Check if the interrupt is
	and	#$01			; VSYNC from VERA
					; If not jump to end
; Here the ACME assembler checks the status of the Steal_IRQ constant
; to figure out where to branch to
!if Steal_IRQ = 1 {
	beq	irq_end			; End the IRQ (steal)
} else {
	beq	Old_IRQ			; Jump to old interrupt handler
}
	inc	$00			; Increment value in $00

	lda	#1			; Reset the VERA interrupt
	sta	vera_isr

	lda	vera_addr_hi		; Save the current VERA address
	sta	$03
	lda	vera_addr_mid
	sta	$04
	lda	vera_addr_low
	sta	$05

	lda	#0			; Set the new VERA address
	sta	vera_addr_hi		; Top right corner in 80 column mode
	sta	vera_addr_mid
	lda	#158
	sta	vera_addr_low
	lda	$00			; Write the value in $00 to screen
	sta	vera_data0

	lda	$03			; Restore VERA address
	sta	vera_addr_hi
	lda	$04
	sta	vera_addr_mid
	lda	$05
	sta	vera_addr_low
; Again the ACME assembler checks the status of the Steal_IRQ constant
; If it is 0, we continue on to the original interrupt handler
!if Steal_IRQ = 0 {
	jmp	Old_IRQ
}
	; End the IRQ (steal) by pulling Y,X and A register from stack
	; and doing an RTI (ReTurn from Interrupt)
irq_end:
	pla				; Pure 6502 assembler can not
	tay				; push and pull register X and Y
	pla				; directly so we need to use
	tax				; register A and then transfer
	pla				; the value to the correct register
	rti

	; The address pointed to by JMP is just a dummy, it will be
	; overwritten by the SetNewIRQ function so it points to the
	; original interrupt handler
Old_IRQ:
	jmp	$FFFF

;*************************************************************************
; This functions prints the contents of register A as a hexadecimal
; number. It prints the number where the cursor is and appends two spaces
; The function is roughly copied from here:
; http://forum.6502.org/viewtopic.php?f=2&t=3164
;*************************************************************************
PrintHx:
	pha			; Save A on stack for later use
	lsr			; Shift high nibble down to low nibble
	lsr
	lsr
	lsr
	cmp	#$0A		; If the number is larger than #$9
	bcs	msb_atf		; Branch to taking care of letters
	adc	#$30		; Add #$30 to number for petscii
	jsr	CHROUT		; Print high nibble of number
	jmp	num_lsb		; Go handle low nibble of number
msb_atf:
	clc
	adc	#55		; Add #55 to number for petscii letters
	jsr	CHROUT		; Print high nibble of number
num_lsb:
	pla			; Restore A from stack
	and	#$0F		; zero out high nibble
	cmp	#$0A		; If the number is larger than #$9
	bcs	lsb_atf		; Branch to taking care of letters
	adc	#$30		; Add #$30 to number for petscii
	jsr	CHROUT		; Print low nibble of number
	jmp	.pend		; We are done, go to end
lsb_atf:
	clc
	adc	#55		; Add #55 to number for petscii letters
	jsr	CHROUT		; Print low nibble of number
.pend
	lda	#' '		; Add 2 spaces after the number
	jsr	CHROUT
	lda	#' '
	jsr	CHROUT
	rts
