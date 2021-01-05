!cpu w65c02
*=$400

; *****************************************************************************
; IRQ driven effects library copied from:
; https://github.com/Dooshco/X16/blob/master/Effects.asm
; converted to acme assembly from ca65 assembly
; *****************************************************************************

VERA_LOW	= $9F20
VERA_MID	= $9F21
VERA_HIGH	= $9F22
VERA_DATA0	= $9F23
IRQ_VECTOR	= $0314
PSG_CHANNEL	= $1F9FC
PSG_VOLUME	= PSG_CHANNEL+2

!macro	VERA_SET .addr, .increment {
	lda	#((^.addr) | (.increment << 4))
	sta	VERA_HIGH
	lda	#>.addr
	sta	VERA_MID
	lda	#<.addr
	sta	VERA_LOW
}

; *****************************************************************************
; Entry Section
; *****************************************************************************
	bra	ping
	bra	shoot
	bra	zap
	bra	explode

ping:
	ldx	#0
	bra	common
shoot:
	ldx	#10
	bra	common
zap:
	ldx	#20
	bra	common
explode:
	ldx	#30
	bra	common

; *****************************************************************************
common:
	ldy	#0			; move 10 bytes from definitions
-	lda	sounds,x
	sta	channel15,y
	inx
	iny
	cpy	#10
	bne	-

	lda	#255			; Start playing
	sta	phase

	lda	running			; is IRQ player already running?
	bne	return

	sei				; insert new IRQ player
	lda	IRQ_VECTOR
	sta	OLD_IRQ_HANDLER
	lda	#<Play
	sta	IRQ_VECTOR
	lda	IRQ_VECTOR+1
	sta	OLD_IRQ_HANDLER+1
	lda	#>Play
	sta	IRQ_VECTOR+1
	cli
	lda	#1
	sta	running
return:
	rts

; *****************************************************************************
; IRQ Play Section
; *****************************************************************************
Play:
	; Save VERA registers
	lda	$9F20
	sta	data_store
	lda	$9F21
	sta	data_store+1
	lda	$9F22
	sta	data_store+2
	lda	$9F25
	sta	data_store+3

	lda	phase
	bne	+		; if phase = 0 - Exit
	jmp	exit

+	cmp	#1		; if phase = 1 - Release
	bne	+
	jmp	release

+	lda	#1		; else phase = 255 - Start
	sta	phase

	+VERA_SET PSG_CHANNEL,1

	lda	frequency	; read and set frequency
	sta	VERA_DATA0
	lda	frequency+1
	sta	VERA_DATA0
	lda	volume+1
	ora	#%11000000
	sta	VERA_DATA0	;starting Volume = volume
	lda	waveform
	sta	VERA_DATA0	; set waveform
	jmp	exit

; *****************************************************************************
release:
; *****************************************************************************
	lda	release_count
	bne	release_loop		; not finished yet

	+VERA_SET PSG_VOLUME,0
	stz	VERA_DATA0		; set volume to 0 at the end of Release phase

	stz	phase			; release finished, exit
	jmp	exit

release_loop:
	sec				; decrease 16 bit volume
	lda	volume
	sbc	vol_change
	sta	volume
	lda	volume+1
	sbc	vol_change+1
	sta	volume+1

	sec				; decrease 16 bit frequency
	lda	frequency
	sbc	freq_change
	sta	frequency
	lda	frequency+1
	sbc	freq_change+1
	sta	frequency+1

	+VERA_SET PSG_CHANNEL,1

	lda	frequency		; read and set frequency
	sta	VERA_DATA0
	lda	frequency+1
	sta	VERA_DATA0

	lda	volume+1
	ora	#%11000000
	sta	VERA_DATA0		; read and set volume

	dec	release_count

exit:
	; restore VERA registers
	lda	data_store
	sta	$9F20
	lda	data_store+1
	sta	$9F21
	lda	data_store+2
	sta	$9F22
	lda	data_store+3
	sta	$9F25

	jmp	(OLD_IRQ_HANDLER)

; *****************************************************************************
; Variables
; *****************************************************************************
running:	!byte	0	; 0 - not running, 1 - running
phase:		!byte	0	; 0 - not playing, 255 - start, 1 - Play Release

channel15:	; Structure of channel15 data
release_count:	!byte	0

frequency:	!word	0
waveform	!byte	0

volume:		!word	0
vol_change:	!word	0
freq_change:	!word	0

	; Sound definitions - fits into the structure of channel15
sounds:
			;.byte	100,199,9,160,0,63,161,0,0,0
ping_envelope: 		;!byte	$64,$C7,$09,$A0,$00,$3F,$A1,$00,$00,$00
		!byte	100	; release_count
		!word	2503	; frequency
		!byte	160	; waveform
		!word	16128	; volume
		!word	161	; vol_change
		!word	0	; freq_change

			;.byte	20,107,17,224,0,63,0,3,0,0
shoot_envelope:		;!byte	$14,$6B,$11,$E0,$00,$3F,$00,$03,$00,$00
		!byte	20	; release_count
		!word	4459	; frequency
		!byte	224	; waveform
		!word	16128	; volume
		!word	768	; vol_change
		!word	0	; freq_change

			;.byte	37,232,10,96,0,63,179,1,100,0
zap_envelope:		;!byte	$25,$E8,$0A,$60,$00,$3F,$B3,$01,$64,$00
		!byte	37	; release_count
		!word	2792	; frequency
		!byte	96	; waveform
		!word	16128	; volume
		!word	435	; vol_change
		!word	100	; freq_change

			;.byte	200,125,5,224,0,63,80,0,0,0
explode_envelope	;!byte	$C8,$7D,$05,$E0,$00,$3F,$50,$00,$00,$00
		!byte	200	; release_count
		!word	1405	; frequency
		!byte	224	; waveform
		!word	16128	; volume
		!word	80	; vol_change
		!word	0	; freq_change

data_store:		!byte	0,0,0,0
OLD_IRQ_HANDLER		!word	0
