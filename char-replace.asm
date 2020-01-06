!to "chartest.prg",cbm
*=$0801
	!src	"cx16.inc"
	+SYS_LINE
*=$0810

VERA_ADDR_LO	= $9F20
VERA_ADDR_MID	= VERA_ADDR_LO+1
VERA_ADDR_HI	= VERA_ADDR_LO+2
VERA_DATA0	= VERA_ADDR_LO+3
VERA_DATA1	= VERA_ADDR_LO+4
VERA_CTRL	= VERA_ADDR_LO+5
CHROUT		= $FFD2
CHRIN		= $FFCF

	lda	#(WHITE<<4)+BLACK; White background, black text
	sta	COLORPORT
	lda	#147		; Clear screen
	jsr	CHROUT

	lda	#0
	sta	VERA_CTRL	; Use Data port 0

	lda	#$10
	sta	VERA_ADDR_HI	; Increment by 1, bank 0
	lda	#$FE		; Set address to
	sta	VERA_ADDR_MID	; $F800+($dd*$8)=$FEE8
	lda	#$E8		; This places the custom chars
	sta	VERA_ADDR_LO	; at the end of the font table

	lda	#<CHARS		; Save address of CHARS in ZP
	sta	TMP0
	lda	#>CHARS
	sta	TMP0+1

	ldy	#0
	ldx	#35		; number of characters to replace in font
.outloop:
	txa			; Save .X on stack
	pha
	ldx	#8		; Counter for bytes in a character
-	lda	(TMP0),y
	sta	VERA_DATA0
	clc			; Add 1 to address storead in ZP
	lda	#1
	adc	TMP0
	sta	TMP0
	lda	#0
	adc	TMP1
	sta	TMP1
	dex
	bne	-		; Jump back and do next byte of character
	pla			; Pull .X from stack
	tax
	dex
	bne	.outloop	; While we have not don all chars, jump back

; ******* Code below is just for showing that the characters have been *****
; ******* placed into VERAs memory. ****************************************


	ldy	#1
	ldx	#1
	jsr	GotoXY		; Move to 1x1
	ldx	#<.lin01
	ldy	#>.lin01
	jsr	PrintStr	; Print .lin01

	ldy	#3		; Move to 1x3
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin02
	ldy	#>.lin02
	jsr	PrintStr	; Print .lin02

	ldy	#5
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin03
	ldy	#>.lin03
	jsr	PrintStr

	ldy	#7
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin04
	ldy	#>.lin04
	jsr	PrintStr

	ldy	#9
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin05
	ldy	#>.lin05
	jsr	PrintStr

	ldy	#11
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin06
	ldy	#>.lin06
	jsr	PrintStr

	ldy	#13
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin07
	ldy	#>.lin07
	jsr	PrintStr

	ldy	#15
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin08
	ldy	#>.lin08
	jsr	PrintStr

	ldy	#17
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin09
	ldy	#>.lin09
	jsr	PrintStr

	ldy	#19
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin10
	ldy	#>.lin10
	jsr	PrintStr

	ldy	#21
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin11
	ldy	#>.lin11
	jsr	PrintStr

	ldy	#23
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin12
	ldy	#>.lin12
	jsr	PrintStr

	ldy	#25
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin13
	ldy	#>.lin13
	jsr	PrintStr

	ldy	#27
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin14
	ldy	#>.lin14
	jsr	PrintStr

	ldy	#29
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin15
	ldy	#>.lin15
	jsr	PrintStr

	ldy	#31
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin16
	ldy	#>.lin16
	jsr	PrintStr

	ldy	#33
	ldx	#1
	jsr	GotoXY
	ldx	#<.lin17
	ldy	#>.lin17
	jsr	PrintStr

	lda	#2
	jsr	SetInc


	ldx	#1
	ldy	#40
	jsr	GotoXY
	ldx	#<.gate1
	ldy	#>.gate1
	jsr	PrintStr

	ldx	#1
	ldy	#41
	jsr	GotoXY
	ldx	#<.gate2
	ldy	#>.gate2
	jsr	PrintStr

	ldx	#1
	ldy	#42
	jsr	GotoXY
	ldx	#<.gate3
	ldy	#>.gate3
	jsr	PrintStr

	ldx	#1
	ldy	#39
	jsr	GotoXY
	ldx	#<.gnames
	ldy	#>.gnames
	jsr	PrintStr

	jsr	CHRIN


	rts

