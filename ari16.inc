!ifdef ARI16_INC !eof
ARI16_INC=1

;****************************************************************************
; Increment a 16 bit value
;****************************************************************************
; INPUT:	.val - The value that should be incremented
;****************************************************************************
!macro INC16 .val {
	inc	.val		; Increment low byte of value
	bne	+		; If not 0, jump to end
	inc	.val+1		; Increment high byte of value
+
}

;****************************************************************************
; Decrement a 16 bit value
;****************************************************************************
; INPUT:	.val - The value that should be decremented
;****************************************************************************
!macro DEC16 .val {
	lda	.val
	bne	.nodec
	dec	.val+1
.nodec:	dec	.val
}

;****************************************************************************
; Rotate Left on a 16 bit value - 0 shifted into bit0
;****************************************************************************
; INPUT:	.val - The value that should be shifted left
;****************************************************************************
!macro ASL16 .val {
	asl	.val
	rol	.val+1
}

;****************************************************************************
; Arithmetic Shift Left on a 16 bit value - carry-bit shifted into bit0
;****************************************************************************
; INPUT:	.val - The value that should be shifted left
;****************************************************************************
!macro ROL16 .val {
	rol	.val
	rol	.val+1
}

;****************************************************************************
; Logical Shift Right on a 16 bit value - 0 shifted into bit15
;****************************************************************************
; INPUT:	.val - The value that should be shifted right
;****************************************************************************
!macro LSR16 .val {
	lsr	.val
	ror	.val+1
}

;****************************************************************************
; Rotate Right on a 16 bit value - carry-bit shifted into bit15
;****************************************************************************
; INPUT:	.val - The value that should be shifted right
;****************************************************************************
!macro ROR16 .val {
	ror	.val
	ror	.val+1
}

;****************************************************************************
; Add accumulator and carry to 16 bit value
;****************************************************************************
; INPUT:	.val1 - The 16 bit value that accumulator should be added to
; OUTPUT:	.val1 - contains result after addition
;****************************************************************************
!macro ADC16 .val1 {
	adc	.val1
	sta	.val1
	lda	.val1+1
	adc	#0
	sta	.val1+1
}

;****************************************************************************
; Add carry and two 16 bit values
;****************************************************************************
; INPUT:	.val1 - 1st 16 bit value
;		.val2 - 2nd 16 bit value
; OUTPUT:	.val1 - contains result after addition
;****************************************************************************
!macro ADC16 .val1, .val2 {
	lda	.val1
	adc	.val2
	sta	.val1
	lda	.val1+1
	adc	.val2+1
	sta	.val1+1
}

;****************************************************************************
; Subtract accumulator from 16 bit value
;****************************************************************************
; INPUT:	.val1 - 16bit value to subtract accumulator from
; OUTPUT:	.val1 - contains result after subtraction
;****************************************************************************
!macro SBC16 .val1 {
	eor	#$FF
	adc	.val1
	sta	.val1
	lda	.val1+1
	sbc	#0
	sta	.val1+1
}

;****************************************************************************
; Subtract two 16 bit values
;****************************************************************************
; INPUT:	.val1 - 16bit value to subtract from
;		.val2 - 16bit value to subtract
; OUTPUT:	.val1 - contains result after subtraction
;****************************************************************************
!macro SBC16 .val1, .val2 {
	lda	.val1
	sbc	.val2
	sta	.val1
	lda	.val1+1
	sbc	.val2+1
	sta	.val1+1
}
