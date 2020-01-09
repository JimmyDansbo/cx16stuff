*=$0801
	!word	$080C		; Pointer next BASIC line
	!word	$000A		; Line number $000A = 10
	!byte	$9E		; SYS BASIC token
	!pet	" $810",0	; Address where ASM starts
	!word	$0000		; EOF BASIC program
*=$0810

CHROUT	= $FFD2


main_func:!byte $ff
	lda	#>ret1		; Push return address onto stack
	pha
	lda	#<ret1
	pha
	ldx	#0		; Push function address to stack
	inx			; Remember CPU is little-endian
	lda	Jump_table,x
	pha
	dex
	lda	Jump_table,x
	pha
ret1:	rts			; Jump to function

	lda	#>ret2
	pha
	lda	#<ret2
	pha
	ldx	#2
	inx
	lda	Jump_table,x
	pha
	dex
	lda	Jump_table,x
	pha
ret2:	rts

	lda	#>ret3
	pha
	lda	#<ret3
	pha
	ldx	#4
	inx
	lda	Jump_table,x
	pha
	dex
	lda	Jump_table,x
	pha
ret3:	rts

	lda	#>ret4
	pha
	lda	#<ret4
	pha
	ldx	#6
	inx
	lda	Jump_table,x
	pha
	dex
	lda	Jump_table,x
	pha
ret4:	rts

	rts

; Write 1 and a new line on screen
func1:
	lda	#$31
	jsr	CHROUT
	lda	#13
	jsr	CHROUT
	rts

; Write 2 and a new line on screen
func2:
	lda	#$32
	jsr	CHROUT
	lda	#13
	jsr	CHROUT
	rts

; Write 3 and a new line on screen
func3:
	lda	#$33
	jsr	CHROUT
	lda	#13
	jsr	CHROUT
	rts

; Write 4 and a new line on screen
func4:
	lda	#$34
	jsr	CHROUT
	lda	#13
	jsr	CHROUT
	rts

; The jumptable needs to contain the function address - 1 in order
; to be able to use rts to jump to the function
Jump_table:
	!word	func1-1
	!word	func2-1
	!word	func3-1
	!word	func4-1
