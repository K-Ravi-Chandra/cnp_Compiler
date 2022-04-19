%{
#include<fstream>
#include<stdio.h>
#include<string.h>
#include<iostream>
#include<unordered_map>
#include<vector>
#include<stack>
#include<unistd.h>
#include"symbolTable.h"

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
		printSymbolTable();
		cout << "temp code = " << TemporaryCode << endl;
		return;
	}
	int yywrap()
	{
		return 1; 
	} 
}
%}
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

%token BREAK CHAR CONST CONTINUE ELSE ELIF FLOAT FOR IN IF INT RETURN SIZEOF VOID BOOL STRING ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN POW_ASSIGN INC_OP DEC_OP OR_OP AND_OP LE_OP GE_OP EQ_OP NE_OP C_CONST S_CONST B_CONST I_CONST F_CONST IDENTIFIER LET PRINT PRINTS SCAN MAIN LEN VAR NULL_ NEW

%start begin

%%
	primary_expression								
		:	IDENTIFIER						{	
												SymbolTableEntry ste = getVariable(string($<str>1) );
												if( ste.name == "" )
												{
													cout << "COMPILETIME ERROR: " << string($<str>1) << " not declared" << endl;
													cout << "At line : " << yylineno << endl;
													printSymbolTable();
													printScopeStack();
													return -1;
												}
												else if( ste.name.substr(0, 4) == "this" )
												{
													string thisName = "this_" + to_string(ste.scope);
													string varName = ste.name.substr(5, ste.name.length());

													
													string temp1(getTemp("int"));
													appendCode("la " + temp1 + " " + thisName);

													string temp2(getTemp("int"));
													appendCode(temp2 + " =i " + "address( " + currentStruct + " , " + varName + " )");
	
													string temp3(getTemp("int"));
													appendCode(temp3 + " =i " + temp1 + " +i " + temp2);
	
													char* t = (char*) calloc(ste.dataType.length()-1, sizeof(char));
													strcpy(t, ste.dataType.c_str());
													$<var.type>$ = t;
													
													temp3 = "*" + temp3;
													t = (char*) calloc(temp3.length()-1, sizeof(char));
													strcpy(t, temp3.c_str());

													$<var.addr>$ = t;
												}
												else
												{
													char* t = (char*) calloc(ste.dataType.length(), sizeof(char));
													strcpy(t, ste.dataType.c_str());
													$<var.type>$ = t;
	
													string temp = ste.name + "_" + to_string(ste.scope);
													t = (char*) calloc(temp.length()-1, sizeof(char));
													strcpy(t, temp.c_str());
													$<var.addr>$ = t;
												}

												if( parseDebug == 1 )
												{
													cout << "primary_expression -> IDENTIFIER" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
												}
											}	
			| constant						{
												$<var.addr>$ = $<var.addr>1;
												$<var.type>$ = $<var.type>1;

												if( parseDebug == 1 )
												{
													cout << "primary_expression -> constant" << endl
													;cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
												}
											}
			| '(' expression ')'			{
												$<var.addr>$ = $<var.addr>2;
												$<var.type>$ = $<var.type>2;

												if( parseDebug == 1 )
												{
													cout << "primary_expression -> ( expression )" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
												}
											}
			| NULL_							{
												string type = "int";
												char* t = (char*) calloc(type.length(), sizeof(char));
												strcpy(t, type.c_str());
												$<var.type>$ = t;

												$<var.addr>$ = getTemp("int");
												appendCode(string($<var.addr>$) + " =i #0");

												if( parseDebug == 1 )
												{
													cout << "primary_expression -> NULL_" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
												appendCode(string($<var.addr>$) + " =i #" + string($<str>1));

												if( parseDebug == 1 )
												{
													cout << "constant -> I_const" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
												}
											}
			| F_CONST						{
												//similar as above
												string temp = "float";
												char* t = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(t, temp.c_str());
												$<var.type>$ = t;
									
												$<var.addr>$ = getTemp("float");

												appendCode(string($<var.addr>$) + " =f #" + string($<str>1));

												if( parseDebug == 1 )
												{
													cout << "constant -> F_const" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
												}
											}
			| C_CONST						{
												//similar as above
												string temp = "char";
												char* t = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(t, temp.c_str());
												$<var.type>$ = t;
									
												$<var.addr>$ = getTemp("char");

												appendCode(string($<var.addr>$) + " =c #" + string($<str>1));

												if( parseDebug == 1 )
												{
													cout << "constant -> C_const" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
												}
											}
			| S_CONST						{
												//similar as above
												string temp = "string";
												char* t = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(t, temp.c_str());
												$<var.type>$ = t;
									

												string strConst = getStringConst();

												$<var.addr>$ = getTemp("int");
												appendCode( "strconst " + strConst +  " " + string($<var.addr>$) + " #" + string($<str>1));
												if( parseDebug == 1 )
												{
													cout << "constant -> S_const" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
												}
											}
			| B_CONST						{
												//similar as above
												string temp = "bool";
												char* t = (char*) calloc(temp.length()-1, sizeof(char));
												strcpy(t, temp.c_str());
												$<var.type>$ = t;
									
												$<var.addr>$ = getTemp("bool");


												if( string($<str>1) == "true" )
												{
													appendCode(string($<var.addr>$) + " =b #true");
												}
												else
												{
													appendCode(string($<var.addr>$) + " =b #false");
												}

												if( parseDebug == 1 )
												{
													cout << "constant -> B_const" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
												}
											}
			;

	postfix_expression
		:	primary_expression				{
												string addr($<var.addr>1);
												if( addr[0] == '_' )
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
													SymbolTableEntry ste = getVariable(origname);
													if( ste.levels.size() != 0 )
													{
														$<array.addr>$ = $<var.addr>1;
														$<array.type>$ = $<var.type>1;
														$<array.completed>$ = 0;
														$<array.level>$ = 0;
														$<array.index>$ = $<array.addr>$;
													}
													else if( ste.dataType == "string" )
													{
														$<array.addr>$ = $<var.addr>1;
														$<array.type>$ = $<var.type>1;
														$<array.completed>$ = 2;
														$<array.level>$ = 0;
														$<array.index>$ = $<array.addr>$;
													}
													else
													{
														$<array.addr>$ = $<var.addr>1;
														$<array.type>$ = $<var.type>1;
														$<array.index>$ = NULL;
														$<array.level>$ = 0;
														$<array.completed>$ = 1;
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
													else if( addr[i] == '.' )
													{
														origname = "";
													}
													else
													{
														break;
													}
												}

												SymbolTableEntry ste = getVariable(origname);
												if( $<array.completed>1 == 2 )
												{
													string temp(getTemp("int"));
													appendCode(temp + " =i len " + string($<array.addr>$));

													string label1 = getLabel();
													string label2 = getLabel();
													
													appendCode("if ( " + string($<var.addr>3) + " <i " + temp + " ) goto " +  label1);
													string strconst = getStringConst();
													string var(getTemp("int"));
													appendCode("strconst " + strconst + " " + var + " #" + "\"RUNTIME ERROR: Index out of Bounds\\n\"");
													appendCode("print string " + var);
													appendCode("exit");
													appendCode(label1 + ":");
													appendCode("if ( " + string($<var.addr>3) + " >=i #0 ) goto " + label2);
													
													strconst = getStringConst();
													var = (getTemp("int"));
													appendCode("strconst " + strconst + " " + var + " #" + "\"RUNTIME ERROR: Index is negative\\n\"");
													appendCode("print string " + var);
													
													appendCode("exit");
													appendCode(label2 + ":");
													
													temp = string(getTemp("int"));

													appendCode(temp + " =i " + string($<array.addr>1) + " +i " + string($<var.addr>3));

													temp = "*" + temp;
													char* s = (char*) calloc(temp.size()+1, sizeof(char));
													strcpy($<array.addr>$, temp.c_str());

													temp = "char";
													s = (char*) calloc(temp.size()+1, sizeof(char));
													strcpy($<array.type>$, temp.c_str());
													
													$<array.completed>$ = 1;
												}
												else if( $<array.level>1 ==  ste.levels.size()-1 )
												{
														string label1 = getLabel();
														string label2 = getLabel();

														appendCode("if ( " + string($<var.addr>3) + " <i " + ste.levels[$<array.level>1] + "_" + to_string(ste.scope) + " ) goto " +  label1);
														string strconst = getStringConst();
													string var(getTemp("int"));
													appendCode("strconst " + strconst + " " + var + " #" + "\"RUNTIME ERROR: Index out of Bounds\\n\"");
													appendCode("print string " + var);
													appendCode("exit");
													appendCode(label1 + ":");
													appendCode("if ( " + string($<var.addr>3) + " >=i #0 ) goto " + label2);
													
													strconst = getStringConst();
													var = (getTemp("int"));
													appendCode("strconst " + strconst + " " + var + " #" + "\"RUNTIME ERROR: Index is negative\\n\"");
													appendCode("print string " + var);
													
													appendCode("exit");
													appendCode(label2 + ":");

													string temp(getTemp("int"));

													appendCode(temp + " =i " + string($<var.addr>3) + " *i #" + to_string(getActualSize(ste.dataType)));
													
													appendCode(temp + " =i " + string($<array.index>1) + " +i " + temp);

													temp = "*" + temp;
													char* s = (char*) calloc(temp.size()+1, sizeof(char));
													strcpy($<array.addr>$, temp.c_str());

													$<array.type>$ = $<array.type>1;
													$<array.completed>$ = 1;
													if( string($<array.type>$) == "string" )
													{
														$<array.completed>$ = 2;
													}
												}
												else
												{
														string label1 = getLabel();
														string label2 = getLabel();
														appendCode("if ( " + string($<var.addr>3) + " <i " + ste.levels[$<array.level>1] + "_" + to_string(ste.scope) + " ) goto " +  label1);
														string strconst = getStringConst();
													string var(getTemp("int"));
													appendCode("strconst " + strconst + " " + var + " #" + "\"RUNTIME ERROR: Index out of Bounds\\n\"");
													appendCode("print string " + var);
													appendCode("exit");
													appendCode(label1 + ":");
													appendCode("if ( " + string($<var.addr>3) + " >=i #0 ) goto " + label2);
													
													strconst = getStringConst();
													var = (getTemp("int"));
													appendCode("strconst " + strconst + " " + var + " #" + "\"RUNTIME ERROR: Index is negative\\n\"");
													appendCode("print string " + var);
													
													appendCode("exit");
													appendCode(label2 + ":");

													$<array.index>$ = getTemp("int");
													string temp($<array.index>$);

													appendCode(temp + " =i #1");

													for( int i = $<array.level>1 + 1; i < ste.levels.size() ; i++ )
													{
														appendCode(temp + " =i " + temp + " *i " + ste.levels[i] + "_" + to_string(ste.scope));
													}

													appendCode(temp + " =i " + temp + " *i #" + to_string(getActualSize(ste.dataType)));

													appendCode(temp + " =i " + string($<var.addr>3) + " *i " + temp );
													appendCode(temp + " =i " + temp + " +i " + string($<array.index>1));

													$<array.addr>$ = $<array.addr>1;
													$<array.completed>$ = 0;
													$<array.level>$ = $<array.level>1 + 1;
													$<array.type>$ = $<array.type>1;
												}
												if( parseDebug == 1 )
												{
													cout << "postfix_expression -> postfix_expression [ expression ]" << endl;
												}
											}
			| postfix_expression INC_OP		{
												if( $<array.completed>$ >= 1 )
												{
													if( strcmp($<array.type>1,"int") != 0 )
													{
														cout << "COMPILETIME ERROR: cannot apply increment operator to non int types" << endl;
														cout << "At line : " << yylineno << endl;
														return -1;
													}
													$<array.addr>$ = getTemp("int");
													appendCode(string($<array.addr>$) + " =i " + string($<array.addr>1));
													appendCode(string($<array.addr>1) + " =i " + string($<array.addr>1) + " +i " + "#1");
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
												if( $<array.completed>$ >= 1 )
												{
													if( strcmp($<array.type>1,"int") != 0 )
													{
														cout << "COMPILETIME ERROR: cannot apply decrement operator to non int types" << endl;
														cout << "At line : " << yylineno << endl;
														return -1;
													}
													$<array.addr>$ = getTemp("int");
													appendCode(string($<array.addr>$) + " =i " + string($<array.addr>1));
													appendCode(string($<array.addr>1) + " =i " + string($<array.addr>1) + " -i " + "#1");
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
			| postfix_expression '.' IDENTIFIER
											{
												SymbolTableEntry ste = getStructAttribute( string($<array.type>1), string($<str>3));
												if( ste.name == "" )
												{
													cout << "COMPILETIME ERROR: type " << string($<array.type>1) << " doesn't have an attribute " << string($<str>3) << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}


												string temp1(getTemp("int"));
												appendCode("la " + temp1 + " " + string($<array.addr>1));

												string temp2(getTemp("int"));
												appendCode(temp2 + " =i " + "address( " + string($<array.type>1) + " , " + string($<array.addr>1) + " )");

												string temp3(getTemp("int"));
												appendCode(temp3 + " =i " + temp1 + " +i " + temp2);



												char* t = (char*) calloc(ste.dataType.length()-1, sizeof(char));
												strcpy(t, ste.dataType.c_str());
												$<array.type>$ = t;
												
												temp3 = "*" + temp3;
												t = (char*) calloc(temp3.length()-1, sizeof(char));
												strcpy(t, temp3.c_str());

												$<array.addr>$ = t;
												$<array.completed>$ = 1;
											}
			| postfix_expression '.' IDENTIFIER '('
								{
									SymbolTableEntry ste = getFunctionReturnAddress(string($<array.type>1), string($<str>3));

									if( ste.name == "" )
									{
										cout << "COMPILETIME ERROR: Type " << string($<array.type>1) << " doesn't have a method " << string($<str>3) << endl;
										cout << "At line : " << yylineno << endl;
										return 1;
									}
									appendCode("funCall " + string($<array.type>1) + "." + string($<str>3));
									setCallStack(string($<array.type>1), string($<str>3));
									appendCode("param " + string($<array.addr>1));
									callStack.pop();
								}
			functionCall		{
									SymbolTableEntry ste = getFunctionReturnAddress(string($<array.type>1), string($<str>3));

									if( !callStack.empty() )
									{
										cout << "COMPILETIME ERROR: Too few arguments for the function " << string($<array.type>1) << "." << string($<str>3) << endl;
										cout << "At line : " << yylineno << endl;
										return -1;
									}
									
									appendCode("call " + getFunctionLabel(string($<array.type>1), string($<str>1)));
									
									$<array.completed>$ = 1;
									char* t = (char*) calloc(ste.dataType.length()-1, sizeof(char));
									strcpy(t, ste.dataType.c_str());
									$<array.type>$ = t;

									$<array.addr>$ = getTemp(ste.dataType);

									appendCode(string($<array.addr>$) + " = returnVal");

									if( parseDebug == 1 )
									{
										cout << "postfix expr -> postfix . identifier '(' functionCall " << endl;
									}
								}
			| IDENTIFIER '(' 
								{
									SymbolTableEntry ste = getFunctionReturnAddress("main", string($<str>1));

									if( ste.name == "" )
									{
										cout << "COMPILETIME ERROR: " << string($<str>1) << " not declared" << endl;
										cout << "At line : " << yylineno << endl;
										return 1;
									}
									appendCode("funCall main." + string($<str>1));
									setCallStack("main", string($<str>1));
								}
			functionCall
								{
									SymbolTableEntry ste = getFunctionReturnAddress("main", string($<str>1));

									if( !callStack.empty() )
									{
										cout << "COMPILETIME ERROR: Too few arguments for the function " << string($<str>1) << endl;
										cout << "At line : " << yylineno << endl;
										return -1;
									}
									
									appendCode("call " + getFunctionLabel("main", string($<str>1)));
									
									$<array.completed>$ = 1;
									
									char* t = (char*) calloc(ste.dataType.length()-1, sizeof(char));
									strcpy(t, ste.dataType.c_str());
									$<array.type>$ = t;

									$<array.addr>$ =  getTemp(ste.dataType);
									appendCode(string($<array.addr>$) + " = returnVal");

									if( parseDebug == 1 )
									{
										cout << "postfix expr -> identifier '(' functionCall " << endl;
									}
								}
			;
	
	functionCall:
		')'						
								{
									if( parseDebug == 1 )
									{
										cout << "functionCall ->  ')'" << endl;
									}
								}
		| argument_list ')'
								{
									if( parseDebug == 1 )
									{
										cout << "functionCall -> argument_list ')'" << endl;
									}
								}

	argument_list
		:	expression
								{
									if( callStack.empty() )
									{
										cout << "COMPILETIME ERROR: Too many arguments" << endl;
										cout << "At line : " << yylineno << endl;
										return -1;
									}
									else if( string($<var.type>1) != callStack.top().dataType )
									{
										cout << "COMPILETIME ERROR: Incorrect function parameters type" << endl;
										cout << "Given parameter is of type " << string($<var.type>1) << ", required parameter is of type " << callStack.top().dataType << endl;
										cout << "At line : " << yylineno << endl;
										return -1;
									}
									appendCode("param " + string($<var.addr>1));
									callStack.pop();
									if( parseDebug == 1 )
									{
										cout << "argumentlist -> expression" << endl;
									}
								}
			| argument_list ',' expression
								{
									appendCode("param " + string($<var.addr>1));
									if( callStack.empty() )
									{
										cout << "COMPILETIME ERROR: Too many arguments" << endl;
										cout << "At line : " << yylineno << endl;
										return -1;
									}
									else if( string($<var.type>1) != callStack.top().dataType )
									{
										cout << "COMPILETIME ERROR: Incorrect function parameters type" << endl;
										cout << "Given parameter is of type " << string($<var.type>1) << ", required parameter is of type " << callStack.top().dataType << endl;
										cout << "At line : " << yylineno << endl;
										return -1;
									}
									callStack.pop();
									if( parseDebug == 1 )
									{
										cout << "argumentlist -> argumentlist ',' expression" << endl;
									}
								}
			;
	
	unary_expression
		:	postfix_expression				{	
												//if the expression is complete then do the usual
												if( $<array.completed>$ >= 1 )
												{
													$<var.addr>$ = $<array.addr>1;
													if( $<array.completed>$ == 2 )
													{
														string temp = "string";
														char* s = (char*) calloc(temp.size()-1, sizeof(char));
														strcpy(s, temp.c_str());
														$<var.type>$ = s;
													}
													else
													{
														$<var.type>$ = $<array.type>1;
													}
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
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
												appendCode(string($<var.addr>2) + " =i " + string($<var.addr>2) + " +i " + "#1");
												appendCode(string($<var.addr>$) + " =i " + string($<var.addr>2));
												$<var.type>$ = $<var.type>2;

												if( parseDebug == 1 )
												{
													cout << "unary_expr	-> INC_OP unary_expr" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
												appendCode(string($<var.addr>2) + " =i " + string($<var.addr>2) + " -i " + "#1");
												appendCode(string($<var.addr>$) + " =i " + string($<var.addr>2));
												$<var.type>$ = $<var.type>2;
												if( parseDebug == 1 )
												{
													cout << "unary_expr	-> DEC_OP unary_expr" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
												}
											}
			| unary_operator unary_expression
											{
												string op($<str>1);
												string type($<var.type>2); 
												$<var.type>$ = $<var.type>2;

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
															$<var.addr>$ = getTemp("int");
															appendCode(string($<var.addr>$) + " = " + "minus " + string($<var.addr>2));
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
														$<var.addr>$ = getTemp("bool");
														appendCode(string($<var.addr>$) + " = " + "not " + string($<var.addr>2));
													}
												}	
												if( op == "*" )
												{
													if( type[0] != '*' )
													{
														cout << "COMPILETIME ERROR: cannot apply * to non-pointer type" << endl;
														cout << "At line : " << yylineno << endl;
														return -1;
													}
													else
													{
														string temp = type.substr(1, type.size());
														
														char* i = (char*) calloc(temp.length()-1, sizeof(char));
														strcpy(i, temp.c_str());
														$<var.type>$ = i;

														string addr(getTemp(temp));
														appendCode( addr + " =i " + string($<var.addr>2) );

														addr = "*" + addr;

														i = (char*) calloc(addr.length(), sizeof(char));
														strcpy(i, addr.c_str());
														$<var.addr>$ = i;
													}
												}
												if( op == "&" ) 
												{
														$<var.addr>$ = getTemp("int");
														
														string temp = "int";
														
														char* i = (char*) calloc(temp.length()-1, sizeof(char));
														strcpy(i, temp.c_str());
														$<var.type>$ = i;

														appendCode("la " + string($<var.addr>2) + " " + string($<var.addr>$));
												}
												if( parseDebug == 1 )
												{
													cout << "unary_expr	-> unary_op unary_expr" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
												}
											}
			| LEN '(' IDENTIFIER ')'		
											{
												SymbolTableEntry ste = getVariable(string($<str>3) );
												if( ste.name == "" )
												{
													cout << "COMPILETIME ERROR: " << string($<str>1) << " not declared" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}

												string type = "int";
												char* t = (char*) calloc(type.length(), sizeof(char));
												strcpy(t, type.c_str());
												$<var.type>$ = t;

												$<var.addr>$ = getTemp("int");

												//string temp = ste.name + "_" + to_string(ste.scope);
												appendCode(string($<var.addr>$) + " =i len " + ste.name + "_" + to_string(ste.scope));
												if( parseDebug == 1 )
												{	
													cout << "unary_expr -> len '(' identifier ')'" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
												}
											}
			;
	
	type_name		
		:	INT							{	dtype = "int"; 	starsCount = 0; newOrNot = false;}			//set the dtypes for declaration purposes.	
			| FLOAT						{	dtype = "float";starsCount = 0; newOrNot = false;}
			| CHAR						{   dtype = "char";starsCount = 0; newOrNot = false; }
			| STRING					{ 	dtype = "string";starsCount = 0; newOrNot = false;}
			| BOOL						{ 	dtype = "bool";starsCount = 0; newOrNot = false; }
			| VAR IDENTIFIER			{ 	dtype = string($<str>2); starsCount = 0; newOrNot = false;}
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
			| '*'			{
								$<str>$ = $<str>1;
								if( parseDebug == 1 )
												{
													cout << "unary_op -> *" << endl;
												}
							}
			| '&'			{
								$<str>$ = $<str>1;
								if( parseDebug == 1 )
												{
													cout << "unary_op -> &" << endl;
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
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
														appendCode(string($<var.addr>$) + " =i " + string($<var.addr>1) + " *i " +  string($<var.addr>3));
													}
													//if both are float's then the result is also an float.
													else if( type1 == "float" and type2 == "float" )
													{
														$<var.addr>$ = getTemp("float");
														$<var.type>$ = $<var.type>1;
														appendCode(string($<var.addr>$) + " =f " + string($<var.addr>1) + " *f " +  string($<var.addr>3));
													}
													//if one is int and the other is float, then promote the int to float and 
													//store the result in a float variable.
													else if( type1 == "int" and type2 == "float" )
													{
														$<var.addr>$ = getTemp("float");
														$<var.type>$ = $<var.type>3;
														char* temp = getTemp("float");
														appendCode(string(temp) + " =f elevateToFloat ( " + string($<var.addr>1) + " )");
														appendCode(string($<var.addr>$) + " =f " + string(temp) + " *f " +  string($<var.addr>3));
													}
													//same as above
													else if( type1 == "float" and type2 == "int" )
													{
														$<var.addr>$ = getTemp("float");
														$<var.type>$ = $<var.type>1;
														char* temp = getTemp("float");
														appendCode(string(temp) + " =f elevateToFloat ( " + string($<var.addr>3) + " )");
														appendCode(string($<var.addr>$) + " =f " + string($<var.addr>1) + " *f " +  string(temp));
													}
												}
												if( parseDebug == 1 )
												{
													cout << "multi -> multi * unary_expr" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
														appendCode(string($<var.addr>$) + " =i " + string($<var.addr>1) + " /i " +  string($<var.addr>3));
													}
													else if( type1 == "float" and type2 == "float" )
													{
														$<var.addr>$ = getTemp("float");
														$<var.type>$ = $<var.type>1;
														appendCode(string($<var.addr>$) + " =f " + string($<var.addr>1) + " /f " +  string($<var.addr>3));
													}
													else if( type1 == "int" and type2 == "float" )
													{
														$<var.addr>$ = getTemp("float");
														$<var.type>$ = $<var.type>3;
														char* temp = getTemp("float");
														appendCode(string(temp) + " = elevateToFloat ( " + string($<var.addr>1) + " )");
														appendCode(string($<var.addr>$) + " =f " + string(temp) + " /f " +  string($<var.addr>3));
													}
													else if( type1 == "float" and type2 == "int" )
													{
														$<var.addr>$ = getTemp("float");
														$<var.type>$ = $<var.type>1;
														char* temp = getTemp("float");
														appendCode(string(temp) + " = elevateToFloat ( " + string($<var.addr>3) + " )");
														appendCode(string($<var.addr>$) + " =f " + string($<var.addr>1) + " /f " +  string(temp));
													}
												}
												if( parseDebug == 1 )
												{
													cout << "multi -> multi / unary_expr" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
														appendCode(string($<var.addr>$) + " =i " + string($<var.addr>1) + " %i " +  string($<var.addr>3));
												}
												if( parseDebug == 1 )
												{
													cout << "multi	-> multi %% unary_expr" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
													appendCode(string($<var.addr>$) + " =i " + string($<var.addr>1) + " +i " +  string($<var.addr>3));
												}
												//if both are float's then the result is float.
												else if( type1 == "float" and type2 == "float" )
												{
													$<var.addr>$ = getTemp("float");
													$<var.type>$ = $<var.type>1;
													appendCode(string($<var.addr>$) + " =f " + string($<var.addr>1) + " +f " +  string($<var.addr>3));
												}
												//if one is int and other is float then promote int to float.
												else if( type1 == "int" and type2 == "float" )
												{
													$<var.addr>$ = getTemp("float");
													$<var.type>$ = $<var.type>3;
													char* temp = getTemp("float");
													appendCode(string(temp) + " = elevateToFloat ( " + string($<var.addr>1) + " )");
													appendCode(string($<var.addr>$) + " =f " + string(temp) + " +f " +  string($<var.addr>3));
												}
												//if one is int and other is float then promote int to float.
												else if( type1 == "float" and type2 == "int" )
												{
													$<var.addr>$ = getTemp("float");
													$<var.type>$ = $<var.type>1;
													char* temp = getTemp("float");
													appendCode(string(temp) + " = elevateToFloat ( " + string($<var.addr>3) + " )");
													appendCode(string($<var.addr>$) + " =f " + string($<var.addr>1) + " +f " +  string(temp));
												}
												//if both are strings then concatenate the two strings.
												else if( type1 == "string" and type2 == "string" )
												{
													$<var.type>$ = $<var.type>1;
													$<var.addr>$ = getTemp("string");
													appendCode(string($<var.addr>$) + " =s strcat " + string($<var.addr>1) + " " +  string($<var.addr>3));
												}
												//if second operand is char then concatenate the char to the string.
												else if( type1 == "string" and type2 == "char" )
												{
													$<var.type>$ = $<var.type>1;
													$<var.addr>$ = getTemp("string");
													appendCode(string($<var.addr>$) + " =s strcatc " + string($<var.addr>1) + " " +  string($<var.addr>3));
												}
												//if second operand is int, then add add the int, to char ( ascii addition ).
												else if( type1 == "char" and type2 == "int" )
												{
													$<var.addr>$ = getTemp("char");
													$<var.type>$ = $<var.type>1;
													appendCode(string($<var.addr>$) + " =c " + string($<var.addr>1) + " +c " +  string($<var.addr>3));
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
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
													appendCode(string($<var.addr>$) + " =i " + string($<var.addr>1) + " -i " +  string($<var.addr>3));
												}
													else if( type1 == "float" and type2 == "float" )
												{
													$<var.addr>$ = getTemp("float");
													$<var.type>$ = $<var.type>1;
													appendCode(string($<var.addr>$) + " =f " + string($<var.addr>1) + " -f " +  string($<var.addr>3));
												}
												else if( type1 == "int" and type2 == "float" )
												{
													$<var.addr>$ = getTemp("float");
													$<var.type>$ = $<var.type>3;
													char* temp = getTemp("float");
													appendCode(string(temp) + " = elevateToFloat ( " + string($<var.addr>1) + " )");
													appendCode(string($<var.addr>$) + " =f " + string(temp) + " -f " +  string($<var.addr>3));
												}
												else if( type1 == "float" and type2 == "int" )
												{
													$<var.addr>$ = getTemp("float");
													$<var.type>$ = $<var.type>1;
													char* temp = getTemp("float");
													appendCode(string(temp) + " = elevateToFloat ( " + string($<var.addr>3) + " )");
													appendCode(string($<var.addr>$) + " =f " + string($<var.addr>1) + " -f " +  string(temp));
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
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
													appendCode("if ( " + string($<var.addr>1) + " <i " + string($<var.addr>3) + " ) goto " + string(label1));
												}
												else
												{
													appendCode("if ( " + string($<var.addr>1) + " <f " + string($<var.addr>3) + " ) goto " + string(label1));
												}

												//set the result to true if the expression is true.
												appendCode(string($<var.addr>$) + " =b #false");
												appendCode("goto " + string(label2));
												appendCode(string(label1) + ":");
												appendCode(string($<var.addr>$) + " =b #true");
												appendCode(string(label2) + ":");	

												if( parseDebug == 1 )
												{
													cout << "rel_expr -> rel_expr < additive" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
													appendCode("if ( " + string($<var.addr>1) + " >i " + string($<var.addr>3) + " ) goto " + string(label1));
												}
												else
												{
													appendCode("if ( " + string($<var.addr>1) + " >f " + string($<var.addr>3) + " ) goto " + string(label1));
												}

												appendCode(string($<var.addr>$) + " =b #false");
												appendCode("goto " + string(label2));
												appendCode(string(label1) + ":");
												appendCode(string($<var.addr>$) + " =b #true");
												appendCode(string(label2) + ":");	

												if( parseDebug == 1 )
												{
													cout << "rel_expr -> rel_expr > additive" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
													appendCode("if ( " + string($<var.addr>1) + " <=i " + string($<var.addr>3) + " ) goto " + string(label1));
												}
												else
												{
													appendCode("if ( " + string($<var.addr>1) + " <=f " + string($<var.addr>3) + " ) goto " + string(label1));
												}

												appendCode(string($<var.addr>$) + " =b #false");
												appendCode("goto " + string(label2));
												appendCode(string(label1) + ":");
												appendCode(string($<var.addr>$) + " =b #true");
												appendCode(string(label2) + ":");	

												if( parseDebug == 1 )
												{
													cout << "rel_expr -> rel_expr <= additive" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
													appendCode("if ( " + string($<var.addr>1) + " >=i " + string($<var.addr>3) + " ) goto " + string(label1));
												}
												else
												{
													appendCode("if ( " + string($<var.addr>1) + " >=f " + string($<var.addr>3) + " ) goto " + string(label1));
												}

												appendCode(string($<var.addr>$) + " =b #false");
												appendCode("goto " + string(label2));
												appendCode(string(label1) + ":");
												appendCode(string($<var.addr>$) + " =b #true");
												appendCode(string(label2) + ":");	

												if( parseDebug == 1 )
												{
													cout << "rel_expr -> rel_expr >= additive" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
												}
											}
			| equality_expression EQ_OP relational_expression
											{
												string type1($<var.type>1);
												string type2($<var.type>3);
												
												//can compare only equal types.
												if( type1 != type2 and !(type1[0] == '*' and type2 == "int") )
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
													appendCode("if ( " + string($<var.addr>1) + " ==i " + string($<var.addr>3) + " ) goto " + string(label1));
												}
												else if( type1 == "float" )
												{
													appendCode("if ( " + string($<var.addr>1) + " ==f " + string($<var.addr>3) + " ) goto " + string(label1));
												}
												else if( type1 == "char" )
												{
													appendCode("if ( " + string($<var.addr>1) + " ==c " + string($<var.addr>3) + " ) goto " + string(label1));
												}
												else if( type1 == "bool" )
												{
													appendCode("if ( " + string($<var.addr>1) + " ==b " + string($<var.addr>3) + " ) goto " + string(label1));
												}
												else if( type1 == "string" )
												{
													appendCode("if ( " + string($<var.addr>1) + " ==s " + string($<var.addr>3) + " ) goto " + string(label1));
												}
												else if( type1[0] == '*' )
												{
													appendCode("if ( " + string($<var.addr>1) + " ==i " + string($<var.addr>3) + " ) goto " + string(label1));
												}

												appendCode(string($<var.addr>$) + " =b #false");
												appendCode("goto " + string(label2));
												appendCode(string(label1) + ":");
												appendCode(string($<var.addr>$) + " =b #true");
												appendCode(string(label2) + ":");	

												if( parseDebug == 1 )
												{
													cout << "eq_expr -> eq_expr == rel_expr" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
												}
											}
			| equality_expression NE_OP relational_expression
											{
												//same as above
												string type1($<var.type>1);
												string type2($<var.type>3);

												if( type1 != type2 and !(type1[0] == '*' and type2 == "int") )
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
													appendCode("if ( " + string($<var.addr>1) + " !=i " + string($<var.addr>3) + " ) goto " + string(label1));
												}
												else if( type1 == "float" )
												{
													appendCode("if ( " + string($<var.addr>1) + " !=f " + string($<var.addr>3) + " ) goto " + string(label1));
												}
												else if( type1 == "char" )
												{
													appendCode("if ( " + string($<var.addr>1) + " !=c " + string($<var.addr>3) + " ) goto " + string(label1));
												}
												else if( type1 == "bool" )
												{
													appendCode("if ( " + string($<var.addr>1) + " !=b " + string($<var.addr>3) + " ) goto " + string(label1));
												}
												else if( type1 == "string" )
												{
													appendCode("if ( " + string($<var.addr>1) + " !=s " + string($<var.addr>3) + " ) goto " + string(label1));
												}
												else if( type1[0] == '*' )
												{
													appendCode("if ( " + string($<var.addr>1) + " ==i " + string($<var.addr>3) + " ) goto " + string(label1));
												}

												appendCode(string($<var.addr>$) + " =b #false");
												appendCode("goto " + string(label2));
												appendCode(string(label1) + ":");
												appendCode(string($<var.addr>$) + " =b #true");
												appendCode(string(label2) + ":");	

												if( parseDebug == 1 )
												{
													cout << "eq_expr -> eq_expr != rel_expr" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
												appendCode("if ( " + string($<var.addr>1) + " ==b false ) goto " + string(label1));
												appendCode("if ( " + string($<var.addr>3) + " ==b false ) goto " + string(label1));
												appendCode(string($<var.addr>$) + " =b #true");
												char* label2 = getLabel();
												appendCode("goto " + string(label2));
												appendCode(string(label1) + ":");
												appendCode(string($<var.addr>$) + " =b #false");
												appendCode(string(label2) + ":");

												if( parseDebug == 1 )
												{
													cout << "logicaland -> logicaland && eq_expr" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
												$<var.addr>$ = getTemp("bool");
												$<var.type>$ = $<var.type>1;

												char* label1 = getLabel();
												//if either of them is true then the resul is true.
												appendCode("if ( " + string($<var.addr>1) + " == true ) goto " + string(label1));
												appendCode("if ( " + string($<var.addr>3) + " == true ) goto " + string(label1));
												appendCode(string($<var.addr>$) + " =b #false");
												char* label2 = getLabel();
												appendCode("goto " + string(label2));
												appendCode(string(label1) + ":");
												appendCode(string($<var.addr>$) + " =b #true");
												appendCode(string(label2) + ":");
												
												if( parseDebug == 1 )
												{
													cout << "logical_or -> logicalor || logicaland" << endl;
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;;
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
													cout << "$<var.addr>$ = " << string($<var.addr>$) << endl;
													cout << "$<var.type>$ = " << string($<var.type>$) << endl;
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
												appendCode(var + " =i " + val);
											}
											else if( ltype == "float" and rtype == "float" )
											{
												appendCode(var + " =f " + val);
											}
											else if( ltype == "string"  and rtype == "string" )
											{
												appendCode(var + " =s " + val);
											}
											else if( ltype == "char" and rtype == "char" )
											{
												appendCode(var + " =c " + val);
											}
											else if( ltype == "bool" and rtype == "bool" )
											{
												appendCode(var + " =b " + val);
											}
											else if( ltype == "float" and rtype == "int" )
											{
												char* t = getTemp("float");
												appendCode(string(t) + " =f " + "elevateToFloat ( " + val + " )");
												appendCode(var + " =f " + string(t));
											}
											else if( ltype[0] == '*' and rtype == "int" )
											{
												appendCode(var + " =i " + val);
											}
											else if( ltype == rtype )
											{
												appendCode(var + " =" + ltype + " " + val);
											}
											else
											{
												cout << "COMPILETIME ERROR: different operands type to '='" << endl;
												cout << "ltype = " << ltype << " rtype = " << rtype << endl;
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
												appendCode(var + " =i " + var + " % " + val);
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
													appendCode(var + " =i " + var + " " + op[0] + "i " +  val);
												}
												else if( type1 == "float" and type2 == "float" )
												{
													appendCode(var + " =f " + var + " " + op[0] + "f " +  val);
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
													appendCode(string(temp) + " = elevateToFloat ( " + val + " )");
													appendCode(var + " =f " + var + " " + op[0] + "f " +  string(temp));
												}
											}
										}
										else if( op[0] == '+' )
										{
											if( type1 == "int" and type2 == "int" )
											{
												appendCode(var + " =i " + var + " +i " +  val);
											}
											else if( type1 == "float" and type2 == "float" )
											{
												appendCode(var + " =f " + var + " +f " +  val);
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
												appendCode(string(temp) + " = elevateToFloat ( " + val + " )");
												appendCode(var + " =f " + var + " +f " +  string(temp));
											}
											else if( type1 == "string" and type2 == "string" )
											{
												string str(getTemp("string"));
												appendCode(str + " =s strcat " + var + " " +  val);
												appendCode(var + " =s " + str);
											}
											else if( type1 == "string" and type2 == "char" )
											{
												string str(getTemp("string"));
												appendCode(str + " =s strcatc " + var + " " +  val);
												appendCode(var + " =s " + str);
											}
											else if( type1 == "char" and type2 == "int" )
											{
												appendCode(var + " =c " + var + " +c " +  val);
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
		:	NEW type_name declarationlist	
											{
												if( parseDebug == 1 )
												{
													cout << "declaration expr -> NEW typename declarationlist" << endl;
												}
											}
			| type_name declarationlist
											{
												if( parseDebug == 1 )
												{
													cout << "declaration expr -> typename declarationlist" << endl;
												}
											}
			;
	
	declarationlist
			:	declaration ',' declarationlist		
			|	declaration
			;
	
	declaration
		:	stars IDENTIFIER						{
												//insert the variable into the symbol table entry.
												vector<string> levels;
												for( int i = 0 ; i < starsCount ; i++ )
												{
													dtype = "*" + dtype;
												}
												string var($<str>2);
												if( insertVariable(var, dtype, levels, newOrNot ) == -1 )
												{
													cout << "COMPILETIME ERROR: Redeclaration of an already existing variable" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												SymbolTableEntry ste = getVariable(var);
												//appendCode(dtype + " " + ste.name + "_" + to_string(ste.scope));
												
												if( parseDebug == 1 )
												{
													cout << "declaration -> identifier" << endl;
												}
											}
			| stars IDENTIFIER '=' expression		{
												//along with declaration, assign the variables with values.
												for( int i = 0 ; i < starsCount ; i++ )
												{
													dtype = "*" + dtype;
												}
												if( dtype != string($<var.type>4) )
												{
													cout << "COMPILETIME ERROR: cannot assign different variable types" << endl;
													cout << "At line : " << yylineno << endl;
													cout << "dtype = " << dtype << endl;
													cout << "string($<var.type>4) = " << string($<var.type>4) << endl;
													printSymbolTable();
													cout << TemporaryCode << endl;
													return -1;
												}
												vector<string> levels;
												string var($<str>2);
												if( insertVariable(var, dtype, levels, newOrNot) == -1 )
												{
													cout << "COMPILETIME ERROR: Redeclaration of an already existing variable" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
												SymbolTableEntry ste = getVariable( var);
												//appendCode(dtype + " " + ste.name + "_" + to_string(ste.scope)); 
												if( dtype == "int" )
												{
													appendCode(ste.name + "_" + to_string(ste.scope) + " =i " + string($<var.addr>4));
												}
												else if( dtype == "float" )
												{
													appendCode(ste.name + "_" + to_string(ste.scope) + " =f " + string($<var.addr>4));
												}
												else if( dtype == "bool" )
												{
													appendCode(ste.name + "_" + to_string(ste.scope) + " =b " + string($<var.addr>4));
												}
												else if( dtype == "char" )
												{
													appendCode(ste.name + "_" + to_string(ste.scope) + " =c " + string($<var.addr>4));
												}
												else if( dtype == "string" )
												{
													appendCode(ste.name + "_" + to_string(ste.scope) + " =s " + string($<var.addr>4));
												}
												
												if( parseDebug == 1 )
												{
													cout << "declaration -> identifier = expression" << endl;
												}
											}
			| stars IDENTIFIER 
							{
								declevels.clear();
							}
			brackets			
							{							
								string var($<str>2);
								string arrayInit = "array " + var + "_" + to_string(scopeStack.top()) + " " + to_string(getActualSize(dtype)) + " ";
								for( int i = 0 ; i < declevels.size() ; i++ )
								{
									string temp = "_" + var + "_" + to_string(scopeStack.top()) + "_" + to_string(i+1); 
									appendCode(temp + "_" + to_string(scopeStack.top()) + " =i " + declevels[i]);
									arrayInit += temp + "_" + to_string(scopeStack.top()) + " ";
									declevels[i] = temp;
								}
								appendCode(arrayInit);
								if( insertVariable(var, dtype, declevels, newOrNot) == -1 )
								{
									cout << "COMPILETIME ERROR: Redeclaration of an already existing variable" << endl;
									cout << "At line : " << yylineno << endl;
									return -1;
								}
								SymbolTableEntry ste = getVariable(var);
								
								if( parseDebug == 1 )
								{
									cout << "declaration -> identifier" << endl;
								}
							}
			;
	stars:
		'*' stars
						{
							if( parseDebug == 1 )
							{
								cout << "stars -> '*' stars" << endl;
							}
							starsCount++;
						}
		|
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

												appendCode("if ( " + expr + " !=b #true ) goto " + label1);
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
												appendCode("goto " + ifgoto.top());
												appendCode(string($<str>1) + ":");
											}
			'}'								
											{
												//free all the variables declared within the if block.
												scopeStack.pop();
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
												//same as above
												string expr($<var.addr>3);
												string label1 = getLabel();
												
												char* f = new char[label1.length()-1];
												strcpy(f, label1.c_str());
												$<str>1 = f;

												appendCode("if ( " + expr + " !=b #true ) goto " + label1);
											}
			'{' 
											{
												currentScope++;
												scopeStack.push(currentScope);
												$<intval>5 = scopeStack.top();
											}
								
			statement_list					{
												appendCode("goto " + ifgoto.top());
												appendCode(string($<str>1) + ":");
											}
			'}'
											{
												scopeStack.pop();
												if( symbolDebug == 1 )
												{
													printSymbolTable();
												}
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
												appendCode(ifgoto.top() + ":");
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
											}

			|								{
												appendCode(ifgoto.top() + ":");
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
			| RETURN expression ';'
								{
									string returnVal($<var.addr>2);
									appendCode("return " + returnVal);
									if( parseDebug == 1 )
									{
										cout << "statement -> return expression" << endl;
									}
								}
			| RETURN ';'
								{
									appendCode("return VOID");
									if( parseDebug == 1 )
									{
										cout << "statement -> return" << endl;
									}
								}
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
									appendCode("goto " + forNext.top());
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
									appendCode("goto " + forIncrement.top());
								}
							}
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
											appendCode("scan int " + name);
										}
										else if( string($<var.type>1) == "char" )
										{
											appendCode("scan char " + name);
										}
										else if( string($<var.type>1) == "float" )
										{
											appendCode("scan float " + name);
										}
										if( string($<var.type>1) == "string" )
										{
											appendCode("scan string " + name);
										}
									}	
			;

	print_statement
		:	PRINT '(' print_args ')'	
									{
										appendCode("print newline");
									}
			| PRINT '(' ')'
									{
										appendCode("print newline");
									}

			| PRINTS '(' print_args ')'
			;
	
	print_args
		:	expression ','		
										{
											//print the variables based on their types
											if( string($<var.type>1) == "int" )
											{
												appendCode("print int " + string($<var.addr>1));
											}
											else if( string($<var.type>1) == "char" )
											{
												appendCode("print char " + string($<var.addr>1));
											}
											else if( string($<var.type>1) == "float" )
											{
												appendCode("print float " + string($<var.addr>1));
											}
											else if( string($<var.type>1) == "string" )
											{
												appendCode("print string " + string($<var.addr>1));
											}
											else if( string($<var.type>1) == "bool" )
											{
												appendCode("print bool " + string($<var.addr>1));
											}
											else
											{
												cout << "COMPILETIME ERROR: Cannot print Expression of type " << string($<var.type>1) << endl;
												cout << "At Line " << yylineno << endl;
												return -1;
											}
										}
			print_args
			| expression
										{
											//same as above
											if( string($<var.type>1) == "int" )
											{
												appendCode("print int " + string($<var.addr>1));
											}
											else if( string($<var.type>1) == "char" )
											{
												appendCode("print char " + string($<var.addr>1));
											}
											else if( string($<var.type>1) == "float" )
											{
												appendCode("print float " + string($<var.addr>1));
											}
											else if( string($<var.type>1) == "string" )
											{
												appendCode("print string " + string($<var.addr>1));
											}
											else if( string($<var.type>1) == "bool" )
											{
												appendCode("print bool " + string($<var.addr>1));
											}
											else
											{
												cout << "COMPILETIME ERROR: Cannot print Expression of type " << string($<var.type>1) << endl;
												cout << "At Line " << yylineno << endl;
												return -1;
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
												appendCode(start + ":");

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
												appendCode("if ( " + expr + " !=b #true ) goto " + endfor);
												//else goto to the start of the code block of the for statement.
												appendCode("goto " + statementstart);
												appendCode(incrementstart + ":");
											}
			loop_increment_list 			{
												//after incrementing goto the start of the codition checking.
												appendCode("goto " + string($<str>1));
												appendCode(string($<str>4) + ":");
											}
			')' '{' statement_list 			{
												//after executing the block go to the increment part.
												appendCode("goto " + string($<var.addr>6));
												appendCode(string($<var.type>6) + ":");
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
		{
			currentStruct = "main";
			insertStruct(currentStruct);
		}
		blocks
		;

	blocks:
		block blocks
		| 
		;
	
	block:
		functionPrefix
		| struct_declaration
		;

	struct_declaration:
		VAR IDENTIFIER 
						{
						}
		'{' 
						{
							string structName = string($<str>2);
							insertStruct( structName );
							currentStruct = structName;
							currentScope++;
							scopeStack.push(currentScope); 
						}
		attributes 
						{
						}
		'}'
						{
							scopeStack.pop();
							currentStruct = "main";
							if( parseDebug == 1 )
							{
								cout << "struct _declaration -> var identifier '{' attributes '}'" << endl;
							}
						}
		;

	attributes:
		functionPrefix attributes
						{
							if( parseDebug == 1 )
							{
								cout << "attributes -> functionPrefix attributes" << endl;
							}
						}
		| attribute attributes
						{
							if( parseDebug == 1 )
							{
								cout << "attributes -> attribute attributes" << endl;
							}
						}
		|
		;
	
	attribute:
		type_name stars IDENTIFIER 
									{
										dlevels = 0;
										
									}
		dimensions ';'
									{
										vector<string> levels;
										for( int i = 0 ; i < starsCount ; i++ )
										{
											dtype = "*" + dtype;
										}
										for( int i = 1 ; i <= dlevels; i++ )
										{
											levels.push_back(string($<str>3) + "_" + to_string(scopeStack.top()) + "_" + to_string(i));
										}
										int res = insertAttribute( currentStruct, string($<str>3), dtype, levels);
										if( res == -2 )
										{	
											cout << "COMPILETIME ERROR: Attribute with the given name already exists" << endl;
											return -1;
										}
										else if( res == -1 )
										{
											cout << "COMPILETIME ERROR: Attribute declaration prohibited" << endl;
										}
										if( parseDebug == 1 )
										{
											cout << "attribute -> typename stars identifier dimensions" << endl;
										}
									}
		;
	
	dimensions:
		'['']' dimensions	
							{
								dlevels++;
							}
		|
		;

	functionPrefix:
		VOID MAIN '(' ')'
												{
													int res = insertFunction(currentStruct, "void", "main");
													if( res == -2 )
													{
														cout << "COMPILETIME ERROR: " << "Redefinition of the function main" << endl;
														return -1;
													}
													else if( res == -1 )
													{
														cout << "COMPILETIME ERROR: " << "Function Declaration prohibited" << endl;
														return -1;
													}
													currentFunction = "main";

													string label = getLabel();
													appendCode(label + ":");
													setLabel(currentFunction, label);
													appendCode("function start " + currentStruct + "." + currentFunction);
													appendCode("setReturn");
													if( parseDebug == 1 )
													{
														cout << "function -> void main" << endl;
													}
												}
		statement_block							
												{
													appendCode("return");
												}
		| VOID IDENTIFIER '('
												{
													string fname = string($<str>2);
													int res = insertFunction(currentStruct, "void", fname);
													if( res == -2 )
													{
														cout << "COMPILETIME ERROR: " << "Redefinition of the function " << fname << endl;
														return -1;
													}
													else if( res == -1 )
													{
														cout << "COMPILETIME ERROR: " << "Function Declaration prohibited" << endl;
														return -1;
													}
													currentFunction = fname;
													currentScope++;
													scopeStack.push(currentScope);
												}
		functionSuffix
		| type_name stars IDENTIFIER '('
												{
													for( int i = 0 ; i < starsCount ; i++ )
													{
														dtype = "*" + dtype;
													}
													string fname = string($<str>3);
													int res = insertFunction(currentStruct, dtype, fname);
													if( res == -2 )
													{
														cout << "COMPILETIME ERROR: " << "Redefinition of the function " << fname << endl;
														return -1;
													}
													else if( res == -1 )
													{
														cout << "COMPILETIME ERROR: " << "Function Declaration prohibited" << endl;
														return -1;
													}
													currentFunction = fname;
													currentScope++;
													scopeStack.push(currentScope);
												}
		functionSuffix
		;
	functionSuffix:
		functionArguements ')'
												{
													currentScope--;
													scopeStack.pop();
													string label = getLabel();
													appendCode(label + ":");
													setLabel(currentFunction, label);
													appendCode("function start " + currentStruct + "." + currentFunction);
													appendCode("setReturn");
												}
		statement_block							
												{
													appendCode("return");
												}
		| ')'									
												{
													currentScope--;
													scopeStack.pop();
													string label = getLabel();
													appendCode(label + ":");
													setLabel(currentFunction, label);
													appendCode("function start " + currentStruct + "." + currentFunction);
													appendCode("setReturn");
												}
		statement_block							
												{
													appendCode("return");
												}
		;

	functionArguements:
		type_name IDENTIFIER
											{
												vector<string> levels;
												string var($<str>2);
												int r = insertParam( var, dtype, levels );
												if( insertParam(var, dtype, levels) == -1 )
												{
													cout << "COMPILETIME ERROR: Redeclaration of an already existing variable" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
											}
		| functionArguements ',' type_name IDENTIFIER
											{
												vector<string> levels;
												string var($<str>4);
												if( insertParam(var, dtype, levels) == -1 )
												{
													cout << "COMPILETIME ERROR: Redeclaration of an already existing variable" << endl;
													cout << "At line : " << yylineno << endl;
													return -1;
												}
											}
		;

	statement_block
		:	'{' 						{
											currentScope++;
											scopeStack.push(currentScope);
											$<intval>1 = scopeStack.top();
										}
			statement_list	'}'			{
											//release the variables.
											scopeStack.pop();
											if( symbolDebug == 1 )
											{
													printSymbolTable();
											}
											if( parseDebug == 1 )
											{
												cout << "statement_block -> { statementlist }" << endl;
											}
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

	if( i != 0 )
	{
		return 0;
	}
	
	cout << "Successfully Completed Compiling" << endl;
	string file = "file.temp";
	ofstream Myfile(file);

	string functionFrame = getFunctionFrame();
	bool b = checkMain();
	if( b == false )
	{
		cout << "Main function is not declared" << endl;
		return 1;
	}
	functionFrame += "code starts\nfunCall main.main\ncall " + getFunctionLabel("main", "main") + "\nexit\n";
	TemporaryCode = functionFrame + TemporaryCode;

	//printSymbolTable();
	Myfile << TemporaryCode;
	Myfile.close();
	return 0;
}
