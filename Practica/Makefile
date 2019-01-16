all: compile clean

compile:
	antlr -gt practica.g
	dlg -ci parser.dlg scan.c
	g++ -o practica practica.c scan.c err.c -I /usr/include/pccts

clean:
	rm *.c
	rm *.dlg
	rm *.h
