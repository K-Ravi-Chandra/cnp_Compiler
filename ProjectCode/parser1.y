%{
#include<fstream>
#include<stdio.h>
#include<string.h>
#include<iostream>
#include<unordered_map>
#include<vector>
#include<stack>
using namespace std; extern FILE* yyin;
extern int DEBUG;
int parseDebug = 0;
int symbolDebug = 1;
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
vector<pair<string, string>> variableInit;
string dtype;
//unordered_map<string,string> symbolTable;
stack<string> ifgoto;
string forExprVal;

int tempint = 1;
int labelint = 1;

char* getTemp()
{
	string temp = "t" + to_string(tempint);
	char* t = (char*) malloc((temp.length()-1)*sizeof(char));
	strcpy(t, temp.c_str());
	tempint++;
	code += "int " + temp + "\n";
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

int currentScope = 0;

class symbolTableEntry
{
	public:
		string name;
		string dataType;
		int levels;
		int scope;
};

vector<symbolTableEntry> symbolTable;

int insertEntry( string name, string dataType )
{
	for( int i = 0 ; i < symbolTable.size() ; i++ )
	{
		if( symbolTable[i].name == name and symbolTable[i].scope == currentScope )
		{
			return -1;
		}
	}
	symbolTableEntry ste;

	ste.name = name;
	ste.dataType = dataType;
	ste.scope = currentScope;
	ste.levels = 0;
	symbolTable.push_back(ste);
	return 0;
}
int insertEntry( string name, string dataType, int level )
{
	for( int i = 0 ; i < symbolTable.size() ; i++ )
	{
		if( symbolTable[i].name == name and symbolTable[i].scope == currentScope )
		{
			return -1;
		}
	}
	symbolTableEntry ste;

	ste.name = name;
	ste.dataType = dataType;
	ste.scope = currentScope;
	ste.levels = level;
	symbolTable.push_back(ste);
	return 0;
}

void printSymbolTable()
{
	cout << "symbol table:" << endl;
	cout << "name        datatype       scope         levels" << endl;
	for( int i = 0 ; i < symbolTable.size() ; i++ )
	{
		cout << symbolTable[i].name << " " << symbolTable[i].dataType << " " << symbolTable[i].scope << " " << symbolTable[i].levels << endl;
	}
	cout << endl;
}

int deleteEntry( string name, int scope )
{
	for( int i = 0 ; i < symbolTable.size() ; i++ )
	{
		if( symbolTable[i].name == name and symbolTable[i].scope == scope )
		{
			symbolTable.erase(symbolTable.begin()+i);
			return 0;
		}

	}
	return -1;
}

int deleteEntries( int scope )
{
	bool b = true;
	while( b )
	{
		bool c = true;
		for( int i = 0 ; i < symbolTable.size() ; i++ )
		{
			if( symbolTable[i].scope == scope )
			{
				symbolTable.erase(symbolTable.begin()+i);
				c = false;
				break;
			}
		}
		if( c )
		{
			break;
		}
	}
	return 1;
}

string getName( string name )
{
	string res  = "";
	int scope = 0;
	for( int i = 0 ; i < symbolTable.size() ; i++ )
	{
		if( symbolTable[i].name == name  )
		{
			if( name == "" )
			{
				res = symbolTable[i].name;
			}
			else
			{
				if( symbolTable[i].scope > scope )
				{
					name = symbolTable[i].name;
					string s = to_string(symbolTable[i].scope);
					res = symbolTable[i].name + "^" + s;
				}
			}
		}
	}
	return res;
}

int getLevel( string name )
{
	//cout << name << endl;
	string origName = "";
	string scope = "";

	bool b = true;
	for( int i = 0 ; i < name.size() ; i++ )
	{
		if( name[i] != '^' and b == true )
		{
			origName += name[i];
		}
		else if( name[i] == '^' )
		{
			b = false;
		}
		else if( name[i] != '^' and b == false )
		{
			scope += name[i];
		}
	}

	cout << origName << endl;
	cout << scope << endl;

	//int s = stoi(scope);
	int s = 1;

	for( int i = 0 ; i < symbolTable.size() ; i++ )
	{
		if( origName == symbolTable[i].name and s == symbolTable[i].scope )
		{
			return symbolTable[i].levels;
		}
	}
	return 0;
}

string getType( string name )
{
	int scope = 0;
	string type = "";
	for( int i = 0 ; i < symbolTable.size() ; i++ )
	{
		if( symbolTable[i].name == name  )
		{
			if( type == "" )
			{
				type = symbolTable[i].dataType;
			}
			else
			{
				if( symbolTable[i].scope > scope )
				{
					type = symbolTable[i].dataType;
				}
			}
		}
	}
	return type;
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
	struct
	{
		char* addr;
		char* type;
		int arr;
		int level;
		char* index;
		int completed;
	}array;
	char* op;
};

%token BREAK CHAR CONST CONTINUE ELSE ELIF FLOAT FOR IN IF INT RETURN SIZEOF VOID BOOL STRING ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN POW_ASSIGN INC_OP DEC_OP OR_OP AND_OP LE_OP GE_OP EQ_OP NE_OP C_CONST S_CONST B_CONST I_CONST F_CONST IDENTIFIER LET PRINT SCAN MAIN

%start begin
%%
	primary_expression								
		:	IDENTIFIER						{	
												if( getName(string($<str>1)) == "" )
												{
													cout << "ERROR: no variable called " << string($<str>1) << endl;
													return 1;
												}

												string temp = getType(string($<str>1));
												char* f = new char[temp.length()-1];
												strcpy(f, temp.c_str());
												$<var.type>$ = f;

												temp = getName(string($<str>1)) ; 
												char* g = new char[temp.length()-1];
												strcpy(g, temp.c_str());
												$<var.addr>$ = g;

												if( parseDebug == 1 )
												{
													cout << "primary_expression -> IDENTIFIER" << endl;
												}
											}	
			| constant						{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
												if( parseDebug == 1 )
												{
													cout << "primary_expression -> constant" << endl;
												}
											}
			| '(' expression ')'			{
												$<var.addr>$ = $<var.addr>2;
												$<var.type>$ = $<var.type>2;
												if( parseDebug == 1 )
												{
													cout << "primary_expression -> ( expression )" << endl;
												}
											}
			; 
	constant
		:	I_CONST							{
												string temp = "int";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;
									
												$<var.addr>$ = getTemp();
												code += string($<var.addr>$) + " =i #" + $<str>1 + "\n";
												if( parseDebug == 1 )
												{
													cout << "constant -> I_const" << endl;
												}
											}
			| F_CONST						{
												string temp = "float";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;
									
												$<var.addr>$ = getTemp();
												code += string($<var.addr>$) + " =f #" + $<str>1 + "\n";
												if( parseDebug == 1 )
												{
													cout << "constant -> F_const" << endl;
												}
											}
			| C_CONST						{
												string temp = "char";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;
									
												$<var.addr>$ = getTemp();
												code += string($<var.addr>$) + " =c #" + $<str>1 + "\n";
												if( parseDebug == 1 )
												{
													cout << "constant -> C_const" << endl;
												}
											}
			| S_CONST						{
												string temp = "string";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;
									
												$<var.addr>$ = getTemp();
												code += string($<var.addr>$) + " =s #" + $<str>1 + "\n";
												if( parseDebug == 1 )
												{
													cout << "constant -> S_const" << endl;
												}
											}
			| B_CONST						{
												string temp = "bool";
												char* i = new char[temp.length()-1];
												strcpy(i, temp.c_str());
												$<var.type>$ = i;
									
												$<var.addr>$ = getTemp();
												code += string($<var.addr>$) + " =b #" + $<str>1 + "\n";
												if( parseDebug == 1 )
												{
													cout << "constant -> B_const" << endl;
												}
											}
			;

	postfix_expression
		:	primary_expression				{
												string s($<var.type>1);
												char s1[s.size()+1];
												strcpy(s1, s.c_str());
												char* token = strtok(s1, " ");
												vector<string> tokens;
												while(token != NULL)
												{
													tokens.push_back(token);
													token = strtok(NULL, " ");
												}

												if( tokens.size() == 1 )
												{
													$<array.addr>$ = $<var.addr>1;
													$<array.type>$ = $<var.type>1;
													$<array.index>$ = NULL;
													$<array.completed>$ = 1;
												}
												else
												{
													char* temp = (char*) calloc(tokens[0].size()+1, sizeof(char));
													strcpy(temp, tokens[0].c_str());
													$<array.addr>$ = $<var.addr>1;
													$<array.type>$ = temp;
													$<array.completed>$ = 0;
													$<array.level>$ = 0;
													$<array.index>$ = getTemp();
													code += string($<array.index>$) + " =i #0\n"; 
												}
												if( parseDebug == 1 )
												{
													cout << "postfix_expression -> primary_expression" << endl;
												}
											}
			| postfix_expression '[' expression ']'
											{
												int level = getLevel(string($<array.addr>1));
												if( $<array.completed>$ == 1 )
												{
													cout << "ERROR: Cannot index a non-array type" << endl;
													return 1;
												}
												else if( $<array.level>1 ==  level-1 )
												{
													string temp(getTemp());

													code += temp + " =i " + string($<var.addr>3) + " *i #4\n";
													$<array.index>$ = getTemp();

													code += string($<array.index>$) + " =i " + string($<array.index>1) + " +i " + temp + "\n";

													temp = string($<array.addr>1) + "[" + $<array.index>$ + "]";

													$<array.addr>$ = getTemp();
													code += "la " + string($<array.addr>1) + " " + string($<array.addr>$) + "\n";
													code += string($<array.addr>$) + " =i " + string($<array.addr>$) + " +i " + string($<array.index>$) + "\n";

													temp = "*" + string($<array.addr>$);
													char* s = (char*) calloc(temp.size()+1, sizeof(char));
													strcpy($<array.addr>$, temp.c_str());


													$<array.type>$ = $<array.type>1;
													$<array.completed>$ = 1;
													$<array.level>$ = $<array.level>$ + 1;
												}
												if( parseDebug == 1 )
												{
													cout << "postfix_expression -> postfix_expression [ expression ]" << endl;
												}
											}
			| postfix_expression INC_OP		{
												if( $<array.completed>$ == 1 )
												{
													if( strcmp($<array.type>1,"int") != 0 )
													{
														cout << "ERROR: cannot apply increment operator to non int types" << endl;
														return 1;
													}
													$<array.addr>$ = getTemp();
													code += string($<array.addr>$) + " =i " + string($<array.addr>1) + "\n";
													code += string($<array.addr>1) + " =i " + string($<array.addr>1) + " +i " + "#1\n";
													$<array.type>$ = $<var.type>1;
												}
												else
												{
													cout << "ERROR: cannot apply increment operator to non int types" << endl;
													return 1;
												}

												if( parseDebug == 1 )
												{
													cout << "postfix -> INC_OP" << endl;
												}
											}	
			| postfix_expression DEC_OP		{
												if( $<array.completed>$ == 1 )
												{
													if( strcmp($<array.type>1,"int") != 0 )
													{
														cout << "ERROR: cannot apply decrement operator to non int types" << endl;
														return 1;
													}
													$<array.addr>$ = getTemp();
													code += string($<array.addr>$) + " =i " + string($<array.addr>1) + "\n";
													code += string($<array.addr>1) + " =i " + string($<array.addr>1) + " -i " + "#1\n";
													$<array.type>$ = $<var.type>1;
												}
												else
												{
													cout << "ERROR: cannot apply decrement operator to non int types" << endl;
													return 1;
												}
												if( parseDebug == 1 )
												{
													cout << "postfix -> DEC_OP" << endl;
												}
											}
			;
	
	unary_expression
		:	postfix_expression				{	
												if( $<array.completed>$ == 1 )
												{
													$<var.addr>$ = $<array.addr>1;
													$<var.type>$ = $<array.type>1;
													cout << string($<var.addr>$) << "------------------" << endl;
												}
												else
												{
													cout << "ERROR: referencing an array pointer" << endl;
													return 1;
												}
												if( parseDebug == 1 )
												{
													cout << "unary_expr	-> postfix" << endl;
												}
											}
			| INC_OP unary_expression		{
												if( strcmp($<var.type>2,"int") != 0 )
												{
													cout << "ERROR: cannot apply decrement operator to non int types" << endl;
													return 1;
												}
												$<var.addr>$ = getTemp();
												code += string($<var.addr>2) + " =i " + string($<var.addr>2) + " +i " + "#1\n";
												code += string($<var.addr>$) + " =i " + string($<var.addr>2) + "\n";
												if( parseDebug == 1 )
												{
													cout << "unary_expr	-> INC_OP unary_expr" << endl;
												}
											}
			| DEC_OP unary_expression		{
												if( strcmp($<var.type>2,"int") != 0 )
												{
													cout << "ERROR: cannot apply decrement operator to non int types" << endl;
													return 1;
												}
												$<var.addr>$ = getTemp();
												code += string($<var.addr>2) + " =i " + string($<var.addr>2) + " -i " + "#1\n";
												code += string($<var.addr>$) + " =i " + string($<var.addr>2) + "\n";
												if( parseDebug == 1 )
												{
													cout << "unary_expr	-> DEC_OP unary_expr" << endl;
												}
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
												if( parseDebug == 1 )
												{
													cout << "unary_expr	-> unary_op unary_expr" << endl;
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
								if( parseDebug == 1 )
												{
													cout << "unary_op -> +" << endl;
												}
							}
			| '-'			{	
								$<str>$ = $<str>1;
								if( parseDebug == 1 )
												{
													cout << "unary_op -> -" << endl;
												}
							}
			| '!'			{
								$<str>$ = $<str>1;
								if( parseDebug == 1 )
												{
													cout << "unary_op -> !" << endl;
												}
							}
			;
	
	multiplicative_expression
		:	unary_expression				{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
												if( parseDebug == 1 )
												{
													cout << "multi	-> unary_expr" << endl;
												}
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
														code += string($<var.addr>$) + " =i " + string($<var.addr>1) + " *i " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " =f " + string($<var.addr>1) + " *f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "int" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>3;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>1) + ")\n";
														code += string($<var.addr>$) + " =f " + string(temp) + " *f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "int" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>3) + ")\n";
														code += string($<var.addr>$) + " =f " + string($<var.addr>1) + " *f " +  string(temp) + "\n";
													}
												}
												if( parseDebug == 1 )
												{
													cout << "multi -> multi * unary_expr" << endl;
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
														code += string($<var.addr>$) + " =i " + string($<var.addr>1) + " /i " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " =f " + string($<var.addr>1) + " /f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "int" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>3;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>1) + ")\n";
														code += string($<var.addr>$) + " =f " + string(temp) + " /f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "int" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>3) + ")\n";
														code += string($<var.addr>$) + " =f " + string($<var.addr>1) + " /f " +  string(temp) + "\n";
													}
												}
												if( parseDebug == 1 )
												{
													cout << "multi -> multi / unary_expr" << endl;
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
														code += string($<var.addr>$) + " =i " + string($<var.addr>1) + " %%i " +  string($<var.addr>3) + "\n";
												}
												if( parseDebug == 1 )
												{
													cout << "multi	-> multi %% unary_expr" << endl;
												}
											}
			;
	additive_expression
		:	multiplicative_expression		{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
												if( parseDebug == 1 )
												{
													cout << "additive -> multi" << endl;
												}
											}
			| additive_expression '+' multiplicative_expression
											{
												string type1($<var.type>1);
												string type2($<var.type>3);
													if( type1 == "int" and type2 == "int" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " =i " + string($<var.addr>1) + " +i " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " =f " + string($<var.addr>1) + " +f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "int" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>3;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>1) + ")\n";
														code += string($<var.addr>$) + " =f " + string(temp) + " +f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "int" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>3) + ")\n";
														code += string($<var.addr>$) + " =f " + string($<var.addr>1) + " +f " +  string(temp) + "\n";
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
														code += string($<var.addr>$) + " =i " + string($<var.addr>1) + " +i " +  string($<var.addr>3) + "\n";
													}
													else
													{
														cout << "Invalide operands for +" << endl;
														return 1;
													}
													if( parseDebug == 1 )
												{
													cout << "additive -> additive + multi" << endl;
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
														code += string($<var.addr>$) + " =i " + string($<var.addr>1) + " -i " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " =f " + string($<var.addr>1) + " -f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "int" and type2 == "float" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>3;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>1) + ")\n";
														code += string($<var.addr>$) + " =f " + string(temp) + " -f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "int" )
													{
														$<var.addr>$ = getTemp();
														$<var.type>$ = $<var.type>1;
														char* temp = getTemp();
														code += string(temp) + " = elevateTofloat(" + string($<var.addr>3) + ")\n";
														code += string($<var.addr>$) + " =f " + string($<var.addr>1) + " -f " +  string(temp) + "\n";
													}
													else
													{
														cout << "ERROR: invalid operands for -" << endl;
														return 1;
													}
													if( parseDebug == 1 )
												{
													cout << "additive -> additive - multi" << endl;
												}
											}
			;
	
	relational_expression
		:	additive_expression				{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
												if( parseDebug == 1 )
												{
													cout << "rel_expr	-> additive" << endl;
												}
											}
			| relational_expression '<' additive_expression
											{
												if( string($<var.addr>1) == "bool" or string($<var.addr>1) == "string" or string($<var.addr>3) == "bool" or string($<var.addr>3) == "string")
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
												code += "if ( " + string($<var.addr>1) + " <i " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " =b " + "false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b " + "true\n";
												code += string(label2) + ":\n";	

												if( parseDebug == 1 )
												{
													cout << "rel_expr -> rel_expr < additive" << endl;
												}
											}
			| relational_expression '>' additive_expression
											{
												if( string($<var.addr>1) == "bool" or string($<var.addr>1) == "string" or string($<var.addr>3) == "bool" or string($<var.addr>3) == "string")
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
												code += "if ( " + string($<var.addr>1) + " >i " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " =b " + "false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b " + "true\n";
												code += string(label2) + ":\n";
												if( parseDebug == 1 )
												{
													cout << "rel_expr -> rel_expr > additive" << endl;
												}
											}
			| relational_expression LE_OP additive_expression
											{
												if( string($<var.addr>1) == "bool" or string($<var.addr>1) == "string" or string($<var.addr>3) == "bool" or string($<var.addr>3) == "string")
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
												code += "if ( " + string($<var.addr>1) + " <=i" + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " =b " + "false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b " + "true\n";
												code += string(label2) + ":\n";
												if( parseDebug == 1 )
												{
													cout << "rel_expr -> rel_expr <= additive" << endl;
												}
											}
			| relational_expression GE_OP additive_expression
											{
												if( string($<var.addr>1) == "bool" or string($<var.addr>1) == "string" or string($<var.addr>3) == "bool" or string($<var.addr>3) == "string")
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
												code += "if ( " + string($<var.addr>1) + " >= " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " =b " + "false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b " + "true\n";
												code += string(label2) + ":\n";
												if( parseDebug == 1 )
												{
													cout << "rel_expr -> rel_expr >= additive" << endl;
												}
											}
			;
	
	equality_expression
		:	relational_expression			{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
												if( parseDebug == 1 )
												{
													cout << "eq_expr -> rel_expr" << endl;
												}
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
												code += "if ( " + string($<var.addr>1) + " == " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " =b " + "false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b " + "true\n";
												code += string(label2) + ":\n";
												if( parseDebug == 1 )
												{
													cout << "eq_expr -> eq_expr == rel_expr" << endl;
												}
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
												code += "if ( " + string($<var.addr>1) + " != " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " =b " + "false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b " + "true\n";
												code += string(label2) + ":\n";
												if( parseDebug == 1 )
												{
													cout << "eq_expr -> eq_expr != rel_expr" << endl;
												}
											}	
			;

	logical_and_expression
		:	equality_expression				{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
												if( parseDebug == 1 )
												{
													cout << "logicaland_expr -> eq_expr" << endl;
												}
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
												code += "if ( " + string($<var.addr>1) + " == false ) goto " + string(label1) + "\n";
												code += "if ( " + string($<var.addr>3) + " == false ) goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " =b " + "true\n";
												char* label2 = getLabel();
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b " + "false\n";
												code += string(label2) + ":\n";
												if( parseDebug == 1 )
												{
													cout << "logicaland -> logicaland && eq_expr" << endl;
												}
											}
			;
	
	logical_or_expression
		:	logical_and_expression			{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
												if( parseDebug == 1 )
												{
													cout << "logicalor -> logicaland" << endl;
												}
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
												code += "if ( " + string($<var.addr>1) + " == true ) goto " + string(label1) + "\n";
												code += "if ( " + string($<var.addr>3) + " == true ) goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " =b " + "false\n";
												char* label2 = getLabel();
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b " + "true\n";
												code += string(label2) + ":\n";
												if( parseDebug == 1 )
												{
													cout << "logical_or -> logicalor || logicaland" << endl;
												}
											}
			;

	expression
		: 	logical_or_expression			{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;
												if( parseDebug == 1 )
												{
													cout << "expresson -> logicalor" << endl;
												}
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
												code += var + " =i " + val + "\n";
											}
											else if( ltype == "float" and rtype == "int" )
											{
												char* t = getTemp();
												code += string(t) + " =i " + "elevateToFloat(" + val + ")\n";
												code += var + " =i " + string(t) + "\n";
											}
											else
											{
												cout << "<< --------" << ltype << " ---------" << rtype << endl;
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
												code += var + " =i " + var + " % " + val + "\n";
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
														code += var + " =i " + var + " " + op[0] + "i " +  val + "\n";
													}
													else if( type1 == "float" and type2 == "float" )
													{
														code += var + " =f " + var + " " + op[0] + "f " +  val + "\n";
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
														code += var + " =f " + var + " " + op[0] + "f " +  string(temp) + "\n";
													}
											}
										}
										else if( op[0] == '+' )
										{
													if( type1 == "int" and type2 == "int" )
													{
														code += var + " =i " + var + " " + op[0] + "i " +  val + "\n";
													}
													else if( type1 == "float" and type2 == "float" )
													{
														code += var + " =f " + var + " " + op[0] + "f " +  val + "\n";
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
														code += var + " =f " + var + " " + op[0] + "f " +  string(temp) + "\n";
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
														code += var + " =b " + var + " +b " +  val + "\n";
													}
													else
													{
														cout << "Invalide operands for +" << endl;
														return 1;
													}
										}
										if( parseDebug == 1 )
												{
													cout << "assignment epxression -> unaryExpression assign_op expression" << endl;
												}
									}
			;


	declaration_expression
		:	type_name declarationlist		{
												for(int i = 0 ; i < variables.size() ; i++ )
												{
													if( insertEntry(variables[i], dtype) == -1 )
													{
														cout << "ERROR: variable with given name already exists in this scope" << endl;
														return 1;
													}
													code += dtype + " " + getName(variables[i]) + "\n";
												}
												for( int i = 0 ; i < variableInit.size() ; i++ )
												{
													code += getName(variableInit[i].first) + " =i " + variableInit[i].second + "\n";
												}
												if( parseDebug == 1 )
												{
													cout << "declaration expr -> typename declarationlist" << endl;
												}
											}
			| type_name '[' expression ']'	declarationlist
											{
												string type = dtype + " arr";

												string size = string($<var.addr>3);

												for(int i = 0 ; i < variables.size() ; i++ )
												{
													if( insertEntry(variables[i], type, 1) == -1 )
													{
														cout << "ERROR: variable with given name already exists in this scope" << endl;
														return 1;
													}
													code += type + " " + getName(variables[i]) + " " + size + "\n";
												}
												if( parseDebug == 1 )
												{
													cout << "declaration expr -> typename [ expression ] declarationlist" << endl;
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
												if( parseDebug == 1 )
												{
													cout << "declaration -> identifier" << endl;
												}
											}
			| IDENTIFIER '=' expression		{
												string var($<str>1);
												variables.push_back(var);
												string addr($<var.addr>3);
												variableInit.push_back(make_pair(var, addr));
												if( parseDebug == 1 )
												{
													cout << "declaration -> identifier = expression" << endl;
												}
											}
			;
	

	conditional_expression
		:	IF '(' 						
			expression ')'
											{
												string expr($<var.addr>3);
												string label1 = getLabel();
												
												char* f = new char[label1.length()-1];
												strcpy(f, label1.c_str());
												$<str>1 = f;

												string label2 = getLabel();
												ifgoto.push(label2);

												code += "if ( " + expr + " !=b true ) goto " + label1 + "\n";
											}
			'{' 
											{
												currentScope++;
												$<intval>5 = currentScope;
											}
			statement_list 
											{
												code += "goto " + ifgoto.top() + "\n";
												code += string($<str>1) + ":\n";
											}
			'}'								
											{
												if( symbolDebug == 1 )
												{
													printSymbolTable();
												}
											}

			else_statement					{
												if( parseDebug == 1 )
												{
													cout << "conditional expression -> if(expression) statement_block else_statement" << endl;
												}
											}
			;
	
	else_statement
		:	ELIF '(' expression ')' 
											{
												string expr($<var.addr>3);
												string label1 = getLabel();
												
												char* f = new char[label1.length()-1];
												strcpy(f, label1.c_str());
												$<str>1 = f;

												code += "if ( " + expr + " !=b true ) goto " + label1 + "\n";
											}
			'{' 
											{
												currentScope++;
												$<intval>5 = currentScope;
											}
								
			statement_list					{
												code += "goto " + ifgoto.top() + "\n";
												code += string($<str>1) + ":\n";
											}
			'}'
											{
												if( symbolDebug == 1 )
												{
													printSymbolTable();
												}
												deleteEntries($<intval>5);
											}
			else_statement					{
												if( parseDebug == 1 )
												{
													cout << "else_statement -> elif(expression) statment_block else_statement" << endl;
												}
											}
				
			| ELSE '{' 
											{
												currentScope++;
												$<intval>2 = currentScope;
											}
			statement_list					{
												code += ifgoto.top() + ":\n";
												ifgoto.pop();
												if( parseDebug == 1 )
												{
													cout << "else_statement -> else statem_block" << endl;
												}
											}
			'}'
											{
												if( symbolDebug == 1 )
												{
													printSymbolTable();
												}
												deleteEntries($<intval>2);
											}

			|								{
												code += ifgoto.top() + ":\n";
												ifgoto.pop();
												if( parseDebug == 1 )
												{
													cout << "else_statement -> null" << endl;
												}
											}
	
	statement
		: 	assignment_expression ';'
			| declaration_expression ';'
			| conditional_expression
			| for_expression
			| expression ';'
			| IO_statement ';'
			;
	

	IO_statement
		:	print_statement
			| scan_statement
			;

	scan_statement
		:	unary_expression '=' SCAN '('')'
									{
										string name = string($<var.addr>1);
										cout << "----------------name << " << name << endl;
										cout << "----------------type << " << string($<var.type>1) << endl;
										if( string($<var.type>1) == "int" )
										{
											code += "scan int " + name + "\n";
										}
										else if( string($<var.type>1) == "char" )
										{
											code += "scan char " + name + "\n";
										}
										else if( string($<var.type>1) == "float" )
										{
											code += "scan float " + name + "\n";
										}
									}	
			;

	print_statement
		:	PRINT '(' print_args ')'	
									{
									}
			| PRINT '(' ')'
			;
	
	print_args
		:	expression ',' print_args		
										{
											if( string($<var.type>1) == "int" )
											{
												code += "print int " + string($<var.addr>1) + "\n";
											}
											else if( string($<var.type>1) == "char" )
											{
												code += "print char " + string($<var.addr>1) + "\n";
											}
											else if( string($<var.type>1) == "float" )
											{
												code += "print float " + string($<var.addr>1) + "\n";
											}
										}
			| expression
										{
											if( string($<var.type>1) == "int" )
											{
												code += "print int " + string($<var.addr>1) + "\n";
											}
											else if( string($<var.type>1) == "char" )
											{
												code += "print char " + string($<var.addr>1) + "\n";
											}
											else if( string($<var.type>1) == "float" )
											{
												code += "print float " + string($<var.addr>1) + "\n";
											}
										}
			;

	for_expression
		:	FOR '(' 
											{
												currentScope++;
												$<intval>2 = currentScope;
											}
			loop_initialization_list  ';' 
											{
												string start = getLabel();
												code += start + ":\n";

												char* g = new char[start.length()-1];
												strcpy(g, start.c_str());
												$<str>1 = g;
											}
			loop_condition ';'				{
												string expr = forExprVal;

												string statementstart = getLabel();
												string incrementstart = getLabel();
												string endfor = getLabel();

												char* f = new char[statementstart.length()-1];
												strcpy(f, statementstart.c_str());
												$<str>4 = f;

												char* g = new char[incrementstart.length()-1];
												strcpy(g, incrementstart.c_str());
												$<var.addr>6 = g;

												char* h = new char[endfor.length()-1];
												strcpy(h, endfor.c_str());
												$<var.type>6 = h;
												
												code += "if ( " + expr + " !=b true ) goto " + endfor + "\n";
												code += "goto " + statementstart + "\n";
												code += incrementstart + ":\n";
											}
			loop_increment_list 			{
												code += "goto " + string($<str>1) + "\n";
												code += string($<str>4) + ":\n";
											}
			')' '{' statement_list 			{
												code += "goto " + string($<var.addr>6) + "\n";
												code += string($<var.type>6) + ":\n";
												if( parseDebug == 1 )
												{
													cout << "forstatemet -> completed" << endl;
												}
											}
			'}'								{
												if( symbolDebug == 1 )
												{
													printSymbolTable();
												}
												deleteEntries($<intval>2);
											}
			;

	loop_initialization_list										
		:	assignment_expression ',' loop_initialization_list			
											{
												if( parseDebug == 1 )
												{
													cout << "loop_init -> assignmentexpression , loop_init" << endl;
												}
											}
			| assignment_expression
											{
												if( parseDebug == 1 )
												{
													cout << "loop_init -> assignmentexpression" << endl;
												}
											}
			| declaration_expression		{
												if( parseDebug == 1 )
												{
													cout << "loop_init -> declaration" << endl;
												}
											}
			;
	
	loop_condition
		: 	expression						{
												if( strcmp($<var.type>1, "bool") != 0 )
												{
													cout << "ERROR: non-boolean expression is being used as loop condition" << endl;
													return 1;
												}
												forExprVal = string($<var.addr>1);
												if( parseDebug == 1 )
												{
													cout << "loop_condition -> expression" << endl;
												}
											}
			;
	
	loop_increment_list
		:	expression ',' loop_increment_list	{
													if( parseDebug == 1 )
													{
														cout << "loop_incr -> expression , loop_incr" << endl;
													}
												}
			| expression					
													{
														if( parseDebug == 1 )
												{
													cout << "loop_incr -> expression" << endl;
												}
													}
			;

	statement_list
		: 	statement statement_list
			| statement
			;

	begin:
		VOID MAIN '(' ')' statement_block
		;

	statement_block
		:	'{' 						{
											currentScope++;
											$<intval>1 = currentScope;
										}
			statement_list
										{
											if( parseDebug == 1 )
												{
													cout << "statement_block -> { statementlist }" << endl;
												}
										}
			'}'							{
											if( symbolDebug == 1 )
											{
													printSymbolTable();
											}
											deleteEntries($<intval>1);
										}
											
			| '{' '}'					{
												if( parseDebug == 1 )
												{
													cout << "statementblock -> {}" << endl;
												}
										}
			;
%%


int main( int argcount, char* arguements[] )
{
	yyin = fopen(arguements[1], "r");
	yyparse();
	
	cout << "Code: " << endl;
	cout << code << endl;

	printSymbolTable();

	ofstream Myfile("output.txt");

	Myfile << code;
	Myfile.close();
	return 0;
}
