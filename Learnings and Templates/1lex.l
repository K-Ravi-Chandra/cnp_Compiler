%{
#include<stdio.h>
#include<iostream>
#include<string.h>
using namespace std;
%}

%%
"int"		{
				cout << "INT" << endl;	
			}

%%

int yywrap(void){return 0;}

int main()
{
	yylex();
	return 0;
}
