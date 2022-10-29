all: problem1
problem1:
	cl65 -t cx16 -o PROBLEM1.PRG problem1.asm
problem2:
	cl65 -t cx16 -o PROBLEM2.PRG problem2.asm
	cl65 -t cx16 -o PROBLEM2-MEMCPY.PRG problem2-memcpy.asm
clean:
	rm *.PRG *.list *.o
