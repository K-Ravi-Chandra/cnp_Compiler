compile: analyzer.l parser.y tempToMachine.cpp
	lex analyzer.l
	yacc -d parser.y 
	yacc parser.y -o gm.cc
	cc -c lex.yy.c -o lex.yy.o
	g++ lex.yy.o gm.cc symbolTable.cpp -o genTemp
	g++ tempToMachine.cpp -o machineToMips
	rm gm.cc lex.yy.c y.tab.h lex.yy.o y.tab.c

clean:
	rm genTemp machineToMips

clear:
	rm file.temp machine.asm

