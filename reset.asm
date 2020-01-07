*=$0801
	!word	$080C		; Pointer next BASIC line
	!word	$000A		; Line number $000A = 10
	!byte	$9E		; SYS BASIC token
	!pet	" $810",0	; Address where ASM starts
	!word	$0000		; EOF BASIC program
*=$0810

	lda	#0		; Set ROM page to 0
	sta	$9F60
	jmp	($FFFC)		; Jump to address stored at $FFFC
	rts			; Return nicely (we should never get here)
