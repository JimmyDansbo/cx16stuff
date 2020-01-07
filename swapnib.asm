*=$0801
	!word	$080C		; Pointer to next BASIC line
	!word	$000A		; Line number $000A = 10
	!byte	$9E		; SYS BASIC token
	!pet	" $810",0	; Address where ASM starts
	!word	$0000		; EOF BASIC program
*=$0810

;******************************************************************************
; This code does not generate any output in the emulator
; It is purely here to save and test a snippet of code that I stumpled upon
; here:
; https://github.com/commanderx16/x16-rom/issues/22#issuecomment-532359658
; The code swaps the nibbles in a byte
; Use the -debug option in the emulator to step through the code and see
; that nibbles are swapped.
;******************************************************************************
	!byte $ff	; Break into the debugger

	lda	#$F5	; Set the nibbles that are going to be swapped
	sta	$00	; Store en ZP for easy comparison after swap
	; 'Magic' code that swaps nibbles in .A
	asl
	adc	#$80
	rol
	asl
	adc	#$80
	rol
	; Nibbles are now swapped.
	sta	$01	; Store in ZP, now compare with ZP addr $00
			; to see that the nibbles are swapped

	rts
