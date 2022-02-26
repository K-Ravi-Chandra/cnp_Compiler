%{
#include<stdio.h>
#include<string.h>
#include<iostream>
#include<unordered_map>
#include<vector>
using namespace std; extern FILE* yyin;
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
		return 1; } }

string code = "";
vector<string> variables;
vector<string> variableInit;
string dtype;
unordered_map<string,string> symbolTable;

int tempint = 1;
int labelint = 1;

char* getTemp()
{
	string temp = "t" + to_string(tempint);
	char* t = (char*) malloc((temp.length()-1)*sizeof(char));
	strcpy(t, temp.c_str());
	tempint++;
	return t;
}

char* getLabel()
{
	string temp = "label" + to_string(labelint);
	char* t = (char*) malloc((temp.length()-1)*sizeof(char));
	strcpy(t, temp.c_str());
	labelint++;
	return t;
}
%}

%union
{
	char* str;
	int intval;
	int br;
	int con;
	struct
	{
		char* type;
		char* addr;
	} var;
	char* op;
};

%token BREAK CHAR CONST CONTINUE ELSE ELIF FLOAT FOR IN IF INT RETURN SIZEOF VOID BOOL STRING ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN POW_ASSIGN INC_OP DEC_OP OR_OP AND_OP LE_OP GE_OP EQ_OP NE_OP C_CONST S_CONST B_CONST I_CONST F_CONST IDENTIFIER LET