; X = X coordinate
; Y = Y coordinate
GotoXY:
	; In text mode, Y coordinate is just stored in mid address
	sty	VERA_ADDR_MID

	; In text mode, X coordinate is stored in low address, but
	; each character takes up 2 bytes. First one for the character
	; second one for the colors (BG/FG)
	txa			; Transfer X to A
	asl			; Mutiply by 2
	sta	VERA_ADDR_LO
	rts

; A = Increment value
;----------------------
; Value | Amount
;   0   |   0
;   1   |   1
;   2   |   2
;   3   |   4
;   4   |   8
;   5   |   16
;   6   |   32
;   7   |   64
;   8   |   128
;   9   |   256
;   A   |   512
;   B   |   1024
;   C   |   2048
;   D   |   4096
;   E   |   8192
;   F   |   16384
SetInc:
	; Shift the lov nibble to high as it is stored in high nibble
	; of vera_addr_hi
	asl
	asl
	asl
	asl
	sta	VERA_ADDR_HI
	rts

; *******************************************************************
; Write a pascal-style string to screen.
; Since VERA has 256 printable characters we can not use a
; zero-terminated string as that would mean that one character could
; never be printed. Instead, the first byte of the string will
; indicate how long the string is.
; *******************************************************************
; INPUTS:	X = Low byte of string starting address
;		Y = High byte of string starting address
; *******************************************************************
PrintStr:
	; Tell VERA to increment address by 2 every time we write to
	; the data port
	lda	#2
	jsr	SetInc

	; Store address of string in ZP memory
	stx	$00
	sty	$01
	ldy	#0
	lda	($00), Y	; Get length of string
	sta	$02		; Store length in ZP for later
	ldy	#0
.doprint:
	iny
	lda	($00), Y	; Load character from string
	sta	VERA_DATA0	; Write character to VERA
	cpy	$02		; Check if Y has reached length
	bne	.doprint	; If not, print next character
	rts

.gnames	!byte	37,$01,$0E,$04,' ',' ',$0E,$01,$0E,$04,' ',$0F,$12,' ',' ',' ',$0E,$0F,$12,' ',' ',$18,$0F,$12,' ',' ',$18,$0E,$0F,$12,' ',$0E,$0F,$14,' ',$02,$15,$06
;		   AND			NAND		    OR		       NOR		   XOR		       XNOR		   NOT		   BUFFER
.gate1	!byte	36,$DD,$E2,$E4,' ',' ',$DE,$E2,$E4,' ',' ',$E8,$ED,$EF,' ',' ',$E9,$ED,$EF,' ',' ',$F3,$F7,$EF,' ',' ',$F4,$F7,$EF,' ',' ',$FA,' ',' ',' ',$FA,' '
.gate2	!byte	36,$DF,' ',$E6,' ',' ',$DF,' ',$E7,' ',' ',$EA,' ',$F1,' ',' ',$EA,' ',$F2,' ',' ',$EA,$F9,$F1,' ',' ',$EA,$F9,$F2,' ',' ',$FC,$FE,' ',' ',$FD,$FF
.gate3	!byte	36,$E0,$E3,$E5,' ',' ',$E1,$E3,$E5,' ',' ',$EB,$EE,$F0,' ',' ',$EC,$EE,$F0,' ',' ',$F5,$F8,$F0,' ',' ',$F6,$F8,$F0,' ',' ',$FB,' ',' ',' ',$FB,' '


.lin01	!byte	$21,$20,$20,$30,$20,$31,$20,$32,$20,$33,$20,$34,$20,$35,$20,$36,$20
	!byte	$37,$20,$38,$20,$39,$20,$01,$20,$02,$20,$03,$20,$04,$20,$05,$20,$06
.lin02	!byte	$21,$30,$20,$00,$20,$01,$20,$02,$20,$03,$20,$04,$20,$05,$20,$06,$20
	!byte	$07,$20,$08,$20,$09,$20,$0A,$20,$0B,$20,$0C,$20,$0D,$20,$0E,$20,$0F
