%{
	#include "y.tab.h" 
	#include<string.h>

	char symboltable[2000][3][1000];
	int  sym_pointer=0;
	char function[10]={'f','u','n','c','t','i','o','n','\0'};
	char variable[10]={'v','a','r','i','b','l','e','\0'};
	char array[10]={'a','r','r','a','y','\0'};
	char integer[10]={'i','n','t','e','g','e','r','\0'};
	char character[10]={'c','h','a','r','a','c','t','e','r','\0'};
	char drown[10]={'f','l','o','a','t','\0'};
	char boolean[10]={'b','o','o','l','e','a','n','\0'};
	char string[10]={'s','t','r','i','n','g','\0'};

	char id[20]={'I','D','E','N','T','I','F','I','E','R','\0'};
	char constant[20] = {'C', 'O', 'N' , 'S', 'T', 'A', 'N', 'T','\0'};

	int DEBUG = 0;
%}
ws				[ \t\v\n\f]
digit			[0-9]
digits			{digit}+
letter			[a-zA-Z_]
integer			[-]?{digits}|[+-]?({digits}(E|e)[+-]?{digits}) 
drown			[-]?({digits}\.{digits})((E|e)[+-]?{digits})?
char			'[a-zA-Z]?'
string			\".*\"
bool			true|false
identifier		{letter}({letter}|{digit})*

%%
"break"				{
						if( DEBUG == 1) 
							printf("BREAK : %s\n",yytext);
						return BREAK;
					}
"char"				{
						if( DEBUG == 1) 
							printf("CHAR : %s\n",yytext);
						return CHAR;
					}
"const"				{
						if( DEBUG == 1) 
							printf("CONST : %s\n",yytext);
						return CONST;
					}
"continue"			{
						if( DEBUG == 1) 
							printf("CONTINUE : %s\n",yytext);
						return CONTINUE;
					}
"else"				{
						if( DEBUG == 1) 
							printf("ELSE : %s\n",yytext);
						return ELSE;
					}
"elif"				{
						if( DEBUG == 1) 
							printf("ELIF : %s\n",yytext);
						return ELIF;
					}
"float"				{
						if( DEBUG == 1) 
							printf("FLOAT : %s\n",yytext);
						return FLOAT;
					}
"for"				{
						if( DEBUG == 1) 
							printf("FOR : %s\n",yytext);
						return FOR;
					}
"in"				{
						if( DEBUG == 1) 
							printf("IN : %s\n",yytext);
						return IN;
					}
"if"				{
						if( DEBUG == 1) 
							printf("IF : %s\n",yytext);
						return IF;
					}
"int"				{
						if( DEBUG == 1) 
							printf("INT : %s\n",yytext);
						return INT;
					}
"let"				{
						if( DEBUG == 1) 
							printf("LET : %s\n",yytext);
						return LET;
					}
"return"			{
						if( DEBUG == 1) 
							printf("RETURN : %s\n",yytext);
						return RETURN;
					}
"sizeof"			{
						if( DEBUG == 1) 
							printf("SIZEOF: %s\n",yytext);
						return SIZEOF;
					}
"void"				{
						if( DEBUG == 1) 
							printf("VOID : %s\n",yytext);
						return VOID;
					}
"bool"				{
						if( DEBUG == 1) 
							printf("BOOL : %s\n",yytext);
						return BOOL;
					}
"string"			{
						if( DEBUG == 1) 
							printf("STRING : %s\n",yytext);
						return STRING;
					}
"+="				{
						if( DEBUG == 1) 
							printf("ADD_ASSIGN : %s\n",yytext);
						yylval.str = strdup(yytext);
						return ADD_ASSIGN;
					}
"-="				{
						if( DEBUG == 1) 
							printf("SUB_ASSIGN : %s\n",yytext);
						yylval.str = strdup(yytext);
						return SUB_ASSIGN;
					}
"*="				{
						if( DEBUG == 1) 
							printf("MUL_ASSIGN : %s\n",yytext);
						yylval.str = strdup(yytext);
						return MUL_ASSIGN;
					}
"/="				{
						if( DEBUG == 1) 
							printf("DIV_ASSIGN : %s\n",yytext);
						yylval.str = strdup(yytext);
						return DIV_ASSIGN;
					}
"%="				{
						if( DEBUG == 1) 
							printf("MOD_ASSIGN : %s\n",yytext);
						yylval.str = strdup(yytext);
						return MOD_ASSIGN;
					}
"^="				{
						if( DEBUG == 1) 
							printf("POW_ASSIGN : %s\n",yytext);
						yylval.str = strdup(yytext);
						return POW_ASSIGN;
					}
"++"				{
						if( DEBUG == 1) 
							printf("INC_OP : %s\n",yytext);
						yylval.str = strdup(yytext);
						return INC_OP;
					}
"--"				{
						if( DEBUG == 1) 
							printf("DEC_OP : %s\n",yytext);
						yylval.str = strdup(yytext);
						return DEC_OP;
					}
"||"				{
						if( DEBUG == 1) 
							printf("OR_OP : %s\n",yytext);
						yylval.str = strdup(yytext);
						return OR_OP;
					}
"&&"				{
						if( DEBUG == 1) 
							printf("AND_OP : %s\n",yytext);
						yylval.str = strdup(yytext);
						return AND_OP;
					}
"<="				{
						if( DEBUG == 1) 
							printf("LE_OP : %s\n",yytext);
						yylval.str = strdup(yytext);
						return LE_OP;
					}
