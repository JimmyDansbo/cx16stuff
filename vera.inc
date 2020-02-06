!ifdef VERA_INC !eof
VERA_INC=1

VERA_BASE		= $9F20
VERA_ADDR_LOW		= VERA_BASE+0
VERA_ADDR_HIGH		= VERA_BASE+1
VERA_ADDR_BANK		= VERA_BASE+2
VERA_DATA0		= VERA_BASE+3
VERA_DATA1		= VERA_BASE+4
VERA_CTRL		= VERA_BASE+5
VERA_IEN		= VERA_BASE+6
VERA_ISR		= VERA_BASE+7

VERA_DISP_COMPOSER	= $F0000
VERA_PALETTE		= $F1000
VERA_L0_REGS		= $F2000
VERA_L1_REGS		= $F3000
VERA_SPRITE_REG		= $F4000
VERA_SPRITE_ATTRIBS	= $F5000

!macro	VERA_SET_ADDR .bank, .addrhigh, .addrlow {
	lda	VERA_ADDR_BANK
	and	#$F0
	ora	#.bank
	sta	VERA_ADDR_BANK
	lda	#.addrhigh
	sta	VERA_ADDR_HIGH
	lda	#.addrlow
	sta	VERA_ADDR_LOW
}

!macro	VERA_SET_ADDR .bank, .addrhigh, .addrlow, .stride {
	lda	#(.bank | (.stride << 4))
	sta	VERA_ADDR_BANK
	lda	#.addrhigh
	sta	VERA_ADDR_HIGH
	lda	#.addrlow
	sta	VERA_ADDR_LOW
}
