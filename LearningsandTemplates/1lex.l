

%{

#include<string.h>
#include "y.tab.h" 

	
int DEBUG = 1;

%}

ws				[ \t]*
digit			[0-9]
digits			{digit}+
letter			[a-zA-Z_]
integer			[-]?{digits}|[+-]?({digits}(E|e)[+-]?{digits})
drown			[-]?({digits}\.{digits})((E|e)[+-]?{digits})?
char			'[a-zA-Z]?'
string			\".*\"
bool			true|false
arithmeticop	\+|\-|\*|\/|\%|\+\+|\-\-
relop			==|!=|>|<|<=|>=
logicalop		&&|\|\||!
assignmentop	=|\+=|\-=|\/=|\%=|\*=|<<=|>>=|&=|\^=|\|=
conditionalop	\?
datatype		int|char|bool|drown|struct|string|let
keyword			if|else|for|return|break|continue|void|sizeof|{datatype}|const
identifier		{letter}({letter}|{digit})*
otherpunctuator	\(|\)|\[|\]|\{|\}|;|:
comment			\/\*(.|\n)*\*\/|\/\/.*
otheroperator	,|\.


%%

{keyword}			{	
						if(DEBUG == 1) printf("Keyword : %s \n", yytext);
						if(strcmp(yytext , "int") == 0) {
							//printf(" Returning INT \n");
							yylval.str = strdup(yytext);
							return INT;
						}
						else if(strcmp(yytext , "drown") == 0){
							yylval.str = strdup(yytext);
							return FLOAT;
						}
						else if(strcmp(yytext , "char") == 0) {
							yylval.str = strdup(yytext);
							return CHAR;
						}
						else if(strcmp(yytext , "string") == 0) {
							yylval.str = strdup(yytext);
							return STRING;
						}
						else if(strcmp(yytext , "bool") == 0) {
							yylval.str = strdup(yytext);
							return BOOL;
						}
						// else if(strcmp(yytext , "struct") == 0) {
						// 	yylval.str = strdup(yytext);
						// 	return STRUCT;
						// }
						else {
							yylval.str = strdup(yytext);
							return KEYWORD;
						}
					}

{identifier} 		{
						if(DEBUG == 1) printf("Identifier : %s \n", yytext);
						yylval.str = strdup(yytext);
						return VARIABLE;

					}

{assignmentop}		{
						if(DEBUG == 1)printf("Assignment Op : %s \n", yytext);
						if(strcmp(yytext , "=")  == 0){
							return EQUALS ;
						}
						else{
							yylval.str = strdup(yytext);
							return Assignment_Const;
						}
					}

{integer}			{
						if( DEBUG == 1 )
							printf("INTEGER(%s)", yytext);
						yylval.str = strdup(yytext);
						return INTEGER;
					}

{ws}				{
						if(DEBUG == 1) printf("SPACES \n");
						return SPACES;
						
					}
													;

%%


