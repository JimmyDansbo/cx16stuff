!cpu 65c02
*=$0801				; Assembled code should start at $0801
				; (where BASIC programs start)
				; The real program starts at $0810 = 2064
!byte $0C,$08			; $080C - pointer to next line of BASIC code
!byte $0A,$00			; 2-byte line number ($000A = 10)
!byte $9E			; SYS BASIC token
!byte $20			; [space]
!byte $32,$30,$37,$30		; $32="2",$30="0",$37="7",$30="0"
				; (ASCII encoded nums for dec starting addr)
!byte $00			; End of Line
!byte $12, $08 ; This is address $080C containing
	; 2-byte pointer to next line of BASIC code
!byte $14, $00 ; Line 20
!byte $A2 ; NEW BASIC token
!byte $00 ; [ end of line ]
!byte $00,$00 ; ($0000 = end of program)
!byte $00,$00	
				
*=$0816				; The actual program starts here


Old_irq_handler	= $0404		; 2 bytes to hold old IRQ handler address
Jiffie_cnt	= $0403		; 1 byte to count jiffies, 60 jiffies in a second.
Hour		= $0400
Minute		= $0401
Second		= $0402
IRQ_clock	= $0406		; Start address of IRQ handler after copy

From_ptr	= $22		; ZP addresses used as ponters to copy
To_ptr		= $24		; Show_clock routine

IRQVECTOR	= $0314

VERA_ADDR_H	= $9F22
VERA_ADDR_M	= $9F21
VERA_ADDR_L	= $9F20
VERA_DATA0	= $9F23

; Write a BCD encoded number to screen.
; Assumes that correct address has been set before call and that VERA has
; been set to increment by 2 for each write.
!macro WRITE_BCD_NUM .num {
	lda	.num		; Load the number to write to screen
	lsr			; Shift high-nibble to low
	lsr
	lsr
	lsr
	ora	#$30		; OR with $30 to convert it to PETSCII
	sta	VERA_DATA0	; Write character to VERA
	lda	.num		; Load the number to write to screen again
	and	#$0F		; Set high-nibble to zeroes.
	ora	#$30		; OR with £40 to convert it to PETSCII
	sta	VERA_DATA0	; Write character to VERA
}

; Increment a 16 bit number
; .num points to low byte of the 16bit number
!macro INC16 .num {
	inc	.num		; Increment low-byte
	bne	.end		; If it is not zero, jump to end
	inc	.num+1		; Increment high-byte
.end:
}

main:
	; Copy Show_clock routine to $0406
	lda	#<IRQ_clock	; low-byte of IRQ_clock
	sta	To_ptr
	lda	#>IRQ_clock	; high-byte of IRQ_clock
	sta	To_ptr+1
	lda	#<Show_clock	; low-byte of Show_clock
	sta	From_ptr
	lda	#>Show_clock	; high-byte of Show_clock
	sta	From_ptr+1

@loop:	lda	(From_ptr)	; copy a byte from From_ptr to To_ptr
	sta	(To_ptr)

	+INC16  From_ptr
	+INC16	To_ptr

	lda	From_ptr	; Compare From_ptr with End_show_clock
	cmp	#<End_show_clock ;as long as it is not the same, loop back
	bne	@loop
	lda	From_ptr+1	; If low-byte is equal, test high-byte
	cmp	#>End_show_clock ;if not equal, loop back
	bne	@loop

	; Store zeroes in hours, minutes and seconds variables
	stz	Hour
	stz	Minute
	stz	Second
	; Initialize Jiffie_cnt variable
	lda	#60
	sta	Jiffie_cnt

	; Save address to the original interrupt handler
	lda	IRQVECTOR
	sta	Old_irq_handler
	lda	IRQVECTOR+1
	sta	Old_irq_handler+1

	; Install Show_clock/IRQ_clock as interrupt handler
	sei			; Disable interrupts
	lda	#<IRQ_clock	; Write address of local interrupt
	sta	IRQVECTOR	; handler to the interrupt
	lda	#>IRQ_clock	; vector address ($0314)
	sta	IRQVECTOR+1
	cli			; Enable interrupts

	rts

Show_clock:
	; Save VERA registers
	lda	VERA_ADDR_H
	pha
	lda	VERA_ADDR_M
	pha
	lda	VERA_ADDR_L
	pha

	; Set start address of clock and ensure VERA increments correctly
	; This is top right corner in 80x60 mode
	lda 	#$B0
	sta	VERA_ADDR_M
	lda	#144
	sta	VERA_ADDR_L
	lda	#$21
	sta	VERA_ADDR_H

	; Write hours
	+WRITE_BCD_NUM Hour
	lda	#':'
	sta	VERA_DATA0
	; Write minutes
	+WRITE_BCD_NUM Minute
	lda	#':'
	sta	VERA_DATA0
	; Write seconds
	+WRITE_BCD_NUM Second

	; Restore VERA registers
	pla
	sta	VERA_ADDR_L
	pla
	sta	VERA_ADDR_M
	pla
	sta	VERA_ADDR_H

	dec	Jiffie_cnt
	beq	@inc_sec
	jmp	(Old_irq_handler)
	; Run every 60 jiffies = 1 second
@inc_sec:
	lda	#60		; Reset Jiffie_cnt
	sta	Jiffie_cnt

	sed			; Enter BCD mode
	lda	Second		; Increment Second
	clc
	adc	#1
	cmp	#$60
	cld			; Exit BCD mode
	beq	@inc_min
	sta	Second
	bra	@continue
@inc_min:
	stz	Second		; Store 0 in Second to make it wrap around
	sed
	lda	Minute		; Increment Minute
	clc
	adc	#1
	cmp	#$60
	cld
	beq	@inc_hour
	sta	Minute
	bra	@continue
@inc_hour:
	stz	Minute		; Store 0 in Minute to make it wrap around
	sed
	lda	Hour		; Increment Hour
	clc
	adc	#1
	cmp	#$24
	cld
	beq	@rst_hour
	sta	Hour
	bra	@continue
@rst_hour:
	stz	Hour		; Store 0 in Hour to make it wrap around
@continue:
	jmp	(Old_irq_handler)
End_show_clock:
