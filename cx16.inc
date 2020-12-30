!ifdef CX16_INC !eof
CX16_INC=1

KERNALVER	= $FF80
VIA1		= $9F60
VIA1PA		= VIA1+1
VIA1PB		= VIA1+0
VIA2		= $9F70
VIA2PA		= VIA2+1
VIA2PB		= VIA2+0

; Emulator
GIFCTRL		= $9FB5

; IRQ
IRQVECTOR	= $0314

; Text mode ports (not supported and changes between ROM releases)
COLORPORT	= $0376
NUMCOLS		= $0386
NUMLINES	= $0387

; ROM Bank allocations
KERNAL_BANK	= 0
KEYBD_BANK	= 1
CBDOS_BANK	= 2
GEOS_BANK	= 3
BASIC_BANK	= 4
MONITOR_BANK	= 5

; ZeroPage variables/pointers
TMP0		= $00
TMP1		= $01
TMP2		= $22
TMP3		= $23
TMP4		= $24
TMP5		= $26
TMP7		= $27
TMP8		= $28
TMP9		= $29

; PETSCII color codes
PET_BLACK	= $90
PET_WHITE	= $05
PET_RED		= $1C
PET_CYAN	= $9F
PET_PURPLE	= $9C
PET_GREEN	= $1E
PET_BLUE	= $1F
PET_YELLOW	= $9E
PET_ORANGE	= $81
PET_BROWN	= $95
PET_LIGHTRED	= $96
PET_DARKGRAY	= $97
PET_MIDGRAY	= $98
PET_LIGHTGREEN	= $99
PET_LIGHTBLUE	= $9A
PET_LIGHTGRAY	= $9B

; Color values
BLACK		= 0
WHITE		= 1
RED		= 2
CYAN		= 3
PURPLE		= 4
GREEN		= 5
BLUE		= 6
YELLOW		= 7
ORANGE		= 8
BROWN		= 9
LIGHTRED	= 10
DARKGRAY	= 11
MIDGRAY		= 12
LIGHTGREEEN	= 13
LIGHTBLUE	= 14
LIGHTGRAY	= 15

; "ABI" registers in ZeroPage
r0		= $02
r0l		= r0
r0h		= r0+1
r1		= $04
r1l		= r1
r1h		= r1+1
r2		= $06
r2l		= r2
r2h		= r2+1
r3		= $08
r3l		= r3
r3h		= r3+1
r4		= $0A
r4l		= r4
r4h		= r4+1
r5		= $0C
r5l		= r5
r5h		= r5+1
r6		= $0E
r6l		= r6
r6h		= r6+1
r7		= $10
r7l		= r7
r7h		= r7+1
r8		= $12
r8l		= r8
r8h		= r8+1
r9		= $14
r9l		= r9
r9h		= r9+1
r10		= $16
r10l		= r10
r10h		= r10+1
r11		= $18
r11l		= r11
r11h		= r11+1
r12		= $1A
r12l		= r12
r12h		= r12+1
r13		= $1C
r13l		= r13
r13h		= r13+1
r14		= $1E
r14l		= r14
r14h		= r14+1
r15		= $20
r15l		= r15
r15h		= r15+1

; *****************************************************************************
; Save the address of the original interrupt handler
; *****************************************************************************
; USES:		A
; OUTPUTS:	Address of old handler will be passed back in .old_handler
; *****************************************************************************
!macro SAVE_INT_VECTOR .old_handler {
	lda	IRQVECTOR
	sta	.old_handler
	lda	IRQVECTOR+1
	sta	.old_handler+1
}

; *****************************************************************************
; Install new interrupt handler
; *****************************************************************************
; INPUTS:	.handler = address of new interrupt handler
; USES:		A
; *****************************************************************************
!macro INSTALL_INT_HANDLER .handler {
	sei			; Disable interrupts
	lda	#1		; Tell VERA that we want interrupts
	sta	VERA_IEN	; on each VSYNC
	lda	#<.handler	; Write address of local interrupt
	sta	IRQVECTOR	; handler to the interrupt
	lda	#>.handler	; vector address ($0314)
	sta	IRQVECTOR+1
	cli			; Enable interrupts
}

;******************************************************************************
; Code to enable program to be startet with the RUN command
;******************************************************************************
!macro SYS_LINE {
	!word	$080C			; Pointer to next BASIC line
	!word	$000A			; Line number $000A = 10
	!byte	$9E			; SYS BASIC token
	!pet	" $810",0		; Address where ASM starts
	!word	$0000			; EOF BASIC program
}

;******************************************************************************
; Get KERNAL version and convert it from 2's compliment number if it is a
; pre-release
;******************************************************************************
; RETURNS:	.A contains the KERNAL version
;		.C cleared if pre-release version
;******************************************************************************
!macro GET_KERNAL_VER {
	lda	VIA1PB			; Save current ROM bank
	tay				; in .Y
	and	#KERNAL_BANK|#$F8	; Set ROM bank to 0, only 3 lowest bits
	sta	VIA1PB			; are used to set ROM bank
	lda	KERNALVER		; Read KERNAL version
	sty	VIA1PB			; Restore ROM bank
	sec				; Set carry to show it is release-version
	bpl	.done			; If positive, we are done
	eor	#$FF			; Invert and add 1 to convert the 2's
	clc				; compliment number to the KERNAL version
	adc	#1
	clc				; Clear carry to show it is pre-release
.done:
}
