!cpu w65c02
!src "cx16.inc"
+SYS_LINE

Main:
	; Use Wozniak insired function to print hex-string
	lda	#$7C
	jsr	Hex_to_pet_calc
	lda	#13
	jsr	CHROUT

	; Use a lookup table to print hex-string
	lda	#$3E
	jsr	Hex_to_pet_tbl
	lda	#13
	jsr	CHROUT

	rts

; *****************************************************************************
; Print a byte in .A as a hexadecimal string.
; Uses .A, .X and calls the CHROUT/BSOUT C64 KERNAL API
; This is very inspired by the PRBYTE function in wozmon code for Apple 1
; *****************************************************************************
Hex_to_pet_calc:
	tax			; Save .A for low nibble
	lsr
	lsr
	lsr
	lsr			; High nibble to low nibble
	jsr	@print_hex	; Print hex-digit
	txa			; Restore .A
	and	#$0F		; Mask low nibble for hex print
@print_hex:
	ora	#$30		; Convert to petscii
	cmp	#$3A		; Is it a decimal number
	bcc	@do_print	; Yes, print it
	adc	#6		; Otherwise add offset for letters A-F
@do_print:
	jsr	CHROUT		; Print the character to screen
	rts

; *****************************************************************************
; Print a byte in .A as a hexadecimal string.
; Uses .A, .X, .Y and calls the CHROUT/BSOUT C64 KERNAL API
; This function uses a 16-byte table for the actual conversion. It takes up
; more memory, but executes faster.
; *****************************************************************************
Hex_to_pet_tbl:
	tax			; Save .A for low nibble
	lsr
	lsr
	lsr
	lsr			; High nibble to low nibble
	tay			; Copy nibble to .Y to use as index
	lda	Hex_table,y	; Load character from Hex_table
	jsr	CHROUT		; Print the caracter to screen
	txa			; Restore .A
	and	#$0F		; Mask low nibble for hex print
	tay			; Copy nibble to .Y to use as index
	lda	Hex_table,y	; Load character from Hex table
	jsr	CHROUT		; Print the caracter to screen
	rts
Hex_table:
	!pet	"0123456789abcdef"
