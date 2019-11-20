
*=$0801

!byte $0C,$08,$0A,$00,$9E,$20,$32,$30,$36,$34,$00,$00,$00

*=$0810			; Here starts the real program

CHROUT=$FFD2

	jsr	PrintBCDNum
	lda	#13		; Print a newline
	jsr	CHROUT
	jsr	IncBCDNum
	jsr	PrintBCDNum
	rts

PrintBCDNum:
	lda	.BCDnum		; Load number
	lsr			; Shift high nibble down to low nibble
	lsr
	lsr
	lsr
	and	#$0F		; Ensure high nibble is 0
	clc
	adc	#$30		; Convert low nibble to PETSCII character
	jsr	CHROUT
	lda	.BCDnum		; Load number again to work on low nibble
	and	#$0F		; Ensure high nibble is 0
	clc
	adc	#$30		; Convert low nibble to PETSCII character
	jsr	CHROUT
	rts

; Only ADC and SBC are able to do Decimal/BCD arithmetic
; INC, INY, INX, DEC, DEY & DEX work the same way regardless
; of the Decimal flag
IncBCDNum:
	sed			; Set Decimal/BCD mode
	lda	.BCDnum
	clc
	adc	#$01
	sta	.BCDnum
	cld			; Reset Decimal/BCD mode
	rts

.BCDnum	!byte	$19
