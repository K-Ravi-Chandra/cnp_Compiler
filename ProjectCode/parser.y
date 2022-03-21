%{
#include<fstream>
#include<stdio.h>
#include<string.h>
#include<iostream>
#include<unordered_map>
#include<vector>
#include<stack>

using namespace std; 
extern FILE* yyin;

// these following three variables are used to enable debugging of the parsing, if they are set to one
// then they print useful information.( this information is for developing purpose not for end users ).
extern int DEBUG;		//to print information about tokeninzing
int parseDebug = 0;		//to print information about parsing
int symbolDebug = 0;	//print the symbol table.

//this contains the current lineno being parsed.
extern int yylineno;

extern "C"
{
	int yyparse(void);
	int yylex(void);
	void yyerror(const char* s)
	{
		printf("%s at line: %d\n", s, yylineno);
		return;
	}
	int yywrap()
	{
		return 1; 
	} 
}

//this string contains the entire temporary code, we generate the temporary code in incremental fashion.
string code = "";

//All these below variables are global variables required because of the bottom-up parsing nature of yacc 
//parser.( we require at some places for the information to pass from top to bottom ).

//this variable is used to keep count the number of dimensions of the declared array while declaring.
vector<string> declevels;

//this variable stores the type of variable declared.
string dtype;

//this stack contains the goto address after executing one of the if blocks.
stack<string> ifgoto;

//this is used to store the variable that contains the address for loop expression 
string forExprVal;

//temporary variables are of the form "t_{tempint}". for example: t_1, t_22, tempint stores the numeber.
int tempint = 1;

//this stack contains the list of addresses of start of the increment part of the for expression.
//this is used when we encounter a continue statement.( we goto the address of the top of the stack).
stack<string> forIncrement;

//this stack contains the list of addresses of start of the code following the for expression.
//this is used when we encounter a break statement.( we goto the address of the top of the stack). 
stack<string> forNext;

//labels are of the form "label{labelint}". for example: label1, lable30, labelint stores the number.
int labelint = 1;

//returns the name of a new temp variable, and also declares it as a variable in the temp code.
char* getTemp( string type )
{
	string temp = "t_" + to_string(tempint);
	char* t = (char*) malloc((temp.length()-1)*sizeof(char));
	strcpy(t, temp.c_str());
	tempint++;		//increment tempint so that next time new temp variable is created.
	code += type + " " + temp + "\n";		//add the declaration
	return t;
}

//this one does the same thing except that it does not declare the variable.
char* getTemp()
{
	string temp = "t_" + to_string(tempint);
	char* t = (char*) malloc((temp.length()-1)*sizeof(char));
	strcpy(t, temp.c_str());
	tempint++;
	return t;
}

//returns a new label address, similar to the generating temp variables.
char* getLabel()
{
	string temp = "label" + to_string(labelint);
	char* t = (char*) malloc((temp.length()-1)*sizeof(char));
	strcpy(t, temp.c_str());
	labelint++;
	return t;
}

//contains the current scope.
int currentScope = 0;

//contains the heirarchy of scopes the current variable is in.( More detailed explanation about the scopes
//is presented in the documentation.
stack<int> scopeStack;

//this is the definition of a single symbol table entry.
class symbolTableEntry
{
	public:
		string name;		//name of the variable.
		string dataType;	//dataType of the variable.
		vector<string> levels;		//if it is an array, then this contains the array of variables
									//in which the sizes of those dimensions reside.
		int size;			//size of the variable in bytes	
		bool array;			//bool variable specifying if it is an array or not.
		int scope;			//scope in which it is defined and to which it belongs to.
	
	symbolTableEntry()		//constructor for new symbol table entry.
	{
		name = "";
		dataType = "";
		size = 0;
		array = false;
		scope = 0;
	}
};

//Symbol table( list of symboltable entries.)
vector<symbolTableEntry> symbolTable;		

//insert a new entry.
int insertEntry( string name, string dataType , vector<string> levels, bool array)
{
	for( int i = 0 ; i < symbolTable.size() ; i++ )
	{
		if( symbolTable[i].name == name and symbolTable[i].scope == currentScope )
		{
			return -1;		//if a variable with the same name and scope already exists, then return -1.
		}
	}
	symbolTableEntry ste;

	ste.name = name;
	ste.dataType = dataType;
	ste.size = 4;						//currently all variables are of same size.
	ste.scope = scopeStack.top();		//the top of the stack contains the current scope
	ste.levels = levels;
	ste.array = array;
	symbolTable.push_back(ste);

	return 0;					//on success return 0.
}

//a debugging tool to print the symbol table.
void printSymbolTable()
{
	cout << "Symbol Table:" << endl;
	cout << "name\tdatatype\tscope\tsize\tarray\tlevels" << endl;
	for( int i = 0 ; i < symbolTable.size() ; i++ )
	{
		cout << symbolTable[i].name << "\t" << symbolTable[i].dataType << "\t" << symbolTable[i].scope << "\t" << symbolTable[i].size << "\t" << symbolTable[i].array << "\t";
		for( int j = 0 ; j < symbolTable[i].levels.size() ; j++ )
		{
			cout << symbolTable[i].levels[j] << " ";
		}
		cout << endl;
	}
	cout << endl;
}


//remove an entry from the table.
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
	return -1;		//if an entry doesn't exist then return -1.
}

//delete all entries in the given scope
int deleteEntries( int scope )
{
	while( true )
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
		if( c )		//if completed removing, then break.
		{
			break;
		}
	}
	return 1;
}

//returns the symbol table entry with the given name, if there are multiple entries then return the entry
//that has the highest scope.
symbolTableEntry getEntry( string name )
{
	symbolTableEntry res;
	bool b = true;
	int scope = 0;
	for( int i = 0 ; i < symbolTable.size() ; i++ )
	{
		if( symbolTable[i].name == name  )
		{
			if( b )
			{
				res = symbolTable[i];
				b = false;
			}
			else
			{
				//if an entry with higher scope exists then return it, when referring we always return the most local one.
				if( symbolTable[i].scope > res.scope )
				{
					res = symbolTable[i];
				}
			}
		}
	}
	return res;
}
%}

