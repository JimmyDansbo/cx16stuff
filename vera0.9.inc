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

; ******************** Addresses ********************
VERA_PSG_REGISTERS	= $1F9C0
VERA_PALETTE		= $1FA00
VERA_SPRITE_ATTRIBS	= $1FC00

; ******************** Offsets ********************
VERA_PAL_GREEN_BLUE	= 0
VERA_PAL_RED		= 1

VERA_SPRITE_ADDR_LOW	= 0
VERA_SPRITE_ADDR_HIGH	= 1
VERA_SPRITE_X_LOW	= 2
VERA_SPRITE_X_HIGH	= 3
VERA_SPRITE_Y_LOW	= 4
VERA_SPRITE_Y_HIGH	= 5
VERA_SPRITE_CONFIG	= 6
VERA_SPRITE_SIZE	= 7

; ******************** Macros ********************

; **************************************************************************
; Set the VERA Address, do not touch Address increment and DECR values
; **************************************************************************
; INPUT:	.addr = 17 bit address to set 0xxxx or 1xxxx
; USES:		A register
; **************************************************************************
!macro VERA_SET_ADDR .addr {
	lda	VERA_ADDR_HIGH
	!if ^.addr = 0 {
		and	#%11111110	; Clear bit 0 of VERA_ADDR_HIGH
	} else {
		ora	#%00000001	; Set bit 0 of VERA_ADDR_HIGH
	}
	sta	VERA_ADDR_HIGH
	lda	#>.addr			; Set bits 8-15 of VERA_ADDR
	sta	VERA_ADDR_MID
	lda	#<.addr			; Set bits 0-y of VERA_ADDR
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
	and	#$0F			; Remove high nibble of VERA_ADDR HIGH
	ora	#.stride<<4		; Set the new stride in high niblle
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
	lda	VERA_ADDR_HIGH
	!if .decr = 0 {
		and	#%11110111	; Clear bit 3 of VERA_ADDR_HIGH
	} else {
		ora	#%00001000	; Set bit 3 of VERA_ADDR_HIGH
	}
	sta	VERA_ADDR_HIGH
	+VERA_SET_ADDR .addr, .stride
}

; **************************************************************************
; Set the VERA DCSEL bit
; **************************************************************************
; INPUT:	.sel = Value DCSEL bit should be set to
; USES:		A register
; **************************************************************************
!macro VERA_DCSEL .sel {
	lda	VERA_CTRL
	!if .sel = 0 {
		and	#%11111101	; Clear DCSEL bit
	} else {
		ora	#%00000010	; Set DCSEL bit
	}
	sta	VERA_CTRL
}

; **************************************************************************
; Set the VERA ADDRSEL bit
; **************************************************************************
; INPUT:	.sel = Value ADDRSEL bit should be set to
; USES:		A register
; **************************************************************************
!macro VERA_ADDRSEL .sel {
	lda	VERA_CTRL
	!if .sel = 0 {
		and	#%11111110	; Clear ADDRSEL bit
	} else {
		ora	#%00000001	; Set ADDRSEL bit
	}
	sta	VERA_CTRL
}

; **************************************************************************
; Reset the VERA
; **************************************************************************
; USES:		A register
; **************************************************************************
!macro VERA_RESET {
	lda	#%10000000		; Set the RESET bit in CTRL register
	sta	VERA_CTRL
}

!macro VERA_SET_SPRITES .ena {
	lda	VERA_DC_VIDEO
	!if .ena = 0 {
		and	#%10111111
	} else {
		ora	#%01000000
	}
	sta	VERA_DC_VIDEO
}

!macro VERA_SET_L0 .ena {
	lda	VERA_DC_VIDEO
	!if .ena = 0 {
		and	#%11101111
	} else {
		ora	#%00010000
	}
	sta	VERA_DC_VIDEO
}

!macro VERA_SET_L1 .ena {
	lda	VERA_DC_VIDEO
	!if .ena = 0 {
		and	#%11011111
	} else {
		ora	#%00100000
	}
	sta	VERA_DC_VIDEO
}
