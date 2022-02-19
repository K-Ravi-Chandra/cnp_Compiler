%option yylineno

%{
#include<stdio.h>
#include<iostream>
#include<string.h>
using namespace std;
%}

%%
"int"|"char"|"string"|"drown"|"bool"|"void"|"let"|"del"			{cout << "Keyword " ;}
"const"															{cout << "Constant " ;}
"if"															{cout << "IF " ;}
"elif" 															{cout << "ELIF " ;}
"else"															{cout << "ELSE " ;}
"for"															{cout << "FOR " ;}
"continue"														{cout << "CONTINUE " ;}
"break"															{cout <<  "BREAK " ;}
"struct"														{cout << "STRUCT " ;}
"return"														{cout << "RETURN " ;}
"||" 															{cout << "OR " ;}
"&&"															{cout << "AND " ;}
"=="|"!="														{cout << "EQUAL_Const " ;}
"<="|">="														{cout << "REL_Const " ;}
">>"|"<<"														{cout << "Shift_Const " ;}
"++"|"--"														{cout << "INC_Const " ;}
";"|"="|","|"{"|"}"|"("|")"|"["|"]"|"*"|"+"|"-"|"/"|"?"|":"|"&"|"|"|"^"|"!"|"~"|"%"|"<"|">"					{cout << yytext[0] << " ";}
"*="|"/="|"+="|"%="|"-="|"^="									{cout << "Assignment_Const " ;}
[0-9]+															{cout <<  "INT_Const " ;}
[0-9]+"."[0-9]+													{cout << "DROWN_Const " ;}	
"'"."'"															{cout <<  "Char_Const " ;}
[a-zA-z_][a-zA-z_0-9]*			 								{cout << "Identifier " ;}
\"(\\.|[^\"])*\"												{cout << "STRING " ;}
"//"(\\.|[^\n])*[\n]											;
[/][*]([^*]|[*]*[^*/])*[*]+[/]                                  ;
[ \t\n]															;

%%

int yywrap(void){return 1;}

int main()
{
	yylex();
	return 0;
}