%start statement_block
%%
	primary_expression								
		:	IDENTIFIER						{	
												$<var.addr>$ = $<str>1 ; 
												if( symbolTable.find(string($<str>1)) == symbolTable.end() )
												{
													cout << "ERROR: no variable called " << string($<str>1) << endl;
													return 1;
												}
												string temp = symbolTable[string($<str>1)];
												char* f = new char[temp.length()-1];
												strcpy(f, temp.c_str());
												$<var.type>$ = f;
											}	
			| constant						{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
											}
			| '(' expression ')'			{
												$<var.addr>$ = $<var.addr>2;
												$<var.type>$ = $<var.type>2;
											}
			;

	constant
		:	I_CONST							{
												string temp = "int";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;
									
												$<var.addr>$ = getTemp();
												code += string($<var.addr>$) + " = " + "i" + $<str>1 + "\n";
											}
			| F_CONST						{
												string temp = "float";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;
									
												$<var.addr>$ = getTemp();
												code += string($<var.addr>$) + " = " + "f" + $<str>1 + "\n";
											}
			| C_CONST						{
												string temp = "char";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;
									
												$<var.addr>$ = getTemp();
												code += string($<var.addr>$) + " = " + "c" + $<str>1 + "\n";
											}
			| S_CONST						{
												string temp = "string";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;
									
												$<var.addr>$ = getTemp();
												code += string($<var.addr>$) + " = " + "s" + $<str>1 + "\n";
											}
			| B_CONST						{
												string temp = "bool";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;
									
												$<var.addr>$ = getTemp();
												code += string($<var.addr>$) + " = " + "b" + $<str>1 + "\n";
											}
			;

	postfix_expression
		:	primary_expression				{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
											}
			| postfix_expression '[' expression ']'
			| postfix_expression INC_OP		{
												if( strcmp($<var.type>1,"int") != 0 )
												{
													cout << "ERROR: cannot apply increment operator to non int types" << endl;
													return 1;
												}
												$<var.addr>$ = getTemp();
												code += string($<var.addr>$) + " = " + string($<var.addr>1) + "\n";
												code += string($<var.addr>1) + " = " + string($<var.addr>1) + " +i " + "#i1\n";
											}	
			| postfix_expression DEC_OP		{
												if( strcmp($<var.type>1,"int") != 0 )
												{
													cout << "ERROR: cannot apply decrement operator to non int types" << endl;
													return 1;
												}
												$<var.addr>$ = getTemp();
												code += string($<var.addr>$) + " = " + string($<var.addr>1) + "\n";
												code += string($<var.addr>1) + " = " + string($<var.addr>1) + " -i " + "#i1\n";
											}
			;
	
	unary_expression
		:	postfix_expression				{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
											}
			| INC_OP unary_expression		{
												if( strcmp($<var.type>1,"int") != 0 )
												{
													cout << "ERROR: cannot apply decrement operator to non int types" << endl;
													return 1;
												}
												$<var.addr>$ = getTemp();
												code += string($<var.addr>1) + " = " + string($<var.addr>1) + " +i " + "#i1\n";
												code += string($<var.addr>$) + " = " + string($<var.addr>1) + "\n";
											}
			| DEC_OP unary_expression		{
												if( strcmp($<var.type>1,"int") != 0 )
												{
													cout << "ERROR: cannot apply decrement operator to non int types" << endl;
													return 1;
												}
												$<var.addr>$ = getTemp();
												code += string($<var.addr>1) + " = " + string($<var.addr>1) + " -i " + "#i1\n";
												code += string($<var.addr>$) + " = " + string($<var.addr>1) + "\n";
											}
			| unary_operator unary_expression
											{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
												string op($<str>1);
												string type($<var.type>2); 
												if( op == "+" or op == "-" )
												{
													if( type != "int" and type != "float" )
													{
														cout << "ERROR: cannot apply + to not number types" << endl;
														return 1;
													}
													else
													{
														if( op == "-" )
														{
															$<var.addr>$ = getTemp();
															code += string($<var.addr>1) + " = " + "minus" + string($<var.addr>1) + "\n";
														}
													}
												}
												if( op == "!" )
												{
													if( type != "bool" )
													{
														cout << "ERROR: cannot apply ! to non bool types" << endl;
														return 1;
													}
													else
													{
														$<var.addr>$ = getTemp();
														code += string($<var.addr>1) + " = " + "not" + string($<var.addr>1) + "\n";
													}
												}	
											}
			| SIZEOF '(' type_name ')'
			| SIZEOF unary_expression
			;
	
	type_name		
		:	INT				{	dtype = "int"; variables.clear(); variableInit.clear(); }	
			| FLOAT			{	dtype = "float"; variables.clear(); variableInit.clear(); }
			| CHAR			{   dtype = "char"; variables.clear(); variableInit.clear(); }
			| STRING		{ 	dtype = "string"; variables.clear(); variableInit.clear(); }
			| BOOL			{ 	dtype = "bool"; variables.clear(); variableInit.clear(); }
			| LET			{	dtype = "let"; variables.clear(); variableInit.clear(); }
			;

	unary_operator
		:	'+'				{	
								$<str>$ = $<str>1;
							}
			| '-'			{	
								$<str>$ = $<str>1;
							}
			| '!'			{
								$<str>$ = $<str>1;
							}
			;
	
	multiplicative_expression
		:	unary_expression				{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
											}
			| multiplicative_expression '*' unary_expression
											{
												string type1($<var.type>1);
												string type2($<var.type>3);
												if( type1 != "int" and type1 != "float" or type2 != "int" and type2 != "float" )
												{
													cout << "ERROR: cannot multiply non-number types" << endl;
													return 1;
												}
												else
												{
													if( type1 == "int" and type2 == "int" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " = " + string($<var.addr>1) + " *i " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " = " + string($<var.addr>1) + " *f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "int" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>3;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>1) + ")\n";
														code += string($<var.addr>$) + " = " + string(temp) + " *f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "int" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>3) + ")\n";
														code += string($<var.addr>$) + " = " + string($<var.addr>1) + " *f " +  string(temp) + "\n";
													}
												}
											}
			| multiplicative_expression '/' unary_expression
											{	
												string type1($<var.type>1);
												string type2($<var.type>3);
												if( type1 != "int" and type1 != "float" or type2 != "int" and type2 != "float" )
												{
													cout << "ERROR: cannot divide non-number types" << endl;
													return 1;
												}
												else
												{
													if( type1 == "int" and type2 == "int" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " = " + string($<var.addr>1) + " /i " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " = " + string($<var.addr>1) + " /f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "int" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>3;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>1) + ")\n";
														code += string($<var.addr>$) + " = " + string(temp) + " /f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "int" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>3) + ")\n";
														code += string($<var.addr>$) + " = " + string($<var.addr>1) + " /f " +  string(temp) + "\n";
													}
												}
											}
			| multiplicative_expression '%' unary_expression
											{
												string type1($<var.type>1);
												string type2($<var.type>3);
												if( type1 != "int" or type2 != "int" )
												{
													cout << "ERROR: cannot apply modulus to  non-integer types" << endl;
													return 1;
												}
												else
												{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " = " + string($<var.addr>1) + " % " +  string($<var.addr>3) + "\n";
												}
											}
			;
	additive_expression
		:	multiplicative_expression		{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
											}
			| additive_expression '+' multiplicative_expression
											{
												string type1($<var.type>1);
												string type2($<var.type>3);
													if( type1 == "int" and type2 == "int" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " = " + string($<var.addr>1) + " +i " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " = " + string($<var.addr>1) + " +f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "int" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>3;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>1) + ")\n";
														code += string($<var.addr>$) + " = " + string(temp) + " +f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "int" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>3) + ")\n";
														code += string($<var.addr>$) + " = " + string($<var.addr>1) + " +f " +  string(temp) + "\n";
													}
												else if( type1 == "string" and type2 == "string" )
												{
														$<var.type>$ = $<var.type>1;
														$<var.addr>$ = getTemp();
														code += string($<var.addr>$) + " = strcat(" + string($<var.addr>1) + "," +  string($<var.addr>3) + ")\n";
												}
												else if( type1 == "string" and type2 == "char" )
												{
														$<var.type>$ = $<var.type>1;
														$<var.addr>$ = getTemp();
														code += string($<var.addr>$) + " = strcatc(" + string($<var.addr>1) + "," +  string($<var.addr>3) + ")\n";
												}
												else if( type1 == "char" and type2 == "int" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " = " + string($<var.addr>1) + " +b " +  string($<var.addr>3) + "\n";
													}
													else
													{
														cout << "Invalide operands for +" << endl;
														return 1;
													}
											}
			| additive_expression '-' multiplicative_expression
											{
												string type1($<var.type>1);
												string type2($<var.type>3);
													if( type1 == "int" and type2 == "int" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " = " + string($<var.addr>1) + " -i " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " = " + string($<var.addr>1) + " -f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "int" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>3;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>1) + ")\n";
														code += string($<var.addr>$) + " = " + string(temp) + " -f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "int" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>3) + ")\n";
														code += string($<var.addr>$) + " = " + string($<var.addr>1) + " -f " +  string(temp) + "\n";
													}
													else
													{
														cout << "ERROR: invalid operands for -" << endl;
														return 1;
													}
											}
			;
	
	relational_expression
		:	additive_expression				{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
											}
			| relational_expression '<' additive_expression
											{
												if( string($<var.addr>1) == "bool" or string($<var.addr>1) == "string" or string($<var.addr>2) == "bool" or string($<var.addr>2) == "string")
												{
													cout << "Invalid Operands for '<'" << endl;
													return 1;
												}
												string temp = "bool";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;

												$<var.addr>$ = getTemp();
												string label1 = getLabel();
												string label2 = getLabel();
												code += "if(" + string($<var.addr>1) + " < " + string($<var.addr>3) + ") goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " = " + "false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " = " + "true\n";
												code += string(label2) + ":\n";	
											}
			| relational_expression '>' additive_expression
											{
												if( string($<var.addr>1) == "bool" or string($<var.addr>1) == "string" or string($<var.addr>2) == "bool" or string($<var.addr>2) == "string")
												{
													cout << "Invalid Operands for '>'" << endl;
													return 1;
												}
												string temp = "bool";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;

												$<var.addr>$ = getTemp();
												string label1 = getLabel();
												string label2 = getLabel();
												code += "if(" + string($<var.addr>1) + " > " + string($<var.addr>3) + ") goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " = " + "false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " = " + "true\n";
												code += string(label2) + ":\n";
											}
			| relational_expression LE_OP additive_expression
											{
												if( string($<var.addr>1) == "bool" or string($<var.addr>1) == "string" or string($<var.addr>2) == "bool" or string($<var.addr>2) == "string")
												{
													cout << "Invalid Operands for '<='" << endl;
													return 1;
												}
												string temp = "bool";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;

												$<var.addr>$ = getTemp();
												string label1 = getLabel();
												string label2 = getLabel();
												code += "if(" + string($<var.addr>1) + " <= " + string($<var.addr>3) + ") goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " = " + "false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " = " + "true\n";
												code += string(label2) + ":\n";
											}
			| relational_expression GE_OP additive_expression
											{
												if( string($<var.addr>1) == "bool" or string($<var.addr>1) == "string" or string($<var.addr>2) == "bool" or string($<var.addr>2) == "string")
												{
													cout << "Invalid Operands for '>='" << endl;
													return 1;
												}
												string temp = "bool";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;

												$<var.addr>$ = getTemp();
												string label1 = getLabel();
												string label2 = getLabel();
												code += "if(" + string($<var.addr>1) + " >= " + string($<var.addr>3) + ") goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " = " + "false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " = " + "true\n";
												code += string(label2) + ":\n";
											}
			;
	
	equality_expression
		:	relational_expression			{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
											}
			| equality_expression EQ_OP relational_expression
											{
												if( strcmp($<var.type>1, $<var.type>3) != 0 )
												{
													cout << "ERROR: cannot compare two different operands" << endl;
													return 1;
												}
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
												string temp = "bool";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;

												$<var.addr>$ = getTemp();
												string label1 = getLabel();
												string label2 = getLabel();
												code += "if(" + string($<var.addr>1) + " == " + string($<var.addr>3) + ") goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " = " + "false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " = " + "true\n";
												code += string(label2) + ":\n";
											}
			| equality_expression NE_OP relational_expression
											{
												if( strcmp($<var.type>1, $<var.type>3) != 0 )
												{
													cout << "ERROR: cannot compare two different operands" << endl;
													return 1;
												}
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
												string temp = "bool";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;

												$<var.addr>$ = getTemp();
												string label1 = getLabel();
												string label2 = getLabel();
												code += "if(" + string($<var.addr>1) + " != " + string($<var.addr>3) + ") goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " = " + "false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " = " + "true\n";
												code += string(label2) + ":\n";
											}	
			;

	logical_and_expression
		:	equality_expression				{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
											}
			| logical_and_expression AND_OP equality_expression
											{
												if( strcmp($<var.type>1, "bool") != 0 or strcmp($<var.type>3, "bool") != 0 )
												{
													cout << "ERROR: cannot apply '&&' to non-boolean operands" << endl;
													return 1;
												}

												$<var.addr>$ = getTemp();
												$<var.type>$ = $<var.type>1;
												char* label1 = getLabel();
												code += "if(" + string($<var.addr>1) + " == " + "false) goto " + string(label1) + "\n";
												code += "if(" + string($<var.addr>3) + " == " + "false) goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " = " + "btrue\n";
												char* label2 = getLabel();
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " = " + "false\n";
												code += string(label2) + ":\n";
											}
			;
	
	logical_or_expression
		:	logical_and_expression			{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
											}
			| logical_or_expression OR_OP	logical_and_expression
											{
												if( strcmp($<var.type>1, "bool") != 0 or strcmp($<var.type>3, "bool") != 0 )
												{
													cout << "ERROR: cannot apply '||' to non-boolean operands" << endl;
													return 1;
												}
												$<var.addr>$ = getTemp();
												$<var.type>$ = $<var.type>1;

												char* label1 = getLabel();
												code += "if(" + string($<var.addr>1) + " == " + "true) goto " + string(label1) + "\n";
												code += "if(" + string($<var.addr>3) + " == " + "true) goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " = " + "false\n";
												char* label2 = getLabel();
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " = " + "true\n";
												code += string(label2) + ":\n";
											}
			;

	expression
		: 	logical_or_expression			{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
											}
			;

	assignment_operator
		:	'='						{	$<str>$ = $<str>1;	}
			| MUL_ASSIGN			{	$<str>$ = $<str>1;	}
			| DIV_ASSIGN			{	$<str>$ = $<str>1;	}
			| MOD_ASSIGN			{	$<str>$ = $<str>1;	}
			| ADD_ASSIGN			{	$<str>$ = $<str>1;	}
			| SUB_ASSIGN			{	$<str>$ = $<str>1;	}
			| POW_ASSIGN			{	$<str>$ = $<str>1;	}
			;

	assignment_expression
		: 	unary_expression assignment_operator expression
									{
										string op($<str>2);
										string ltype($<var.type>1);
										string rtype($<var.type>3);
										string type1 = ltype;
										string type2 = ltype;
										string var($<var.addr>1);
										string val($<var.addr>3);

										if( op == "=" )
										{
											if( ltype == rtype )
											{
												code += var + " = " + val + "\n";
											}
											else if( ltype == "float" and rtype == "int" )
											{
												char* t = getTemp();
												code += string(t) + " = " + "elevateToFloat(" + val + ")\n";
												code += var + " = " + string(t) + "\n";
											}
											else
											{
												cout << "ERROR: different operands type to '='" << endl;
												return 1;
											}
										}
										else if( op[0] == '%' )
										{
											if( ltype != "int" or rtype != "int" )
											{
												cout << "ERROR: non-int operands to %" << endl;
												return 1;
											}
											else
											{
												code += var + " = " + var + " % " + val + "\n";
											}
										}
										else if( op[0] == '^' or op[0] == '-' or op[0] == '/' or op[0] == '*')
										{
											if( ltype != "int" and ltype != "float" or rtype != "int" and rtype != "float" )
											{
												cout << "ERROR: invalid operands for "  << op << endl;
												return 1;
											}
											else
											{
													if( type1 == "int" and type2 == "int" )
													{
														code += var + " = " + var + " " + op[0] + "i " +  val + "\n";
													}
													else if( type1 == "float" and type2 == "float" )
													{
														code += var + " = " + var + " " + op[0] + "f " +  val + "\n";
													}
													else if( type1 == "int" and type2 == "float" )
													{
														cout << "ERROR: cannot convert int to float" << endl;
														return 1;
													}
													else if( type1 == "float" and type2 == "int" )
													{
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + val + ")\n";
														code += var + " = " + var + " " + op[0] + "f " +  string(temp) + "\n";
													}
											}
										}
										else if( op[0] == '+' )
										{
													if( type1 == "int" and type2 == "int" )
													{
														code += var + " = " + var + " " + op[0] + "i " +  val + "\n";
													}
													else if( type1 == "float" and type2 == "float" )
													{
														code += var + " = " + var + " " + op[0] + "f " +  val + "\n";
													}
													else if( type1 == "int" and type2 == "float" )
													{
														cout << "ERROR: cannot convert int to float" << endl;
														return 1;
													}
													else if( type1 == "float" and type2 == "int" )
													{
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + val + ")\n";
														code += var + " = " + var + " " + op[0] + "f " +  string(temp) + "\n";
													}
												else if( type1 == "string" and type2 == "string" )
												{
														code += var + " = strcat(" + var + "," +  val  + ")\n";
												}
												else if( type1 == "string" and type2 == "char" )
												{
														code += var + " = strcatc(" + var + "," +  val  + ")\n";
												}
												else if( type1 == "char" and type2 == "int" )
													{
														code += var + " = " + var + " +b " +  val + "\n";
													}
													else
													{
														cout << "Invalide operands for +" << endl;
														return 1;
													}
										}
									}
			;


	declaration_expression
		:	type_name declarationlist		{
												for(int i = 0 ; i < variables.size() ; i++ )
												{
													code += dtype + " " + variables[i] + "\n";
													if( symbolTable.find(variables[i]) != symbolTable.end() )
													{
														cout << "ERROR: variable already declared: " << variables[i] << endl;
														return 1;
													}
													symbolTable[variables[i]] = dtype;
												}
												for( int i = 0 ; i < variableInit.size() ; i++ )
												{
													code += variableInit[i];
												}
											}
			;
	
	declarationlist
		: 	declaration ',' declarationlist
			| declaration
			;
	
	declaration
		:	IDENTIFIER						{
												string var($<str>1);
												variables.push_back(var);
											}
			| IDENTIFIER '=' expression		{
												string var($<str>1);
												variables.push_back(var);
												string addr($<var.addr>3);
												variableInit.push_back(var + " = " + addr + "\n");
											}
			;

	conditional_expression
		:	IF '(' expression ')'
											{
												string expr($<var.addr>3);
												string label1 = getLabel();
												
												char* f = new char[label1.length()-1];
												strcpy(f, label1.c_str());
												$<str>1 = f;

												code += "if(" + expr + " != true) goto " + label1 + "\n";
											}
			statement_block 
											{
												code += string($<str>1) + ":\n";
											}
			else_statement
			;
	
	else_statement
		:	ELIF '(' expression ')' 
											{
												string expr($<var.addr>3);
												string label1 = getLabel();
												
												char* f = new char[label1.length()-1];
												strcpy(f, label1.c_str());
												$<str>1 = f;

												code += "if(" + expr + " != true) goto " + label1 + "\n";
											}
			statement_block 				{
												code += string($<str>1) + ":\n";
											}
			else_statement					{
												$<str>$ = $<str>6;
											}
				
			| ELSE statement_block			{
												string label = getLabel();
												code += label + ";\n";
												char* f = new char[label.length()-1];
												strcpy(f, label.c_str());
												$<str>$ = f;
											}

			|								{
												string label = getLabel();
												code += label + ";\n";
												char* f = new char[label.length()-1];
												strcpy(f, label.c_str());
												$<str>$ = f;
											}

	statement
		: 	assignment_expression ';'
			| declaration_expression ';'
			| conditional_expression
			;

	statement_list
		: 	statement statement_list
			| statement
			;

	statement_block
		:	'{' statement_list '}'
			| '{' '}'
			;

%%


int main( int argcount, char* arguements[] )
{
	yyin = fopen(arguements[1], "r");
	yyparse();
	cout << "symbol table" << endl;
	for(auto x : symbolTable)
	{
		cout << x.first << " " << x.second << endl;
	}
	cout << endl;
	cout << "Code: " << endl;
	cout << code << endl;
	return 0;
}