//this is the union that contains the attributes of different grammar symbols.
//basing on the grammar symbol, one of them will be used.
%union
{
	char* str;		//used for returning the identifiers from the lexer.
	int intval;

	struct			//used by grammar symbols that evaluate to expressions.
	{
		char* type;
		char* addr;
	} var;

	struct			//used by grammar symbols that deal with array references.
	{
		char* type;
		char* addr;
		int arr;
		int level;
		char* index;
		int completed;
	} array;
};

%token BREAK CHAR CONST CONTINUE ELSE ELIF FLOAT FOR IN IF INT RETURN SIZEOF VOID BOOL STRING ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN POW_ASSIGN INC_OP DEC_OP OR_OP AND_OP LE_OP GE_OP EQ_OP NE_OP C_CONST S_CONST B_CONST I_CONST F_CONST IDENTIFIER LET PRINT PRINTS SCAN MAIN

%start begin

%%
	primary_expression								
		:	IDENTIFIER						{	
												//get the symbol table entry.
												symbolTableEntry ste = getEntry( string($<str>1) );
												if( ste.name == "" )
												{
													cout << "COMPILETIME ERROR: " << string($<str>1) << " not declared" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}

												//get the datatype from ste, and initialize the type attribute.
												char* t = (char*) calloc(ste.dataType.length()-1, sizeof(char));
												strcpy(t, ste.dataType.c_str());
												$<var.type>$ = t;

												//since there can be many variables with same name, we differentiate them by their
												//scope to which they belong to, by appending the scope to their name.
												string temp = ste.name + "_" + to_string(ste.scope);
												t = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(t, temp.c_str());
												$<var.addr>$ = t;

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
												//set the type
												string temp = "int";
												char* t = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(t, temp.c_str());
												$<var.type>$ = t;
									
												//get a new variable and as well as declare it.
												$<var.addr>$ = getTemp("int");

												//add code to set the new temp variables value with I_CONST
												code += string($<var.addr>$) + " =i #" + string($<str>1) + "\n";

												if( parseDebug == 1 )
												{
													cout << "constant -> I_const" << endl;
												}
											}
			| F_CONST						{
												//similar as above
												string temp = "float";
												char* t = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(t, temp.c_str());
												$<var.type>$ = t;
									
												$<var.addr>$ = getTemp("float");

												code += string($<var.addr>$) + " =f #" + string($<str>1) + "\n";

												if( parseDebug == 1 )
												{
													cout << "constant -> F_const" << endl;
												}
											}
			| C_CONST						{
												//similar as above
												string temp = "char";
												char* t = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(t, temp.c_str());
												$<var.type>$ = t;
									
												$<var.addr>$ = getTemp("char");

												code += string($<var.addr>$) + " =c #" + string($<str>1) + "\n";

												if( parseDebug == 1 )
												{
													cout << "constant -> C_const" << endl;
												}
											}
			| S_CONST						{
												//similar as above
												string temp = "string";
												char* t = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(t, temp.c_str());
												$<var.type>$ = t;
									
												$<var.addr>$ = getTemp();

												code += string($<var.addr>$) + " =s #" + string($<str>1) + "\n";

												if( parseDebug == 1 )
												{
													cout << "constant -> S_const" << endl;
												}
											}
			| B_CONST						{
												//similar as above
												string temp = "bool";
												char* t = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(t, temp.c_str());
												$<var.type>$ = t;
									
												$<var.addr>$ = getTemp("bool");

												code += string($<var.addr>$) + " =b #" + string($<str>1) + "\n";

												if( parseDebug == 1 )
												{
													cout << "constant -> B_const" << endl;
												}
											}
			;

	postfix_expression
		:	primary_expression				{
												string addr($<var.addr>1);
												if( addr[1] == '_' and addr[0] == 't' )
												{
													$<array.addr>$ = $<var.addr>1;
													$<array.type>$ = $<var.type>1;
													$<array.index>$ = NULL;
													$<array.completed>$ = 1;
												}
												else
												{
													string origname = "";
													for( int i = 0 ; i < addr.size() ; i++ )
													{
														if( addr[i] != '_' )
														{
															origname += addr[i];
														}
														else
														{
															break;
														}
													}
													symbolTableEntry ste = getEntry(origname);
													if( ste.array == false )
													{
														$<array.addr>$ = $<var.addr>1;
														$<array.type>$ = $<var.type>1;
														$<array.index>$ = NULL;
														$<array.completed>$ = 1;
													}
													else
													{
														$<array.addr>$ = $<var.addr>1;
														$<array.type>$ = $<var.type>1;
														$<array.completed>$ = 0;
														$<array.level>$ = 0;
														$<array.index>$ = getTemp(string($<var.type>1));

														code += string($<array.index>$) + " =i #0\n";
													}
												}
												
												if( parseDebug == 1 )
												{
													cout << "postfix_expression -> primary_expression" << endl;
												}
											}
			| postfix_expression '[' expression ']'
											{
												if( $<array.completed>1 == 1 )
												{
													cout << "COMPILETIME ERROR: Cannot index a non-array type" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												if( string($<var.type>3) != "int" )
												{
													cout << "COMPILETIME ERROR: Cannot use a non integer as index" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												
												string addr($<array.addr>1);
												string origname = "";
												for( int i = 0 ; i < addr.size() ; i++ )
												{
													if( addr[i] != '_' )
													{
														origname += addr[i];
													}
													else
													{
														break;
													}
												}

												symbolTableEntry ste = getEntry(origname);

												if( $<array.level>1 ==  ste.levels.size()-1 )
												{
													string label1 = getLabel();
													string label2 = getLabel();

													code += "if ( " + string($<var.addr>3) + " <i " + ste.levels[$<array.level>1] + " ) goto " +  label1 + "\n";
													string var(getTemp());
													code += var + " =s #" + "\"RUNTIME ERROR: Index out of Bounds\"\n";
													code += "print string " + var + "\n";
													code += "exit\n";
													code += label1 + ":\n";
													code += "if ( " + string($<var.addr>3) + " >=i #0 ) goto " + label2 + "\n";
													var = string(getTemp());
													code += var + " =s #" + "\"RUNTIME ERROR: Index is negative\"\n";
													code += "print string " + var + "\n";
													code += "exit\n";
													code += label2 + ":\n";

													string temp(getTemp("int"));

													code += temp + " =i " + string($<var.addr>3) + " *i #" + to_string(ste.size) + "\n";
													$<array.index>$ = getTemp("int");

													code += string($<array.index>$) + " =i " + string($<array.index>1) + " +i " + temp + "\n";

													temp = string(getTemp("int"));

													code += temp + " =i " + string($<array.addr>1) + "\n";
													code += temp + " =i " + temp + " +i " + string($<array.index>$) + "\n";

													temp = "*" + temp;
													char* s = (char*) calloc(temp.size()+1, sizeof(char));
													strcpy($<array.addr>$, temp.c_str());
													
													$<array.type>$ = $<array.type>1;
													$<array.completed>$ = 1;
													$<array.level>$ = $<array.level>$ + 1;
												}
												else
												{
													string label1 = getLabel();
													string label2 = getLabel();

													code += "if ( " + string($<var.addr>3) + " <i " + ste.levels[$<array.level>1] + " ) goto " +  label1 + "\n";
													string var(getTemp());
													code += var + " =s #" + "\"RUNTIME ERROR: Index out of Bounds\"\n";
													code += "print string " + var + "\n";
													code += "exit\n";
													code += label1 + ":\n";
													code += "if ( " + string($<var.addr>3) + " >=i #0 ) goto " + label2 + "\n";
													var = string(getTemp());
													code += var + " =s #" + "\"RUNTIME ERROR: Index is negative\"\n";
													code += "print string " + var + "\n";
													code += "exit\n";
													code += label2 + ":\n";

													string temp(getTemp("int"));

													code += temp + " =i #1\n";

													for( int i = $<array.level>1 + 1; i < ste.levels.size() ; i++ )
													{
														code += temp + " =i " + temp + " *i " + ste.levels[i] + "\n";
													}

													code += temp + " =i " + temp + " *i #" + to_string(ste.size) + "\n";

													code += temp + " =i " + string($<var.addr>3) + " *i " + temp  + "\n";

													$<array.index>$ = getTemp("int");

													code += string($<array.index>$) + " =i " + string($<array.index>1) + " +i " + temp + "\n";
													$<array.type>$ = $<array.type>1;
													$<array.addr>$ = $<array.addr>1;
													$<array.completed>$ = 0;
													$<array.level>$ = $<array.level>1 + 1;
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
														cout << "COMPILETIME ERROR: cannot apply increment operator to non int types" << endl;
														cout << "At line : " << yylineno << endl;
														return -1;
													}
													$<array.addr>$ = getTemp("int");
													code += string($<array.addr>$) + " =i " + string($<array.addr>1) + "\n";
													code += string($<array.addr>1) + " =i " + string($<array.addr>1) + " +i " + "#1\n";
													$<array.type>$ = $<var.type>1;
													$<array.completed>$ = $<array.completed>1;
												}
												else
												{
													cout << "COMPILETIME ERROR: cannot apply increment operator to non int types" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
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
														cout << "COMPILETIME ERROR: cannot apply decrement operator to non int types" << endl;
														cout << "At line : " << yylineno << endl;
														return -1;
													}
													$<array.addr>$ = getTemp("int");
													code += string($<array.addr>$) + " =i " + string($<array.addr>1) + "\n";
													code += string($<array.addr>1) + " =i " + string($<array.addr>1) + " -i " + "#1\n";
													$<array.type>$ = $<var.type>1;
													$<array.completed>$ = $<array.completed>1;
												}
												else
												{
													cout << "COMPILETIME ERROR: cannot apply decrement operator to non int types" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												if( parseDebug == 1 )
												{
													cout << "postfix -> DEC_OP" << endl;
												}
											}
			;
	
	unary_expression
		:	postfix_expression				{	
												//if the expression is complete then do the usual
												if( $<array.completed>$ == 1 )
												{
													$<var.addr>$ = $<array.addr>1;
													$<var.type>$ = $<array.type>1;
												}
												//else the array is not referenced properly
												else
												{
													cout << "COMPILETIME ERROR: referencing an array pointer" << endl;
													cout << "At line : " << yylineno << endl;
													return 1;
												}
												if( parseDebug == 1 )
												{
													cout << "unary_expr	-> postfix" << endl;
												}
											}
			| INC_OP unary_expression		{
												//check if the variable is an int
												if( strcmp($<var.type>2,"int") != 0 )
												{
													cout << "COMPILETIME ERROR: cannot apply decrement operator to non int types" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}

												//first increment the value and then assign the value
												$<var.addr>$ = getTemp("int");
												code += string($<var.addr>2) + " =i " + string($<var.addr>2) + " +i " + "#1\n";
												code += string($<var.addr>$) + " =i " + string($<var.addr>2) + "\n";

												if( parseDebug == 1 )
												{
													cout << "unary_expr	-> INC_OP unary_expr" << endl;
												}
											}
			| DEC_OP unary_expression		{
												//same as above
												if( strcmp($<var.type>2,"int") != 0 )
												{
													cout << "COMPILETIME ERROR: cannot apply decrement operator to non int types" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												$<var.addr>$ = getTemp("int");
												code += string($<var.addr>2) + " =i " + string($<var.addr>2) + " -i " + "#1\n";
												code += string($<var.addr>$) + " =i " + string($<var.addr>2) + "\n";
												if( parseDebug == 1 )
												{
													cout << "unary_expr	-> DEC_OP unary_expr" << endl;
												}
											}
			| unary_operator unary_expression
											{
												$<var.type>$ = $<var.type>2;
												string op($<str>1);
												string type($<var.type>2); 

												if( op == "+" or op == "-" )
												{
													// + and - are only applicable to int and float variables.
													if( type != "int" and type != "float" )
													{
														cout << "COMPILETIME ERROR: cannot apply + to non number types" << endl;
														cout << "At line : " << yylineno << endl;
														return -1;
													}
													else
													{
														if( op == "-" )
														{
															$<var.addr>$ = getTemp();
															code += string($<var.addr>$) + " = " + "minus " + string($<var.addr>2) + "\n";
														}
													}
												}
												//! is only applicable to bool variables.
												if( op == "!" )
												{
													if( type != "bool" )
													{
														cout << "COMPILETIME ERROR: cannot apply ! to non bool types" << endl;
														cout << "At line : " << yylineno << endl;
														return -1;
													}
													else
													{
														$<var.addr>$ = getTemp();
														code += string($<var.addr>$) + " = " + "not " + string($<var.addr>2) + "\n";
													}
												}	
												if( parseDebug == 1 )
												{
													cout << "unary_expr	-> unary_op unary_expr" << endl;
												}
											}
			;
	
	type_name		
		:	INT				{	dtype = "int"; 	}			//set the dtypes for declaration purposes.	
			| FLOAT			{	dtype = "float";}
			| CHAR			{   dtype = "char"; }
			| STRING		{ 	dtype = "string"; }
			| BOOL			{ 	dtype = "bool"; }
			| LET			{	dtype = "let";  }
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
												
												//multiplication is only applicable between int and float variables.
												if( type1 != "int" and type1 != "float" or type2 != "int" and type2 != "float" )
												{
													cout << "COMPILETIME ERROR: cannot multiply non-number types" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												else
												{
													//if both the operands are int's then the result is also an int.
													if( type1 == "int" and type2 == "int" )
													{
														$<var.addr>$ = getTemp("int");
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " =i " + string($<var.addr>1) + " *i " +  string($<var.addr>3) + "\n";
													}
													//if both are float's then the result is also an float.
													else if( type1 == "float" and type2 == "float" )
													{
														$<var.addr>$ = getTemp("float");
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " =f " + string($<var.addr>1) + " *f " +  string($<var.addr>3) + "\n";
													}
													//if one is int and the other is float, then promote the int to float and 
													//store the result in a float variable.
													else if( type1 == "int" and type2 == "float" )
													{
														$<var.addr>$ = getTemp("float");
														$<var.type>$ = $<var.type>3;
														char* temp = getTemp("float");
														code += string(temp) + " =f elevateToFloat ( " + string($<var.addr>1) + " )\n";
														code += string($<var.addr>$) + " =f " + string(temp) + " *f " +  string($<var.addr>3) + "\n";
													}
													//same as above
													else if( type1 == "float" and type2 == "int" )
													{
														$<var.addr>$ = getTemp("float");
														$<var.type>$ = $<var.type>1;
														char* temp = getTemp("float");
														code += string(temp) + " =f elevateToFloat ( " + string($<var.addr>3) + " )\n";
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
												//everything same as for multiplication.
												string type1($<var.type>1);
												string type2($<var.type>3);
												if( type1 != "int" and type1 != "float" or type2 != "int" and type2 != "float" )
												{
													cout << "COMPILETIME ERROR: cannot divide non-number types" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												else
												{
													if( type1 == "int" and type2 == "int" )
													{
														$<var.addr>$ = getTemp("int");
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " =i " + string($<var.addr>1) + " /i " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "float" )
													{
														$<var.addr>$ = getTemp("float");
														$<var.type>$ = $<var.type>1;
														code += string($<var.addr>$) + " =f " + string($<var.addr>1) + " /f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "int" and type2 == "float" )
													{
														$<var.addr>$ = getTemp("float");
														$<var.type>$ = $<var.type>3;
														char* temp = getTemp("float");
														code += string(temp) + " = elevateToFloat ( " + string($<var.addr>1) + " )\n";
														code += string($<var.addr>$) + " =f " + string(temp) + " /f " +  string($<var.addr>3) + "\n";
													}
													else if( type1 == "float" and type2 == "int" )
													{
														$<var.addr>$ = getTemp("float");
														$<var.type>$ = $<var.type>1;
														char* temp = getTemp("float");
														code += string(temp) + " = elevateToFloat ( " + string($<var.addr>3) + " )\n";
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

												//modulus operator is only applicable for int's
												if( type1 != "int" or type2 != "int" )
												{
													cout << "COMPILETIME ERROR: cannot apply modulus to  non-integer types" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												else
												{
														$<var.addr>$ = getTemp("int");
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

												//if both are int's then result is int.
												if( type1 == "int" and type2 == "int" )
												{
													$<var.addr>$ = getTemp("int");
													$<var.type>$ = $<var.type>1;
													code += string($<var.addr>$) + " =i " + string($<var.addr>1) + " +i " +  string($<var.addr>3) + "\n";
												}
												//if both are float's then the result is float.
												else if( type1 == "float" and type2 == "float" )
												{
													$<var.addr>$ = getTemp("float");
													$<var.type>$ = $<var.type>1;
													code += string($<var.addr>$) + " =f " + string($<var.addr>1) + " +f " +  string($<var.addr>3) + "\n";
												}
												//if one is int and other is float then promote int to float.
												else if( type1 == "int" and type2 == "float" )
												{
													$<var.addr>$ = getTemp("float");
													$<var.type>$ = $<var.type>3;
													char* temp = getTemp("float");
													code += string(temp) + " = elevateToFloat ( " + string($<var.addr>1) + " )\n";
													code += string($<var.addr>$) + " =f " + string(temp) + " +f " +  string($<var.addr>3) + "\n";
												}
												//if one is int and other is float then promote int to float.
												else if( type1 == "float" and type2 == "int" )
												{
													$<var.addr>$ = getTemp("float");
													$<var.type>$ = $<var.type>1;
													char* temp = getTemp("float");
													code += string(temp) + " = elevateToFloat ( " + string($<var.addr>3) + " )\n";
													code += string($<var.addr>$) + " =f " + string($<var.addr>1) + " +f " +  string(temp) + "\n";
												}
												//if both are strings then concatenate the two strings.
												else if( type1 == "string" and type2 == "string" )
												{
													$<var.type>$ = $<var.type>1;
													$<var.addr>$ = getTemp("string");
													code += string($<var.addr>$) + " =s strcat ( " + string($<var.addr>1) + " ," +  string($<var.addr>3) + " )\n";
												}
												//if second operand is char then concatenate the char to the string.
												else if( type1 == "string" and type2 == "char" )
												{
													$<var.type>$ = $<var.type>1;
													$<var.addr>$ = getTemp("string");
													code += string($<var.addr>$) + " =s strcatc ( " + string($<var.addr>1) + " ," +  string($<var.addr>3) + " )\n";
												}
												//if second operand is int, then add add the int, to char ( ascii addition ).
												else if( type1 == "char" and type2 == "int" )
												{
													$<var.addr>$ = getTemp("char");
													$<var.type>$ = $<var.type>1;
													code += string($<var.addr>$) + " =c " + string($<var.addr>1) + " +c " +  string($<var.addr>3) + "\n";
												}
												//anyother combination of operands is invalid.
												else
												{
													cout << "COMPILETIME ERROR: Invalid Operands for +" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												if( parseDebug == 1 )
												{
													cout << "additive -> additive + multi" << endl;
												}
											}
			| additive_expression '-' multiplicative_expression
											{
												//same as for addition
												string type1($<var.type>1);
												string type2($<var.type>3);

												if( type1 == "int" and type2 == "int" )
												{
													$<var.addr>$ = getTemp("int");
													$<var.type>$ = $<var.type>1;
													code += string($<var.addr>$) + " =i " + string($<var.addr>1) + " -i " +  string($<var.addr>3) + "\n";
												}
													else if( type1 == "float" and type2 == "float" )
												{
													$<var.addr>$ = getTemp("float");
													$<var.type>$ = $<var.type>1;
													code += string($<var.addr>$) + " =f " + string($<var.addr>1) + " -f " +  string($<var.addr>3) + "\n";
												}
												else if( type1 == "int" and type2 == "float" )
												{
													$<var.addr>$ = getTemp("float");
													$<var.type>$ = $<var.type>3;
													char* temp = getTemp("float");
													code += string(temp) + " = elevateToFloat ( " + string($<var.addr>1) + " )\n";
													code += string($<var.addr>$) + " =f " + string(temp) + " -f " +  string($<var.addr>3) + "\n";
												}
												else if( type1 == "float" and type2 == "int" )
												{
													$<var.addr>$ = getTemp("float");
													$<var.type>$ = $<var.type>1;
													char* temp = getTemp("float");
													code += string(temp) + " = elevateToFloat ( " + string($<var.addr>3) + " )\n";
													code += string($<var.addr>$) + " =f " + string($<var.addr>1) + " -f " +  string(temp) + "\n";
												}
												else
												{
													cout << "COMPILETIME ERROR: invalid operands for -" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
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
												string type1($<var.type>1);
												string type2($<var.type>3);
												
												// < is applicable only for int, floats.
												if( type1 == "bool" or type1 == "string" or type2 == "bool" or type2 == "string" or type1 == "char" or type2 == "char" )
												{
													cout << "COMPILETIME ERROR: Invalid Operands for '<'" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}

												//the result is a bool variable.
												string temp = "bool";
												char* i = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(i, temp.c_str());
												$<var.type>$ = i;

												$<var.addr>$ = getTemp("bool");
												string label1 = getLabel();
												string label2 = getLabel();

												if( type1 == "int" and type2 == "int" )
												{
													code += "if ( " + string($<var.addr>1) + " <i " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}
												else
												{
													code += "if ( " + string($<var.addr>1) + " <f " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}

												//set the result to true if the expression is true.
												code += string($<var.addr>$) + " =b #false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b #true\n";
												code += string(label2) + ":\n";	

												if( parseDebug == 1 )
												{
													cout << "rel_expr -> rel_expr < additive" << endl;
												}
											}
			| relational_expression '>' additive_expression
											{
												//same as for >
												string type1($<var.type>1);
												string type2($<var.type>3);

												if( type1 == "bool" or type1 == "string" or type2 == "bool" or type2 == "string" or type1 == "char" or type2 == "char" )
												{
													cout << "COMPILETIME ERROR: Invalid Operands for '>'" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												string temp = "bool";
												char* i = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(i, temp.c_str());
												$<var.type>$ = i;

												$<var.addr>$ = getTemp("bool");
												string label1 = getLabel();
												string label2 = getLabel();
												if( type1 == "int" and type2 == "int" )
												{
													code += "if ( " + string($<var.addr>1) + " >i " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}
												else
												{
													code += "if ( " + string($<var.addr>1) + " >f " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}

												code += string($<var.addr>$) + " =b #false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b #true\n";
												code += string(label2) + ":\n";	

												if( parseDebug == 1 )
												{
													cout << "rel_expr -> rel_expr > additive" << endl;
												}
											}
			| relational_expression LE_OP additive_expression
											{
												//same as for < and > 
												string type1($<var.type>1);
												string type2($<var.type>3);

												if( type1 == "bool" or type1 == "string" or type2 == "bool" or type2 == "string" or type1 == "char" or type2 == "char" )
												{
													cout << "COMPILETIME ERROR: Invalid Operands for '<='" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												string temp = "bool";
												char* i = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(i, temp.c_str());
												$<var.type>$ = i;

												$<var.addr>$ = getTemp("bool");
												string label1 = getLabel();
												string label2 = getLabel();
												if( type1 == "int" and type2 == "int" )
												{
													code += "if ( " + string($<var.addr>1) + " <=i " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}
												else
												{
													code += "if ( " + string($<var.addr>1) + " <=f " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}

												code += string($<var.addr>$) + " =b #false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b #true\n";
												code += string(label2) + ":\n";	

												if( parseDebug == 1 )
												{
													cout << "rel_expr -> rel_expr <= additive" << endl;
												}
											}
			| relational_expression GE_OP additive_expression
											{
												//same as above
												string type1($<var.type>1);
												string type2($<var.type>3);

												if( type1 == "bool" or type1 == "string" or type2 == "bool" or type2 == "string" or type1 == "char" or type2 == "char" )
												{
													cout << "COMPILETIME ERROR: Invalid Operands for '>='" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												string temp = "bool";
												char* i = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(i, temp.c_str());
												$<var.type>$ = i;

												$<var.addr>$ = getTemp("bool");
												string label1 = getLabel();
												string label2 = getLabel();
												if( type1 == "int" and type2 == "int" )
												{
													code += "if ( " + string($<var.addr>1) + " >=i " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}
												else
												{
													code += "if ( " + string($<var.addr>1) + " >=f " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}

												code += string($<var.addr>$) + " =b #false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b #true\n";
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
												string type1($<var.type>1);
												string type2($<var.type>3);
												
												//can compare only equal types.
												if( type1 != type2 )
												{
													cout << "COMPILETIME ERROR: cannot compare two different type of operands" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}

												string temp = "bool";
												char* i = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(i, temp.c_str());
												$<var.type>$ = i;

												$<var.addr>$ = getTemp("bool");
												string label1 = getLabel();
												string label2 = getLabel();
												if( type1 == "int" )
												{
													code += "if ( " + string($<var.addr>1) + " ==i " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}
												else if( type1 == "float" )
												{
													code += "if ( " + string($<var.addr>1) + " ==f " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}
												else if( type1 == "char" )
												{
													code += "if ( " + string($<var.addr>1) + " ==c " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}
												else if( type1 == "bool" )
												{
													code += "if ( " + string($<var.addr>1) + " ==b " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}
												else if( type1 == "string" )
												{
													code += "if ( " + string($<var.addr>1) + " ==s " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}

												code += string($<var.addr>$) + " =b #false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b #true\n";
												code += string(label2) + ":\n";	

												if( parseDebug == 1 )
												{
													cout << "eq_expr -> eq_expr == rel_expr" << endl;
												}
											}
			| equality_expression NE_OP relational_expression
											{
												//same as above
												string type1($<var.type>1);
												string type2($<var.type>3);

												if( type1 != type2 )
												{
													cout << "COMPILETIME ERROR: cannot compare two different type of operands" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}

												string temp = "bool";
												char* i = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(i, temp.c_str());
												$<var.type>$ = i;

												$<var.addr>$ = getTemp("bool");
												string label1 = getLabel();
												string label2 = getLabel();
												if( type1 == "int" )
												{
													code += "if ( " + string($<var.addr>1) + " !=i " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}
												else if( type1 == "float" )
												{
													code += "if ( " + string($<var.addr>1) + " !=f " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}
												else if( type1 == "char" )
												{
													code += "if ( " + string($<var.addr>1) + " !=c " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}
												else if( type1 == "bool" )
												{
													code += "if ( " + string($<var.addr>1) + " !=b " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}
												else if( type1 == "string" )
												{
													code += "if ( " + string($<var.addr>1) + " !=s " + string($<var.addr>3) + " ) goto " + string(label1) + "\n";
												}

												code += string($<var.addr>$) + " =b #false\n";
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b #true\n";
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
												// && is applicable to only two bool variables.
												if( strcmp($<var.type>1, "bool") != 0 or strcmp($<var.type>3, "bool") != 0 )
												{
													cout << "COMPILETIME ERROR: cannot apply '&&' to non-boolean operands" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}

												$<var.addr>$ = getTemp("bool");
												$<var.type>$ = $<var.type>1;

												//usual logical and translation.
												//if either of them is false then the result is false.

												char* label1 = getLabel();
												code += "if ( " + string($<var.addr>1) + " ==b false ) goto " + string(label1) + "\n";
												code += "if ( " + string($<var.addr>3) + " ==b false ) goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " =b #true\n";
												char* label2 = getLabel();
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b #false\n";
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
												//same a logical AND.
												if( strcmp($<var.type>1, "bool") != 0 or strcmp($<var.type>3, "bool") != 0 )
												{
													cout << "COMPILETIME ERROR: cannot apply '||' to non-boolean operands" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												$<var.addr>$ = getTemp();
												$<var.type>$ = $<var.type>1;

												char* label1 = getLabel();
												//if either of them is true then the resul is true.
												code += "if ( " + string($<var.addr>1) + " == true ) goto " + string(label1) + "\n";
												code += "if ( " + string($<var.addr>3) + " == true ) goto " + string(label1) + "\n";
												code += string($<var.addr>$) + " =b #false\n";
												char* label2 = getLabel();
												code += "goto " + string(label2) + "\n";
												code += string(label1) + ":\n";
												code += string($<var.addr>$) + " =b #true\n";
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
										string type2 = rtype;
										string var($<var.addr>1);
										string val($<var.addr>3);

										//usual assignment rules.
										if( op == "=" )
										{
											if( ltype == "int" and rtype == "int" )
											{
												code += var + " =i " + val + "\n";
											}
											else if( ltype == "float" and rtype == "float" )
											{
												code += var + " =f " + val + "\n";
											}
											else if( ltype == "string" and rtype == "string" )
											{
												code += var + " =s " + val + "\n";
											}
											else if( ltype == "char" and rtype == "char" )
											{
												code += var + " =c " + val + "\n";
											}
											else if( ltype == "bool" and rtype == "bool" )
											{
												code += var + " =b " + val + "\n";
											}
											else if( ltype == "float" and rtype == "int" )
											{
												char* t = getTemp("float");
												code += string(t) + " =f " + "elevateToFloat ( " + val + " )\n";
												code += var + " =f " + string(t) + "\n";
											}
											else
											{
												cout << "COMPILETIME ERROR: different operands type to '='" << endl;
												cout << "ltype = " << ltype << " rtype = " << rtype << endl;
												printSymbolTable();
												cout << "At line : " << yylineno << endl;
												return -1;
											}
										}
										else if( op[0] == '%' )
										{
											if( ltype != "int" or rtype != "int" )
											{
												cout << "COMPILETIME ERROR: non-int operands to %" << endl;
												cout << "At line : " << yylineno << endl;
												return -1;
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
												cout << "COMPILETIME ERROR: invalid operands for "  << op << endl;
												cout << "At line : " << yylineno << endl;
												return -1;
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
													cout << "COMPILETIME ERROR: cannot convert int to float" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												else if( type1 == "float" and type2 == "int" )
												{
													char* temp = getTemp();
													code += string(temp) + " = elevateToFloat ( " + val + " )\n";
													code += var + " =f " + var + " " + op[0] + "f " +  string(temp) + "\n";
												}
											}
										}
										else if( op[0] == '+' )
										{
											if( type1 == "int" and type2 == "int" )
											{
												code += var + " =i " + var + " +i " +  val + "\n";
											}
											else if( type1 == "float" and type2 == "float" )
											{
												code += var + " =f " + var + " +f " +  val + "\n";
											}
											else if( type1 == "int" and type2 == "float" )
											{
												cout << "COMPILETIME ERROR: cannot convert int to float" << endl;
												cout << "At line : " << yylineno << endl;
												return -1;
											}
											else if( type1 == "float" and type2 == "int" )
											{
												char* temp = getTemp("float");
												code += string(temp) + " = elevateToFloat ( " + val + " )\n";
												code += var + " =f " + var + " +f " +  string(temp) + "\n";
											}
											else if( type1 == "string" and type2 == "string" )
											{
													code += var + " =s strcat ( " + var + " , " +  val  + " )\n";
											}
											else if( type1 == "string" and type2 == "char" )
											{
													code += var + " =s strcatc ( " + var + " , " +  val  + " )\n";
											}
											else if( type1 == "char" and type2 == "int" )
											{
												code += var + " =c " + var + " +c " +  val + "\n";
											}
											else
											{
												cout << "COMPILETIME ERROR: Invalid operands for +" << endl;
												cout << "At line : " << yylineno << endl;
												return -1;
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
												if( parseDebug == 1 )
												{
													cout << "declaration expr -> typename declarationlist" << endl;
												}
											}
			;
	
	declarationlist
		: 	declaration ',' declarationlist		
			| declaration
			;
	
	declaration
		:	IDENTIFIER						{
												//insert the variable into the symbol table entry.
												vector<string> levels;
												string var($<str>1);
												if( insertEntry(var, dtype, levels, false) == -1 )
												{
													cout << "COMPILETIME ERROR: Redeclaration of an already existing variable" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}

												symbolTableEntry ste = getEntry(var);
												code += dtype + " " + ste.name + "_" + to_string(ste.scope) + "\n";
												
												if( parseDebug == 1 )
												{
													cout << "declaration -> identifier" << endl;
												}
											}
			| IDENTIFIER '=' expression		{
												//along with declaration, assign the variables with values.
												if( dtype != string($<var.type>3) )
												{
													cout << "COMPILETIME ERROR: cannot assign different variable types" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												vector<string> levels;
												string var($<str>1);
												if( insertEntry(var, dtype, levels, false) == -1 )
												{
													cout << "COMPILETIME ERROR: Redeclaration of an already existing variable" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}

												symbolTableEntry ste = getEntry(var);
												code += dtype + " " + ste.name + "_" + to_string(ste.scope) + "\n"; 
												if( dtype == "int" )
												{
													code += ste.name + "_" + to_string(ste.scope) + " =i " + string($<var.addr>3) + "\n";
												}
												else if( dtype == "float" )
												{
													code += ste.name + "_" + to_string(ste.scope) + " =f " + string($<var.addr>3) + "\n";
												}
												else if( dtype == "bool" )
												{
													code += ste.name + "_" + to_string(ste.scope) + " =b " + string($<var.addr>3) + "\n";
												}
												else if( dtype == "char" )
												{
													code += ste.name + "_" + to_string(ste.scope) + " =c " + string($<var.addr>3) + "\n";
												}
												else if( dtype == "string" )
												{
													code += ste.name + "_" + to_string(ste.scope) + " =s " + string($<var.addr>3) + "\n";
												}
												
												if( parseDebug == 1 )
												{
													cout << "declaration -> identifier = expression" << endl;
												}
											}
			| IDENTIFIER 
							{
								declevels.clear();
							}
			brackets			
							{							
								string var($<str>1);
								if( insertEntry(var, dtype, declevels, true) == -1 )
								{
									cout << "COMPILETIME ERROR: Redeclaration of an already existing variable" << endl;
									cout << "At line : " << yylineno << endl;
									return -1;
								}
								symbolTableEntry ste = getEntry(var);
								code += dtype + " " + ste.name + "_" + to_string(ste.scope);

								for( int i = 0 ; i < declevels.size() ; i++ )
								{
									code += " " + declevels[i];
								}
								code += "\n";
								
								if( parseDebug == 1 )
								{
									cout << "declaration -> identifier" << endl;
								}
							}
			;

	brackets
		:	'[' expression ']'
							{
								string type($<var.type>2);
								if( type != "int" )
								{
									cout << "COMPILETIME ERROR: cannot use non-int values as sizes for arrays" << endl;
									cout << "At line : " << yylineno << endl;
									return -1;
								}
								//push the variable deciding the dimension size into the levels vector.
								declevels.push_back($<var.addr>2);
							}
			brackets
			| '[' expression ']'
							{
								string type($<var.type>2);
								if( type != "int" )
								{
									cout << "COMPILETIME ERROR: cannot use non-int values as sizes for arrays" << endl;
									cout << "At line : " << yylineno << endl;
									return -1;
								}
								declevels.push_back($<var.addr>2);
							}
			;
	

	conditional_expression
		:	IF '(' 						
			expression ')'
											{
												string expr($<var.addr>3);

												//this contains the address of the code to execute, if the expression evaluates to false.
												string label1 = getLabel();
												
												char* f = new char[label1.length()-1];
												strcpy(f, label1.c_str());
												$<str>1 = f;

												string label2 = getLabel();
												ifgoto.push(label2);

												code += "if ( " + expr + " !=b #true ) goto " + label1 + "\n";
											}
			'{' 
											{
												//increase scope and push to the stack
												currentScope++;
												scopeStack.push(currentScope);
												$<intval>5 = scopeStack.top();
											}
			statement_list 
											{
												//after executing the code block go to the next statement after the entire if hierarchy.
												code += "goto " + ifgoto.top() + "\n";
												code += string($<str>1) + ":\n";
											}
			'}'								
											{
												//free all the variables declared within the if block.
												scopeStack.pop();
												if( symbolDebug == 1 )
												{
													printSymbolTable();
												}
												deleteEntries($<intval>5);
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
												//same as above
												string expr($<var.addr>3);
												string label1 = getLabel();
												
												char* f = new char[label1.length()-1];
												strcpy(f, label1.c_str());
												$<str>1 = f;

												code += "if ( " + expr + " !=b #true ) goto " + label1 + "\n";
											}
			'{' 
											{
												currentScope++;
												scopeStack.push(currentScope);
												$<intval>5 = scopeStack.top();
											}
								
			statement_list					{
												code += "goto " + ifgoto.top() + "\n";
												code += string($<str>1) + ":\n";
											}
			'}'
											{
												scopeStack.pop();
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
												scopeStack.push(currentScope);
												$<intval>2 = scopeStack.top();
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
												scopeStack.pop();
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
			| flow_control_statements ';'
			;
	
	flow_control_statements
		:	BREAK				
							{
								if( forNext.empty() == true )
								{
									cout << "COMPILETIME ERROR: cannot use break outside for loop" << endl;
									cout << "At line : " << yylineno << endl;
									return -1;
								}
								else
								{
									code += "goto " + forNext.top() +"\n";
								}
							}
			| CONTINUE
							{
								if( forIncrement.empty() == true )
								{
									cout << "COMPILETIME ERROR: cannot use continue outside for loop" << endl;
									cout << "At line : " << yylineno << endl;
									return -1;
								}
								else
								{
									code += "goto " + forIncrement.top() +"\n";
								}
							}
			| RETURN
			;

	IO_statement
		:	print_statement
			| scan_statement
			;

	scan_statement
		:	unary_expression '=' SCAN '('')'
									{
										//basing on the type of the unary expression appropriate, datatypes is scanned.
										string name = string($<var.addr>1);
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
										//add a new line character after printing the arguements.
										string var(getTemp("char"));
										code += var + " =c #'\\n'\n";
										code += "print char " + var + "\n";
									}
			| PRINT '(' ')'
									{
										//add a new line character after printing the arguements.
										string var(getTemp("char"));
										code += var + " =c #'\\n'\n";
										code += "print char " + var + "\n";
									}

			| PRINTS '(' print_args ')'
			;
	
	print_args
		:	expression ','		
										{
											//print the variables based on their types
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
											else if( string($<var.type>1) == "string" )
											{
												code += "print string " + string($<var.addr>1) + "\n";
											}
										}
			print_args
			| expression
										{
											//same as above
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
											else if( string($<var.type>1) == "string" )
											{
												code += "print string " + string($<var.addr>1) + "\n";
											}
										}
			;

	for_expression
		:	FOR '(' 
											{
												//increment and scope and push it to the stack
												currentScope++;
												scopeStack.push(currentScope);
												$<intval>2 = scopeStack.top();
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
												forIncrement.push(incrementstart);

												string endfor = getLabel();
												forNext.push(endfor);

												char* f = new char[statementstart.length()-1];
												strcpy(f, statementstart.c_str());
												$<str>4 = f;

												char* g = new char[incrementstart.length()-1];
												strcpy(g, incrementstart.c_str());
												$<var.addr>6 = g;

												char* h = new char[endfor.length()-1];
												strcpy(h, endfor.c_str());
												$<var.type>6 = h;
												
												//if the expr evaluates to false then go to the code next to the for block.
												code += "if ( " + expr + " !=b #true ) goto " + endfor + "\n";
												//else goto to the start of the code block of the for statement.
												code += "goto " + statementstart + "\n";
												code += incrementstart + ":\n";
											}
			loop_increment_list 			{
												//after incrementing goto the start of the codition checking.
												code += "goto " + string($<str>1) + "\n";
												code += string($<str>4) + ":\n";
											}
			')' '{' statement_list 			{
												//after executing the block go to the increment part.
												code += "goto " + string($<var.addr>6) + "\n";
												code += string($<var.type>6) + ":\n";
												if( parseDebug == 1 )
												{
													cout << "forstatemet -> completed" << endl;
												}
											}
			'}'								{
												//release the variables
												scopeStack.pop();
												if( symbolDebug == 1 )
												{
													printSymbolTable();
												}
												deleteEntries($<intval>2);
												forIncrement.pop();
												forNext.pop();
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
		VOID MAIN '(' ')' statement_block			//currently the execution is hardcoded to start with main.
		;

	statement_block
		:	'{' 						{
											currentScope++;
											scopeStack.push(currentScope);
											$<intval>1 = scopeStack.top();
										}
			statement_list
										{
											if( parseDebug == 1 )
												{
													cout << "statement_block -> { statementlist }" << endl;
												}
										}
			'}'							{
											//release the variables.
											scopeStack.pop();
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
	int i = yyparse();

	string filename(arguements[1]);

	if( i == -1 )
	{
		return 0;
	}
	
	printSymbolTable();

	//ofstream Myfile(filename + ".tmp");
	ofstream Myfile("output.txt");

	Myfile << code;
	Myfile.close();
	return 0;
}
