parse: analyzer.l parser.y
	lex analyzer.l
	yacc -d parser.y 
	yacc parser.y -o gm.cc
	cc -c lex.yy.c -o lex.yy.o
	c++ lex.yy.o gm.cc -o ic
	rm gm.cc lex.yy.c y.tab.h lex.yy.o y.tab.c

gen: 
	g++ tempToMachine.cpp -o mc

clean:
	rm y.tab.c y.tab.h lex.yy.c lex.yy.o gm.cc a.out

