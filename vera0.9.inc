!ifdef VERA_INC !eof
VERA_INC=1

; ******************** Registers ********************
VERA_BASE		= $9F20
VERA_ADDR_LOW		= VERA_BASE
VERA_ADDR_MID		= VERA_BASE+1
VERA_ADDR_HIGH		= VERA_BASE+2
VERA_DATA0		= VERA_BASE+3
VERA_DATA1		= VERA_BASE+4
VERA_CTRL		= VERA_BASE+5
VERA_IEN		= VERA_BASE+6
VERA_ISR		= VERA_BASE+7
VERA_IRQLINE_L		= VERA_BASE+8
VERA_DC			= VERA_BASE+9
VERA_DC_VIDEO		= VERA_DC	; DCSEL=0
VERA_DC_HSCALE		= VERA_DC+1	; DCSEL=0
VERA_DC_VSCALE		= VERA_DC+2	; DCSEL=0
VERA_DC_BORDER		= VERA_DC+3	; DCSEL=0
VERA_DC_HSTART		= VERA_DC	; DCSEL=1
VERA_DC_HSTOP		= VERA_DC+1	; DCSEL=1
VECA_DC_VSTART		= VERA_DC+2	; DCSEL=1
VERA_DC_VSTOP		= VERA_DC+3	; DCSEL=1
VERA_L0			= VERA_DC+4
VERA_L0_CONFIG		= VERA_L0
VERA_L0_MAPBASE		= VERA_L0+1
VERA_L0_TILEBASE	= VERA_L0+2
VERA_L0_HSCROLL_L	= VERA_L0+3
VERA_L0_HSCROLL_H	= VERA_L0+4
VERA_L0_VSCROLL_L	= VERA_L0+5
VERA_L0_VSCROLL_H	= VERA_L0+6
VERA_L1			= VERA_L0+7
VERA_L1_CONFIG		= VERA_L1
VERA_L1_MAPBASE		= VERA_L1+1
VERA_L1_TILEBASE	= VERA_L1+2
VERA_L1_HSCROLL_L	= VERA_L1+3
VERA_L1_HSCROLL_H	= VERA_L1+4
VERA_L1_VSCROLL_L	= VERA_L1+5
VERA_L1_VSCROLL_H	= VERA_L1+6
VERA_AUDIO		= VERA_L1+7
VERA_AUDIO_CTRL		= VERA_AUDIO
VERA_AUDIO_RATE		= VERA_AUDIO+1
VERA_AUDIO_DATA		= VERA_AUDIO+2
VERA_SPI_DATA		= VERA_AUDIO+3
VERA_SPI_CTRL		= VERA_AUDIO+4

; ******************** Macros ********************

; **************************************************************************
; Set the VERA Address, do not touch Address increment and DECR values
; **************************************************************************
; INPUT:	.addr = 17 bit address to set 0xxxx or 1xxxx
; USES:		A register
; **************************************************************************
!macro VERA_SET_ADDR .addr {
	lda	#^.addr
	bne	+
	lda	VERA_ADDR_HIGH
	and	#%11111110
	bra	++
+	lda	VERA_ADDR_HIGH
	ora	#%00000001
++	sta	VERA_ADDR_HIGH
	lda	#>.addr
	sta	VERA_ADDR_MID
	lda	#<.addr
	sta	VERA_ADDR_LOW
}

; **************************************************************************
; Set the VERA Address and stride do not touch DECR value
; **************************************************************************
; INPUT:	.addr = 17 bit address to set 0xxxx or 1xxxx
;		.stride = 4 bit inc/dec value
; USES:		A register
; **************************************************************************
!macro VERA_SET_ADDR .addr, .stride {
	lda	VERA_ADDR_HIGH
	and	#$0F
	ora	#.stride<<4
	sta	VERA_ADDR_HIGH
	+VERA_SET_ADDR .addr
}

; **************************************************************************
; Set the VERA Address, stride and DECR values
; **************************************************************************
; INPUT:	.addr = 17 bit address to set 0xxxx or 1xxxx
;		.stride = 4 bit inc/dec value
;		.decr = 1 bit flag (0=increment, 1=decrement)
; USES:		A register
; **************************************************************************
!macro VERA_SET_ADDR .addr, .stride, .decr {
	lda	#.decr
	bne	+
	lda	VERA_ADDR_HIGH
	and	#%11110111
	bra	++
+	lda	VERA_ADDR_HIGH
	ora	#%00001000
++	sta	VERA_ADDR_HIGH
	+VERA_SET_ADDR .addr, .stride
}
