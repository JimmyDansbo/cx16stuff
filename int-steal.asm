*=$0801
!byte $0C,$08,$0A,$00,$9E,$20,$32,$30,$36,$34,$00,$00,$00
*=$0810

vera_addr_low	= $9F20
vera_addr_mid	= $9F21
vera_addr_hi	= $9F22
vera_data0	= $9F23
vera_data1	= $9F24
vera_ctrl	= $9F25
vera_ien	= $9F26
vera_isr	= $9F27


main:
	rts
