%{
	int DEBUG = 0;		//print the tokens only for debugging purposes.
	/*
		for each token in a given category return the yylval such that we can infer
		which token we got.

		for example: if you are returning keyword, then in yylval return lets say 1 for int, 2 for float, 3 for bool etc.
		similarly for all other categories.

		if you want to return a string then return yylval.str

		similarly for others.
		int	-	yylval.int4		( you have to convert yytext to int and then return)
		float	- yylval.float8
		bool	- yylval.bool
		char	- yylval.char1
	*/
%}

%%
"int"					{
							if( DEBUG == 1 )
								printf("INT");
							return INT;
						}
[a-zA-Z_][a-zA-Z_0-9]*	{
							if( DEBUG == 1 )
								printf(yytext);
							yylval.str = strdup(yytext);
							return STRING;
						}
