*=$0801
	!word	$080C		; Pointer to next BASIC line
	!word	$000A		; Line number $000A = 10
	!byte	$9E		; SYS BASIC token
	!pet	" $810",0	; Address where ASM starts
	!word	$0000		; EOF BASIC program
*=$0810

CHROUT	= $FFD2


main_func:!byte $ff
	inc	Count		; Addresses are 16bit so 2 bytes
	inc	Count		; Increment twice
	ldx	Count		; Load index to jump table
	cpx	#8		; If it is 8, we have gone through all 4
	beq	@main_end
	lda	Jump_table,x	; Load LSB of address
	sta	Ptr		; Store in Ptr variable
	lda	Jump_table+1,x	; Load MSB of address
	sta	Ptr+1		; Store in Ptr variable
	jsr	jsr_in_ptr	; Do indrect jump to function
	jmp	main_func	; Loop back to beginning
@main_end:
	rts

; By doing a jsr to this label we imitate a jsr to an indirect address
; When the function being jumped to, do an RTS, it wil get back to where
; this function is called.
jsr_in_ptr:
	jmp	(Ptr)		; Do the indrect jump

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

Ptr	!word	$0000

Count	!byte	$00-2		; This byte is incremented twice as the first
				; thing in the program

Jump_table
	!word	func1
	!word	func2
	!word	func3
	!word	func4
