%{
#include<stdio.h>
#include<iostream>
using namespace std;
extern FILE* yyin;
extern int DEBUG;
extern "C"
{
	int yyparse(void);
	int yylex(void);
	void yyerror(const char* s)
	{
		printf("Error is ");
		printf("%s\n", s);
		return;
	}
	int yywrap()
	{
		return 1;
	}
}

string code = "";

%}

%union
{
	char* str;
	int intval;
};

%token INT BOOL SPACES VARIABLE EQUALS INTEGER STRING FLOAT CHAR KEYWORD Assignment_Const

%%


Statements:	Statement SPACES Statements
			|
			; 

Statement:	Declaration
			;

Declaration:Type SPACES VARIABLE SPACES EQUALS SPACES INTEGER
				{
					string s = $<str>1;
					string c = s + " ";
					s = $<str>3;
					c += s + " = ";
					s = $<str>7;
					c += s;
					if( DEBUG == 1 )
					{
						cout << c << endl;
					}
					code += c + "\n";
				}
			;

Type:	INT 
			{
				$<str>$ = $<str>1;
			}
		| BOOL 
			{
				$<str>$ = $<str>1;
			}
		| STRING {
					$<str>$ = $<str>1;
				}
		| FLOAT {
					$<str>$ = $<str>1;
				}
		| CHAR	
			{
				$<str>$ = $<str>1;
			}
		;
%%

int main( int argcount, char* arguements[] )
{
	yyin = fopen(arguements[1], "r");
	yyparse();
	cout << "Code: " << endl;
	cout << code << endl;
	return 0;
}
