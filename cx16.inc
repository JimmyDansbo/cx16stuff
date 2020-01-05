!ifdef CX16_INC !eof
CX16_INC=1

KERNALVER	= $FF80
VIA1PA		= $9F61
VIA1PB		= $9F60

; ROM Bank allocations
KERNAL_BANK	= 0
KEYBD_BANK	= 1
CBDOS_BANK	= 2
GEOS_BANK	= 3
BASIC_BANK	= 4
MONITOR_BANK	= 5

TMP0		= $00
TMP1		= $01

; "ABI" registers in ZeroPage
r0		= $02
r0l		= $02
r0h		= $03
r1		= $04
r1l		= $04
r1h		= $05
r2		= $06
r2l		= $06
r2h		= $07
r3		= $08
r3l		= $08
r3h		= $09
r4		= $0A
r4l		= $0A
r4h		= $0B
r5		= $0C
r5l		= $0C
r5h		= $0D
r6		= $0E
r6l		= $0E
r6h		= $0F
r7		= $10
r7l		= $10
r7h		= $11
r8		= $12
r8l		= $12
r8h		= $13
r9		= $14
r9l		= $14
r9h		= $15
r10		= $16
r10l		= $16
r10h		= $17
r11		= $18
r11l		= $18
r11h		= $19
r12		= $1A
r12l		= $1A
r12h		= $1B
r13		= $1C
r13l		= $1C
r13h		= $1D
r14		= $1E
r14l		= $1E
r14h		= $1F
r15		= $20
r15l		= $20
r15h		= $21

!macro SYS_LINE {
	!byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00
}

;******************************************************************************
; Get KERNAL version and convert it from 2's compliment number if it is a
; pre-release
;******************************************************************************
; RETURNS:	.A contains the KERNAL version
;		.C cleared if pre-release version
;******************************************************************************
!macro GET_KERNAL_VER {
	lda	VIA1PB		; Save current ROM bank
	sta	TMP0		; In TMP0
	and	#%11111000	; Set ROM bank to 0, only 3 lowest bits
	sta	VIA1PB		; are used to set ROM bank
	lda	KERNALVER	; Read KERNAL version
	sta	TMP1		; SAve it in TMP1
	lda	TMP0		; Restore ROM bank
	sta	VIA1PB
	lda	TMP1		; Get KERNAL version into .A
	sec
	bpl	.done		; If positive, we are done
	eor	#$FF		; Invert and add 1 to convert the 2's
	clc			; compliment number to the KERNAL version
	adc	#1
	clc
.done:
}