.lin03	!byte	$21,$31,$20,$10,$20,$11,$20,$12,$20,$13,$20,$14,$20,$15,$20,$16,$20
	!byte	$17,$20,$18,$20,$19,$20,$1A,$20,$1B,$20,$1C,$20,$1D,$20,$1E,$20,$1F
.lin04	!byte	$21,$32,$20,$20,$20,$21,$20,$22,$20,$23,$20,$24,$20,$25,$20,$26,$20
	!byte	$27,$20,$28,$20,$29,$20,$2A,$20,$2B,$20,$2C,$20,$2D,$20,$2E,$20,$2F
.lin05	!byte	$21,$33,$20,$30,$20,$31,$20,$32,$20,$33,$20,$34,$20,$35,$20,$36,$20
	!byte	$37,$20,$38,$20,$39,$20,$3A,$20,$3B,$20,$3C,$20,$3D,$20,$3E,$20,$3F
.lin06	!byte	$21,$34,$20,$40,$20,$41,$20,$42,$20,$43,$20,$44,$20,$45,$20,$46,$20
	!byte	$47,$20,$48,$20,$49,$20,$4A,$20,$4B,$20,$4C,$20,$4D,$20,$4E,$20,$4F
.lin07	!byte	$21,$35,$20,$50,$20,$51,$20,$52,$20,$53,$20,$54,$20,$55,$20,$56,$20
	!byte	$57,$20,$58,$20,$59,$20,$5A,$20,$5B,$20,$5C,$20,$5D,$20,$5E,$20,$5F
.lin08	!byte	$21,$36,$20,$60,$20,$61,$20,$62,$20,$63,$20,$64,$20,$65,$20,$66,$20
	!byte	$67,$20,$68,$20,$69,$20,$6A,$20,$6B,$20,$6C,$20,$6D,$20,$6E,$20,$6F
.lin09	!byte	$21,$37,$20,$70,$20,$71,$20,$72,$20,$73,$20,$74,$20,$75,$20,$76,$20
	!byte	$77,$20,$78,$20,$79,$20,$7A,$20,$7B,$20,$7C,$20,$7D,$20,$7E,$20,$7F
.lin10	!byte	$21,$38,$20,$80,$20,$81,$20,$82,$20,$83,$20,$84,$20,$85,$20,$86,$20
	!byte	$87,$20,$88,$20,$89,$20,$8A,$20,$8B,$20,$8C,$20,$8D,$20,$8E,$20,$8F
.lin11	!byte	$21,$39,$20,$90,$20,$91,$20,$92,$20,$93,$20,$94,$20,$95,$20,$96,$20
	!byte	$97,$20,$98,$20,$99,$20,$9A,$20,$9B,$20,$9C,$20,$9D,$20,$9E,$20,$9F
.lin12	!byte	$21,$01,$20,$A0,$20,$A1,$20,$A2,$20,$A3,$20,$A4,$20,$A5,$20,$A6,$20
	!byte	$A7,$20,$A8,$20,$A9,$20,$AA,$20,$AB,$20,$AC,$20,$AD,$20,$AE,$20,$AF
.lin13	!byte	$21,$02,$20,$B0,$20,$B1,$20,$B2,$20,$B3,$20,$B4,$20,$B5,$20,$B6,$20
	!byte	$B7,$20,$B8,$20,$B9,$20,$BA,$20,$BB,$20,$BC,$20,$BD,$20,$BE,$20,$BF
.lin14	!byte	$21,$03,$20,$C0,$20,$C1,$20,$C2,$20,$C3,$20,$C4,$20,$C5,$20,$C6,$20
	!byte	$C7,$20,$C8,$20,$C9,$20,$CA,$20,$CB,$20,$CC,$20,$CD,$20,$CE,$20,$CF
.lin15	!byte	$21,$04,$20,$D0,$20,$D1,$20,$D2,$20,$D3,$20,$D4,$20,$D5,$20,$D6,$20
	!byte	$D7,$20,$D8,$20,$D9,$20,$DA,$20,$DB,$20,$DC,$20,$DD,$20,$DE,$20,$DF
