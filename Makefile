all:
	acme -f cbm -o bcdtopet.prg bcdtopet.asm
	acme -f cbm -o helloworld.prg helloworld.asm
clean:
	rm -f *.prg
