!cpu w65c02
*=$0801
!byte $0C,$08,$0A,$00,$9E,$20,$32,$30,$36,$34,$00,$00,$00
*=$0810

BSOUT=$FFD2

COL_BLACK	= $0
COL_WHITE	= $1
COL_RED		= $2
COL_CYAN	= $3
COL_PURPLE	= $4
COL_GREEN	= $5
COL_BLUE	= $6
COL_YELLOW	= $7
COL_ORANGE	= $8
COL_BROWN	= $9
COL_LIGHT_RED	= $A
COL_DARK_GREY	= $B
COL_GRAY	= $C
COL_LIGHT_GREEN	= $D
COL_LIGHT_BLUE	= $E
COL_LIGHT_GRAY	= $F

PET_BLACK	= $90
PET_WHITE	= $0F
PET_RED		= $1C
PET_CYAN	= $9F
PET_PURPLE	= $9C
PET_GREEN	= $1E
PET_BLUE	= $1F
PET_YELLOW	= $9E
PET_ORANGE	= $81
PET_BROWN	= $95
PET_LIGHT_RED	= $96
PET_DARK_GREY	= $97
PET_GRAY	= $98
PET_LIGHT_GREEN	= $99
PET_LIGHT_BLUE	= $9A
PET_LIGHE_GRAY	= $9B

PET_SWAP	= $01

main:
	lda	#(COL_BLACK<<4)|COL_RED
	sta	col_var
	jsr	Col_change
	rts


; ***************************************************************************
; Set background- and foreground color through PETSCII codes
; ***************************************************************************
; INPUTS:	$02 = Color code. High nibble background color
;		                  Low nibble, foreground color
; ***************************************************************************
Col_change:
	pha			; Save .A and .X
	phx			; They are used by this function
	lda	col_var		; Load the color code
	lsr			; Shift high-nibble to low = get bg color
	lsr
	lsr
	lsr
	tax			; Use .X as index
	lda	Colors,x	; Load the PETSCII color code correspondig to color index
	jsr	BSOUT		; Set the FG color
	lda	#PET_SWAP	; Swap FG/BG colors
	jsr	BSOUT
	lda	col_var		; Load the color code
	and	#$0F		; Ensure high-nibble is 0 = get fg color
	tax			; Use .X as index
	lda	Colors,x	; Load the PETSCII color code corresponding to color index
	jsr	BSOUT
	plx			; Restore .X and .A
	pla
	rts

; List of PETSCII color codes in the color index order
Colors	!byte	$90,$05,$1C,$9F,$1E,$1F,$9E,$81,$95,$96,$97,$98,$99,$9A,$9B
; Variable to hold color information
col_var !byte	$00