.lin16	!byte	$21,$05,$20,$E0,$20,$E1,$20,$E2,$20,$E3,$20,$E4,$20,$E5,$20,$E6,$20
	!byte	$E7,$20,$E8,$20,$E9,$20,$EA,$20,$EB,$20,$EC,$20,$ED,$20,$EE,$20,$EF
.lin17	!byte	$21,$06,$20,$F0,$20,$F1,$20,$F2,$20,$F3,$20,$F4,$20,$F5,$20,$F6,$20
	!byte	$F7,$20,$F8,$20,$F9,$20,$FA,$20,$FB,$20,$FC,$20,$FD,$20,$FE,$20,$FF



CHARS
; ******************* AND/NAND *************************
; Top left of AND
	!byte	%........
	!byte	%....####
	!byte	%....####
	!byte	%######..
	!byte	%######..
	!byte	%....##..
	!byte	%....##..
	!byte	%....##..

; Top left of AND inverted input
	!byte	%........
	!byte	%....####
	!byte	%.##.####
	!byte	%#..###..
	!byte	%#..###..
	!byte	%.##.##..
	!byte	%....##..
	!byte	%....##..

; Left mid of AND
	!byte	%....##..
	!byte	%....##..
	!byte	%....##..
	!byte	%....##..
	!byte	%....##..
	!byte	%....##..
	!byte	%....##..
	!byte	%....##..

; Bottom Left of AND
	!byte	%....##..
	!byte	%....##..
	!byte	%....##..
	!byte	%######..
	!byte	%######..
	!byte	%....####
	!byte	%....####
	!byte	%........

; Bottom Left of AND inverted input
	!byte	%....##..
	!byte	%....##..
	!byte	%.##.##..
	!byte	%#..###..
	!byte	%#..###..
	!byte	%.##.####
	!byte	%....####
	!byte	%........

; Top mid of AND
	!byte	%........
	!byte	%######..
	!byte	%########
	!byte	%......##
	!byte	%.......#
	!byte	%........
	!byte	%........
	!byte	%........

; Bottom mid of AND
	!byte	%........
	!byte	%........
	!byte	%........
	!byte	%.......#
	!byte	%......##
	!byte	%########
	!byte	%######..
	!byte	%........

; Top right of AND
	!byte	%........
	!byte	%........
	!byte	%........
	!byte	%........
	!byte	%#.......
	!byte	%##......
	!byte	%.##.....
	!byte	%.##.....

; Bottom right of AND
	!byte	%.##.....
	!byte	%.##.....
	!byte	%##......
	!byte	%#.......
	!byte	%........
	!byte	%........
	!byte	%........
	!byte	%........

; Right mid of AND
	!byte	%..##....
	!byte	%..##....
	!byte	%...#....
	!byte	%...#####
	!byte	%...#####
	!byte	%...#....
	!byte	%..##....
	!byte	%..##....

; Right mid of NAND
	!byte	%..##....
	!byte	%..##....
	!byte	%...#.##.
	!byte	%...##..#
	!byte	%...##..#
	!byte	%...#.##.
	!byte	%..##....
	!byte	%..##....

; ******************* OR/NOR *************************
; Top left OR
	!byte	%........
	!byte	%....####
	!byte	%....####
	!byte	%######..
	!byte	%#######.
	!byte	%.....##.
	!byte	%......##
	!byte	%......##

; Top left OR inverted input
	!byte	%........
	!byte	%....####
	!byte	%.##.####
	!byte	%#..###..
	!byte	%#..####.
	!byte	%.##..##.
	!byte	%......##
	!byte	%......##

; Left mid of OR
	!byte	%......##
	!byte	%......##
	!byte	%......##
	!byte	%......##
	!byte	%......##
	!byte	%......##
	!byte	%......##
	!byte	%......##


; Bottom left OR
	!byte	%......##
	!byte	%......##
	!byte	%.....##.
	!byte	%#######.
	!byte	%######..
	!byte	%....####
	!byte	%....####
	!byte	%........

; Bottom left OR inverted input
	!byte	%......##
	!byte	%......##
	!byte	%.##..##.
	!byte	%#..####.
	!byte	%#..###..
	!byte	%.##.####
	!byte	%....####
	!byte	%........

; Top mid of OR
	!byte	%........
	!byte	%#######.
	!byte	%########
	!byte	%.......#
	!byte	%.......#
	!byte	%........
	!byte	%........
	!byte	%........