">="				{
						if( DEBUG == 1) 
							printf("GE_OP : %s\n",yytext);
						yylval.str = strdup(yytext);
						return GE_OP;
					}
"=="				{
						if( DEBUG == 1) 
							printf("EQ_OP : %s\n",yytext);
						yylval.str = strdup(yytext);
						return EQ_OP;
					}
"!="				{
						if( DEBUG == 1) 
							printf("NE_OP : %s\n",yytext);
						yylval.str = strdup(yytext);
						return NE_OP;
					}
";"					{
						if( DEBUG == 1) 
							printf(";: %s\n",yytext);
						yylval.str = strdup(yytext);
						return ';';
					}
"{"					{
						if( DEBUG == 1) 
							printf("{ : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '{';
					}
"}"					{
						if( DEBUG == 1) 
							printf("} : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '}';
					}
","					{
						if( DEBUG == 1) 
							printf(", : %s\n",yytext);
						yylval.str = strdup(yytext);
						return ',';
					}
"="					{
						if( DEBUG == 1) 
							printf("= : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '=';
					}
"("					{
						if( DEBUG == 1) 
							printf("( : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '(';
					}
")"					{
						if( DEBUG == 1) 
							printf(") : %s\n",yytext);
						yylval.str = strdup(yytext);
						return ')';
					}
"["					{
						if( DEBUG == 1) 
							printf("[ : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '[';
					}
"]"					{
						if( DEBUG == 1) 
							printf("] : %s\n",yytext);
						yylval.str = strdup(yytext);
						return ']';
					}
"."					{
						if( DEBUG == 1) 
							printf(". : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '.';
					}
"!"				{
						if( DEBUG == 1) 
							printf("! : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '!';
					}
"&"				{
						if( DEBUG == 1) 
							printf("& : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '&';
					}
"-"				{
						if( DEBUG == 1) 
							printf("- : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '-';
					}
"+"				{
						if( DEBUG == 1) 
							printf("+ : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '+';
					}
"*"				{
						if( DEBUG == 1) 
							printf("* : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '*';
					}
"/"				{
						if( DEBUG == 1) 
							printf("/ : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '/';
					}
"%"				{
						if( DEBUG == 1) 
							printf("%% : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '%';
					}
"<"				{
						if( DEBUG == 1) 
							printf("< : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '<';
					}
">"				{
						if( DEBUG == 1) 
							printf("> : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '>';
					}
"^"				{
						if( DEBUG == 1) 
							printf("^ : %s\n",yytext);
						yylval.str = strdup(yytext);
						return '^';
					}
{char}				{ 
						if(DEBUG == 1) printf("Char Const : %s \n", yytext);
						yylval.str = strdup(yytext);
						for(int i=0;i<strlen(yytext);i++) symboltable[sym_pointer][0][i]=yytext[i];	// installing in the symboltable table
						for(int i=0;i<10;i++) symboltable[sym_pointer][1][i]=character[i];
						for(int i=0;i<20;i++) symboltable[sym_pointer][2][i]=constant[i];
						sym_pointer++;
						return C_CONST;
					}

{string}			{ 	
						if(DEBUG == 1) printf("String Const: %s \n", yytext);
						yylval.str = strdup(yytext);
						for(int i=0;i<strlen(yytext);i++) symboltable[sym_pointer][0][i]=yytext[i];
						for(int i=0;i<10;i++) symboltable[sym_pointer][1][i]=string[i];
						for(int i=0;i<20;i++) symboltable[sym_pointer][2][i]=constant[i];
						sym_pointer++;
						return S_CONST;
					}

{bool}				{ 	
						if(DEBUG == 1) printf("B Const : %s \n", yytext);
						yylval.str = strdup(yytext);
						for(int i=0;i<strlen(yytext);i++) symboltable[sym_pointer][0][i]=yytext[i];
						for(int i=0;i<10;i++) symboltable[sym_pointer][1][i]=boolean[i];
						for(int i=0;i<20;i++) symboltable[sym_pointer][2][i]=constant[i];
						sym_pointer++;
						return B_CONST;

					}

{integer}			{
						if( DEBUG == 1 )
							printf("I CONST: (%s)\n", yytext);
						yylval.str = strdup(yytext);
						for(int i=0;i<strlen(yytext);i++) symboltable[sym_pointer][0][i]=yytext[i];
						for(int i=0;i<10;i++) symboltable[sym_pointer][1][i]=integer[i];
						for(int i=0;i<20;i++) symboltable[sym_pointer][2][i]=constant[i];
						sym_pointer++;
						return I_CONST;
					}

{drown}				{
						if( DEBUG == 1 )
							printf("F_CONST: (%s)\n", yytext);
						yylval.str = strdup(yytext);
						for(int i=0;i<strlen(yytext);i++) symboltable[sym_pointer][0][i]=yytext[i];
						for(int i=0;i<10;i++) symboltable[sym_pointer][1][i]=drown[i];
						for(int i=0;i<20;i++) symboltable[sym_pointer][2][i]=constant[i];
						sym_pointer++;
						return F_CONST;
					}

{identifier} 		{
						if(DEBUG == 1) printf("Identifier : %s \n", yytext);
						yylval.str = strdup(yytext);
						for(int i=0;i<strlen(yytext);i++) symboltable[sym_pointer][0][i]=yytext[i];
						for(int i=0;i<10;i++) symboltable[sym_pointer][1][i]=variable[i];
						for(int i=0;i<20;i++) symboltable[sym_pointer][2][i]=id[i];
						sym_pointer++;
						return IDENTIFIER;

					}


{ws}+				{
					}
%%
