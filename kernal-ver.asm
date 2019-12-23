;*************************************************************************
; Small program to demonstrate how to read the kernal version with
; assembler programming. The kernal version is stored on address $FF80
; in the kernal ROM bank. By default when the program is started the
; BASIC ROM bank is enabled. This code shows how to switch the ROM bank,
; read the kernal version, and display the kernal version
;*************************************************************************
*=$0801
!byte $0C,$08,$0A,$00,$9E,$20,$32,$30,$36,$34,$00,$00,$00
*=$0810

;*************************************************************************
; KERNAL API
;*************************************************************************
CHROUT		=$FFD2

;*************************************************************************
; CX16 ports
;*************************************************************************
KERNALVER	=$FF80
VIA1ROMBANK	=$9F60

;*************************************************************************
; CX16 ROM constants
;*************************************************************************
KERNAL_BANK	=0
KEYBD_BANK	=1
CBDOS_BANK	=2
GEOS_BANK	=3
BASIC_BANK	=4
MONITOR_BANK	=5


	ldy	VIA1ROMBANK		; Save the current ROM bank
	lda	#KERNAL_BANK		; Set the kernal BANK
	sta	VIA1ROMBANK
	lda	KERNALVER		; Read kernal version
	sty	VIA1ROMBANK		; Restore ROM bank

	; Kernal version is stored as a twos compliment negative number
	; as long as we have not reached a production build
	; To convert a twos compliment negative number to its positive
	; value, we invert all bits and add 1
	eor	#$FF			; Invert all bits in A
	tay				; Copy result to Y
	iny				; Add 1 to result

	cpy	#35			; Check for version 35
	bne	.is34			; If not, check for version 34
	ldy	#0
-	lda	.v35,y
	bne	.doprn35
	rts
.doprn35:
	jsr	CHROUT
	iny
	jmp	-
.is34:
	cpy	#34			; Check for version 34
	bne	.unknown		; If not, say we don't know the version
	ldy	#0
-	lda	.v34,y
	bne	.doprn34
	rts
.doprn34:
	jsr	CHROUT
	iny
	jmp	-
.unknown:				; Say we don't know the version
	ldy	#0
-	lda	.none,y
	bne	.doprnn
	rts
.doprnn:
	jsr	CHROUT
	iny
	jmp	-

	rts


.v35	!pet	"version: 35",13,0
.v34	!pet	"version: 34",13,0
.none	!pet	"version unknown",13,0