; Bottom mid of OR
	!byte	%........
	!byte	%........
	!byte	%........
	!byte	%.......#
	!byte	%.......#
	!byte	%########
	!byte	%#######.
	!byte	%........

; Top right OR
	!byte	%........
	!byte	%........
	!byte	%........
	!byte	%........
	!byte	%#.......
	!byte	%#.......
	!byte	%#.......
	!byte	%##......

; Bottom right OR
	!byte	%##......
	!byte	%#.......
	!byte	%#.......
	!byte	%#.......
	!byte	%........
	!byte	%........
	!byte	%........
	!byte	%........

; Right mid of OR
	!byte	%.#......
	!byte	%.##.....
	!byte	%..#.....
	!byte	%...#####
	!byte	%...#####
	!byte	%..#.....
	!byte	%.##.....
	!byte	%.#......

; Right mid of NOR
	!byte	%.#......
	!byte	%.##.....
	!byte	%..#..##.
	!byte	%...##..#
	!byte	%...##..#
	!byte	%..#..##.
	!byte	%.##.....
	!byte	%.#......

; ******************* XOR ******************************
; Top left of XOR
	!byte	%........
	!byte	%....#..#
	!byte	%....##.#
	!byte	%######..
	!byte	%#######.
	!byte	%.....##.
	!byte	%......##
	!byte	%......##

; Top left of XOR inverted input
	!byte	%........
	!byte	%....#..#
	!byte	%.##.##.#
	!byte	%#..###..
	!byte	%#..####.
	!byte	%.##..##.
	!byte	%......##
	!byte	%......##

; Bottom left of XOR
	!byte	%......##
	!byte	%......##
	!byte	%.....##.
	!byte	%#######.
	!byte	%######..
	!byte	%....##.#
	!byte	%....#..#
	!byte	%........

; Bottom left of XOR inverted input
	!byte	%......##
	!byte	%......##
	!byte	%.##..##.
	!byte	%#..####.
	!byte	%#..###..
	!byte	%.##.##.#
	!byte	%....#..#
	!byte	%........

; Top mid of XOR
	!byte	%........
	!byte	%#######.
	!byte	%########
	!byte	%#......#
	!byte	%##.....#
	!byte	%.#......
	!byte	%.##.....
	!byte	%.##.....

; Bottom mid of XOR
	!byte	%.##.....
	!byte	%.##.....
	!byte	%.#......
	!byte	%##.....#
	!byte	%#......#
	!byte	%########
	!byte	%#######.
	!byte	%........

; Mid of XOR
	!byte	%.##.....
	!byte	%.##.....
	!byte	%.##.....
	!byte	%.##.....
	!byte	%.##.....
	!byte	%.##.....
	!byte	%.##.....
	!byte	%.##.....

; ******************* NOT/BUFFER ******************************
; Top of NOT
	!byte	%........
	!byte	%........
	!byte	%........
	!byte	%........
	!byte	%....#...
	!byte	%....##..
	!byte	%....###.
	!byte	%....####

; Bottom of NOT
	!byte	%....####
	!byte	%....###.
	!byte	%....##..
	!byte	%....#...
	!byte	%........
	!byte	%........
	!byte	%........
	!byte	%........

; Left of NOT
	!byte	%....##.#
	!byte	%....##..
	!byte	%....##..
	!byte	%######..
	!byte	%######..
	!byte	%....##..
	!byte	%....##..
	!byte	%....##.#

; Left of NOT inverted input
	!byte	%....##.#
	!byte	%....##..
	!byte	%.##.##..
	!byte	%#..###..
	!byte	%#..###..
	!byte	%.##.##..
	!byte	%....##..
	!byte	%....##.#

; Right of NOT
	!byte	%#.......
	!byte	%##......
	!byte	%.##..##.
	!byte	%..###..#
	!byte	%..###..#
	!byte	%.##..##.
	!byte	%##......
	!byte	%#.......

; Right of BUFFER
	!byte	%#.......
	!byte	%##......
	!byte	%.##.....
	!byte	%..######
	!byte	%..######
	!byte	%.##.....
	!byte	%##......
	!byte	%#.......
