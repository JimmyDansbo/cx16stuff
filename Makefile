all:
	acme -f cbm -o bcdtopet.prg bcdtopet.asm
	acme -f cbm -o charrepl.prg char-replace.asm
	acme -f cbm -o helloworld.prg helloworld.asm
	acme -f cbm -o intsteal.prg int-steal.asm
	acme -f cbm -o jumptable.prg jumptable.asm
	acme -f cbm -o jumptable-rts.prg jumptable-rts.asm
	acme -f cbm -o krnver.prg kernal-ver.asm
	acme -f cbm -o reset.prg reset.asm
	acme -f cbm -o rts-jumptable.prg rts-jumptable.asm
	acme -f cbm -o swapnib.prg swapnib.asm
	acme -f cbm -o veratext.prg veratext.asm
clean:
	rm -f *.prg
