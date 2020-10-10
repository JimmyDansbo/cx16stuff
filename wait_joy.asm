; *****************************************************************************
; The sole purpose of this program is to show how to handle the differences
; of the joystick_get ($FF56) KERNAL function output, depending on how the
; program is started.
; In the CX16 emulator, it is possible to load and run a program directly from
; the commandline, but when that is done, the joystick_get function is not
; initialized correctly and returns $00 until a key is pressed.
; In hardware or if the program is started by typing RUN in BASIC, the function
; is initialized correctly and will return 0 bits for the buttons pressed.
; *****************************************************************************
!cpu 65c02	; Use the extended 65C02 commands

; Make sure the program can be started by typing RUN
*=$801
!byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00
*=$810

; Jump over the string, otherwise the computer will try to execute it.
; If the string was located at end of program, this jump would not be necessary
	bra	Main

Msg	!pet	"press start/return to end program",13,0

TMP0	= $00		; zero page addresses $00 and $01 is used by the program
JOY_GET	= $FF56		; KERNAL call to get joystick state
CHROUT	= $FFD2		; KERNAL call to output character

; *****************************************************************************
; This is the main program. All it does is wait for the user to press start
; button on joystick1 (= return on the keyboard). It starts by writing that
; User should press start/return and then displays joystick states when they
; change.
; *****************************************************************************
Main:
	; Display message on screen
	ldx	#<Msg
	ldy	#>Msg
	jsr	Print_str

	; Store a value in memory that is unlikely to be equal to what is read
	; by the JOY_GET function
	lda	#254
	sta	TMP0

	; Read joystick1
	lda	#0
	jsr	JOY_GET
	; If it returns $00, the program has been started in the emulator
	; directly from commandline and JOY_GET will continue to return $00
	; until a key is pressed.
	cmp	#$00
	beq	@emu_run

	; Here we know that the program has been started by typing RUN in
	; BASIC. The problem here is that we are going to read the RETURN
	; keypress after RUN several times which would effectively end the
	; program right away. To overcome this, we wait for the JOY_GET function
	; to return $FF (= no keys pressed)
@wait_for_settle:
	lda	#0		; Read joystick1
	jsr	JOY_GET
	cmp	TMP0		; If result is equal to last read, skip to +
	beq	+
	sta	TMP0		; Save newly read value in memory
	jsr	Print_hex	; Print the value as hex number
	lda	#13		; - This way we only print when returned value
	jsr	CHROUT		; - changes.
	lda	TMP0		; Restore .A register
+	cmp	#$FF		; While result is not $FF, loop back
	bne	@wait_for_settle
	bra	@norm_run

	; Here we know that the program has been started directly from the
	; commandline in the emulator so we just wait while $00 is returned.
@emu_run:
	lda	#0		; Read joystick1
	jsr	JOY_GET
	cmp	TMP0		; If result is equal to last read, skip to +
	beq	+
	sta	TMP0		; Save newly read value in memory
	jsr	Print_hex	; Print the value as a hex number
	lda	#13		; - This way we only print when returned value
	jsr	CHROUT		; - changes.
	lda	TMP0		; Restore .A register
+	cmp	#$00		; While result equals $00, loop back
	beq	@emu_run

	; When this point is reached, we can be certain that the JOY_GET
	; function works as expected.
@norm_run:
	lda	#0		; Read joystick1
	jsr	JOY_GET
	cmp	TMP0		; If result is equal to last read, skip to +
	beq	+
	sta	TMP0		; Save newly read value in memory
	jsr	Print_hex	; Print the value as a hex number
	lda	#13		; - This way we only print when returned value
	jsr	CHROUT		; - changes.
	lda	TMP0		; Restore .A register
+	and	#$10		; Loop until Start/RETURN is pressed
	bne	@norm_run

	rts

; *****************************************************************************
; Function to print a 0-terminated string
; *****************************************************************************
; INPUTS: .X and .Y must contain low- and high- byte of string starting address
; *****************************************************************************
; USES: TMP0 and TMP+1 zero page memory addresses
; *****************************************************************************
; MODIFIES: .A and .Y registers
; *****************************************************************************
Print_str:
	stx	TMP0		; Store string start address in zero page mem.
	sty	TMP0+1
	ldy	#0
-	lda	(TMP0),y	; Load character from string
	beq	@end		; If it is 0, we are done.
	jsr	CHROUT		; Output character
	iny			; Increment .Y
	bra	-		; Loop back to get next character
@end:
	rts

; *****************************************************************************
; This macro outputs low nibble of .A as a hexadecimal digit.
; The high nibble of .A must be zero.
; *****************************************************************************
; MODIFIES: .A
; *****************************************************************************
!macro PRINT_NIBBLE {
	cmp	#$0F		; Is the value $0F
	bne	+		; If not, check next
	lda	#'F'		; Output 'F'
	jsr	CHROUT
	bra	.end		; Return from macro
+	cmp	#$0E		; Is the value $0E
	bne	+		; If not, check next
	lda	#'E'		; Output 'E'
	jsr	CHROUT
	bra	.end		; Return from macro
+	cmp	#$0D		; Is the value $0D
	bne	+		; If not, check next
	lda	#'D'		; Output 'D'
	jsr	CHROUT
	bra	.end		; Return from macro
+	cmp	#$0C		; Is the value $0C
	bne	+		; If not, check next
	lda	#'C'		; Output 'C'
	jsr	CHROUT
	bra	.end		; Return from macro
+	cmp	#$0B		; Is the value $0B
	bne	+		; If not, check next
	lda	#'B'		; Output 'B'
	jsr	CHROUT
	bra	.end		; Return from macro
+	cmp	#$0A		; Is the value $0A
	bne	+		; If not, check next
	lda	#'A'		; Output 'A'
	jsr	CHROUT
	bra	.end		; Return from macro
+	ORA	#$30		; Convert value to petscii and output
	jsr	CHROUT
.end:
}

; *****************************************************************************
; Outputs value in .A as a hexadecimal number.
; *****************************************************************************
; INPUTS: .A the number to convert and output
; *****************************************************************************
; MODIFIES: .A and .X
; *****************************************************************************
Print_hex:
	tax			; Save value in .A
	lsr			; Move high-nibble to low-nibble
	lsr
	lsr
	lsr
	+PRINT_NIBBLE		; Print the nibble as a hexadecimal digit
	txa			; Restore value to .A
	and	#$0F		; zero out high nibble
	+PRINT_NIBBLE		; Print the nibble as a hexadecimal digit
	rts
