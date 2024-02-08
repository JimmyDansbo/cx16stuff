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
ROM_BANK	=$00

;*************************************************************************
; CX16 ROM constants
;*************************************************************************
KERNAL_BANK	=0
KEYBD_BANK	=1
CBDOS_BANK	=2
GEOS_BANK	=3
BASIC_BANK	=4
MONITOR_BANK	=5


	ldy	ROM_BANK		; Save the current ROM bank
	lda	#KERNAL_BANK		; Set the kernal BANK
	sta	ROM_BANK
	lda	KERNALVER		; Read kernal version
	sty	ROM_BANK		; Restore ROM bank

	; Kernal version is stored as a twos compliment negative number
	; as long as we have not reached a production build
	; To convert a twos compliment negative number to its positive
	; value, we invert all bits and add 1
	eor	#$FF			; Invert all bits in A
	tay				; Copy result to Y
	iny				; Add 1 to result

	cpy	#45			; Check for version 45
	bne	.is46			; If not, check for version 46
	ldy	#0
-	lda	.v45,y
	bne	.doprn45
	rts
.doprn45:
	jsr	CHROUT
	iny
	jmp	-
.is46:
	cpy	#46			; Check for version 46
	bne	.unknown		; If not, say we don't know the version
	ldy	#0
-	lda	.v46,y
	bne	.doprn46
	rts
.doprn46:
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


.v45	!pet	"version: 45",13,0
.v46	!pet	"version: 46",13,0
.none	!pet	"version unknown",13,0
