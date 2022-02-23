all : 
	lex 1lex.l
	yacc -d 1lex.y 
	yacc 1lex.y -o gm.cc
	cc -c lex.yy.c -o lex.yy.o
	c++ lex.yy.o gm.cc

clean:
	rm y.tab.c y.tab.h lex.yy.c lex.yy.o gm.cc a.out

