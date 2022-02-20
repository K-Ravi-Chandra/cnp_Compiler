%{
	#include "y.tab.h" 
	int DEBUG = 1;
%}

%%
"int"		{
				if( DEBUG == 1 )
					printf("INT");
				yylval.str = strdup(yytext);
				return INT;
			}

"float"		{
				if( DEBUG == 1 )
					printf("FLOAT");
				yylval.str = strdup(yytext);
				return FLOAT;
			}
"char"		{
				if( DEBUG == 1 )
					printf("CHAR");
				yylval.str = strdup(yytext);
				return FLOAT;
			}	
"string"	{
				if( DEBUG == 1 )
					printf("STRING");
				yylval.str = strdup(yytext);
				return STRING;
			}
"bool"		{
				if( DEBUG == 1 )
					printf("BOOL");
				yylval.str = strdup(yytext);
				return BOOL;
			}
([a-z]|[A-Z])+		{
				if( DEBUG == 1 )
					printf("VAR(%s)",yytext);
				yylval.str = strdup(yytext);
				return VARIABLE;
			}
"="			{
				if( DEBUG == 1 )
					printf("EQUALS");
				return EQUALS;
			}
[0-9]+		{
				if( DEBUG == 1 )
					printf("INTEGER(%s)", yytext);
				yylval.str = strdup(yytext);
				return INTEGER;
			}
(" "|'\t')*	{
				if( DEBUG == 1 )
					printf(" SPACES ");
				return SPACES;
			}
"\n"		{}
%%
