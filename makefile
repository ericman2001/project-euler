all: problem1
problem1:
	cl65 -t cx16 -o PROBLEM1.PRG problem1.asm
clean:
	rm *.PRG *.list *.o
