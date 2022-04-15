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

string TemporaryCode = "";
string functionFrame = "";
vector<string> declevels;
string dtype;
stack<string> ifgoto;
string forExprVal;
int tempint = 1;
stack<string> forIncrement;
stack<string> forNext;
int labelint = 1;
int currentScope = 0;
stack<int> scopeStack;
vector<pair<string, vector<symbolTableEntry>>> functionSymbolTable;
vector<symbolTableEntry> currentSymbolTable;
string currentFunctionName = "";

//returns the name of a new temp variable, and also declares it as a variable in the temp code.
char* getTemp( string type )
{
	string temp = "_t" + to_string(tempint);
	char* t = (char*) malloc((temp.length()-1)*sizeof(char));
	strcpy(t, temp.c_str());
	tempint++;		//increment tempint so that next time new temp variable is created.
	//appendCode(type + " " + temp);		//add the declaration
	return t;
}

//this one does the same thing except that it does not declare the variable.
char* getTemp()
{
	string temp = "_t" + to_string(tempint);
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

int insertFunction( string returnType, string functionName )
{
	for( int i = 0 ; i < functionSymbolTable.size() ; i++ )
	{
		if( functionSymbolTable[i].first == functionName )
		{
			return -1;
		}
	}
	vector<symbolTableEntry>* entry = new vector<symbolTableEntry>;
	
	symbolTableEntry ste;

	ste.name = "_" + functionName;
	ste.dataType = returnType;
	if( ste.dataType == "char" )
	{
		ste.size = 1;
	}
	else {
		ste.size = 4;
	}
	ste.scope = 0;
	//ste.scope = scopeStack.top();
	ste.array = 0;

	(*entry).push_back(ste);

	pair<string, vector<symbolTableEntry>> functionSymbolTableEntry = make_pair(functionName, *entry);
	functionSymbolTable.push_back(functionSymbolTableEntry);
	currentFunctionName = functionName;
	return 1;
} 
//insert a new entry.
//return -1 if the symbolTable with given function name is not found
//return -2 if the variable with the same name already exists in the given scope.
int insertEntry( string variableName, string dataType , vector<string> levels, bool array)
{
	for( int i = 0 ; i < currentSymbolTable.size() ; i++ )
	{
		if( currentSymbolTable[i].name == variableName and currentSymbolTable[i].scope == currentScope )
		{
			return -2;		//if a variable with the same name and scope already exists, then return -1.
		}
	}
	symbolTableEntry ste;

	ste.name = variableName;
	ste.dataType = dataType;
	if( ste.dataType == "char" )
	{
		ste.size = 1;
	}
	else
	{
		ste.size = 4;
	}
	ste.scope = 0;		//the top of the stack contains the current scope 
	ste.scope = scopeStack.top();
	ste.levels = levels; 
	ste.array = array; 
	currentSymbolTable.push_back(ste);
	return 0;					//on success return 0.
}

//a debugging tool to print the symbol table.
void printSymbolTable()
{
	for( int i = 0 ; i < functionSymbolTable.size() ; i++ )
	{
		cout << "Function = " << functionSymbolTable[i].first << endl;
		cout << "name\tdatatype\tscope\tsize\tarray\tlevels" << endl;

		vector<symbolTableEntry> table = functionSymbolTable[i].second;
		for( int i = 0 ; i < table.size() ; i++ )
		{
			cout << table[i].name << "\t" << table[i].dataType << "\t\t" << table[i].scope << "\t" << table[i].size << "\t" << table[i].array << "\t";
			for( int j = 0 ; j < table[i].levels.size() ; j++ )
			{
				cout << table[i].levels[j] << " ";
			}
			cout << endl;
		}
		cout << endl;
	}
}

symbolTableEntry getEntry( string name )
{
	symbolTableEntry res;
	bool b = true;
	int scope = 0;

	for( int i = 0 ; i < currentSymbolTable.size() ; i++ )
	{
		if( currentSymbolTable[i].name == name  )
		{
			if( b )
			{
				res = currentSymbolTable[i];
				b = false;
			}
			else
			{
				//if an entry with higher scope exists then return it, when referring we always return the most local one.
				if( currentSymbolTable[i].scope > res.scope )
				{
					res = currentSymbolTable[i];
				}
			}
		}
	}
	return res;
}

symbolTableEntry getFunctionReturnAddress( string functionName )
{
	symbolTableEntry res;

	for( int i = 0 ; i < functionSymbolTable.size() ; i++ )
	{
		if( functionSymbolTable[i].first == functionName )
		{
			res = functionSymbolTable[i].second[0];
			break;
		}
	}
	return res;
}

//appends statement to TempCode
void appendCode( string statement )
{
	TemporaryCode += statement + "\n";
}

void appendFunctionFrame( string str )
{
	functionFrame += str + "\n";
}

void insertCurrentSymbolTable()
{
	appendFunctionFrame( "function " + functionSymbolTable[functionSymbolTable.size()-1].first );
	appendFunctionFrame( functionSymbolTable[functionSymbolTable.size()-1].second[0].dataType + " " + functionSymbolTable[functionSymbolTable.size()-1].second[0].name);
	for( int i = 0 ; i < currentSymbolTable.size() ; i++ )
	{
		string code = currentSymbolTable[i].dataType + " " + currentSymbolTable[i].name  + "_" + to_string(currentSymbolTable[i].scope) + " ";
		for( int j = 0 ; j < currentSymbolTable[i].levels.size() ; j++ )
		{
			code += currentSymbolTable[i].levels[j] + " " ;
		}
		appendFunctionFrame(code);
		functionSymbolTable[functionSymbolTable.size()-1].second.push_back(currentSymbolTable[i]);
	}
	appendFunctionFrame("");
	currentSymbolTable.clear();
	return;
}
