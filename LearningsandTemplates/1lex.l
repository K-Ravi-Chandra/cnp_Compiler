

%{

#include<string.h>
#include "y.tab.h" 

	
int DEBUG = 0;

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
scol 			;
otherpunctuator	\(|\)|\[|\]|\{|\}|:
comment			\/\*(.|\n)*\*\/|\/\/.*
otheroperator	,|\.


%%

{char}				{ 
						if(DEBUG == 1) printf("Char Const : %s \n", yytext);
						yylval.str = strdup(yytext);
						return CHARACTER_CONST;
					}

{string}			{ 	
						if(DEBUG == 1) printf("String Const: %s \n", yytext);
						yylval.str = strdup(yytext);
						return STRING_CONST;
					}

{bool}				{ 	
						if(DEBUG == 1) printf("Bool Const : %s \n", yytext);
						yylval.str = strdup(yytext);
						return BOOL_CONST;
					}

{integer}			{
						if( DEBUG == 1 )	printf("INTEGER CONST(%s)", yytext);
						yylval.str = strdup(yytext);
						return INTEGER_CONST;
					}

{drown}				{
						if( DEBUG == 1 )
							printf("DROWN CONST(%s)", yytext);
						yylval.str = strdup(yytext);
						return DROWN_CONST;
					}

"+"					{
						if( DEBUG == 1 )
							printf("Arithmetic operator (or) pointer : %s", yytext);
						return PLUS;
					}

{arithmeticop}		{
						if(DEBUG == 1)printf("Arithmetic Op : %s \n", yytext);
						yylval.str = strdup(yytext);
						return ARITHMETIC_OP;
					}

{relop}				{
						if(DEBUG == 1)printf("Relational Op : %s \n", yytext);
						yylval.str = strdup(yytext);
						return RELATIONAL_OP;
					}

{logicalop}			{
						if(DEBUG == 1)printf("Logical  Op : %s \n", yytext);
						yylval.str = strdup(yytext);
						return LOGICAL_OP;
					}

{assignmentop}		{
						if(DEBUG == 1)printf("Assignment Op : %s \n", yytext);
						if(strcmp(yytext , "=")  == 0){
							return EQUALS ;
						}
						else{
							yylval.str = strdup(yytext);
							return ASSIGNMENT_OP;
						}
					}


{keyword}/.*		{	
						if(DEBUG == 1) printf("Keyword : %s \n", yytext);
						if(strcmp(yytext , "int") == 0) {
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
						else if(strcmp(yytext , "struct") == 0) {
							yylval.str = strdup(yytext);
							return STRUCT;
						}
						else {
							yylval.str = strdup(yytext);
							return KEYWORD;
						}
					}

{conditionalop}		{
						if(DEBUG == 1) printf("Conditional OP : %s \n", yytext);
						yylval.str = strdup(yytext);
						return CONDITIONAL_OP;

					}

{identifier}/\[.*\] {
						if(DEBUG == 1) printf("Identifier Array : %s \n", yytext);
						yylval.str = strdup(yytext);
						return IDENTIFIER_ARRAY;

					}

{otherpunctuator}	{
						if(DEBUG == 1) printf("Punctuator : %s \n", yytext);
						yylval.str = strdup(yytext);
						return PUNCTUATOR;
					}

{comment}			{
						if(DEBUG == 1) printf("Comment : %s \n", yytext);
					}

{otheroperator}		{
						if(DEBUG == 1) printf("Other Operator : %s \n", yytext);
						yylval.str = strdup(yytext);
						return OTHER_OP;
					}

{identifier}/{ws}*\( {
						if(DEBUG == 1) printf("Identifier Function : %s \n", yytext);
						yylval.str = strdup(yytext);
						return IDENTIFIER_FUNC;

					}

{identifier} 		{
						if(DEBUG == 1) printf("Identifier : %s \n", yytext);
						yylval.str = strdup(yytext);
						return IDENTIFIER;

					}

{scol}				{
						if(DEBUG == 1) printf("SCOL : %s \n", yytext);
						return SCOL;
					}


{ws}				{
						if(DEBUG == 1) printf("SPACES \n");
						return SPACES;
						
					}

.					{}

%%


