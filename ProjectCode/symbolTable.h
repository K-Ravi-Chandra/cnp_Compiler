#include<string.h>
#include<iostream>
#include<unordered_map>
#include<vector>
#include<stack>
#include<utility>
#include<unistd.h>
using namespace std;

//this string contains the entire temporary code, we generate the temporary code in incremental fashion.
extern string TemporaryCode;

extern string functionFrame;
//All these below variables are global variables required because of the bottom-up parsing nature of yacc 
//parser.( we require at some places for the information to pass from top to bottom ).

//this variable is used to keep count the number of dimensions of the declared array while declaring.
extern vector<string> declevels;

//this variable stores the type of variable declared.
extern string dtype;

//this stack contains the goto address after executing one of the if blocks.
extern stack<string> ifgoto;

//this is used to store the variable that contains the address for loop expression 
extern string forExprVal;

//temporary variables are of the form "t_{tempint}". for example: t_1, t_22, tempint stores the numeber.
extern int tempint;

//this stack contains the list of addresses of start of the increment part of the for expression.
//this is used when we encounter a continue statement.( we goto the address of the top of the stack).
extern stack<string> forIncrement;

//this stack contains the list of addresses of start of the code following the for expression.
//this is used when we encounter a break statement.( we goto the address of the top of the stack). 
extern stack<string> forNext;

//labels are of the form "label{labelint}". for example: label1, lable30, labelint stores the number.
extern int labelint;

extern string currentFunctionName;



char* getTemp( string type );
char* getTemp();
char* getLabel();

//contains the current scope.
extern int currentScope;

//contains the heirarchy of scopes the current variable is in.( More detailed explanation about the scopes
//is presented in the documentation.
extern stack<int> scopeStack;

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
};

//Symbol table( list of symboltable entries.)
extern vector<symbolTableEntry> symbolTable;		

extern vector<symbolTableEntry> currentSymbolTable;

extern vector<pair<string, vector<symbolTableEntry>>> functionSymbolTable;

//insert a new entry.
int insertEntry( string variableName, string dataType , vector<string> levels, bool array);

int insertFunction( string returnType, string functionName );

//a debugging tool to print the symbol table.
void printSymbolTable();

/*
//remove an entry from the table.
int deleteEntry( string name, int scope );

//delete all entries in the given scope
int deleteEntries( int scope );
*/

//returns the symbol table entry with the given name, if there are multiple entries then return the entry
//that has the highest scope.
symbolTableEntry getEntry(string name );

//appends statement to TempCode
void appendCode( string statement );

void insertCurrentSymbolTable();

symbolTableEntry getFunctionReturnAddress(string functionName);
