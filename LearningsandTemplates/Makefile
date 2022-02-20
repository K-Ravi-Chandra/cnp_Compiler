mylex : lex.yy.c
	g++ lex.yy.c -o lex && ./lex

lex.yy.c : 1lex.l
	lex 1lex.l

clean :
	rm lex.yy.c lex