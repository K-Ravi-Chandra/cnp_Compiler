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
int dlevels;
stack<string> ifgoto;
string forExprVal;
int tempint = 1;
int strConstInt = 1;
stack<string> forIncrement;
stack<string> forNext;
int labelint = 1;
string currentStruct;
string currentFunction;
int currentScope = 0;
int starsCount = 0;
bool newOrNot = false;
stack<int> scopeStack;
stack<SymbolTableEntry> callStack;


//returns the name of a new temp variable, and also declares it as a variable in the temp code.
char* getTemp( string type )
{
	string temp = "_t" + to_string(tempint);
	vector<string> levels;
	insertVariable(temp, type, levels, false);
	temp += "_" + to_string(scopeStack.top());
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
	vector<string> levels;
	insertVariable(temp, "int", levels, false);
	temp += "_" + to_string(scopeStack.top());
	char* t = (char*) malloc((temp.length()-1)*sizeof(char));
	strcpy(t, temp.c_str());
	tempint++;
	return t;
}

string getStringConst()
{
	string temp = "_s" + to_string(strConstInt);
	strConstInt++;
	return temp;
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


vector<StructTable> globalTable;


int getSize( string dataType )
{
	int size = 0;
	if( dataType == "char" )
	{
		size = 1;
	}
	else if( dataType == "int" )
	{
		size = 4;
	}
	else if( dataType == "string" )
	{
		size = 4;
	}
	else if( dataType == "bool" )
	{
		size = 1;
	}
	else if( dataType == "float" )
	{
		size = 4;
	}
	else
	{
		for( int i = 0 ; i < globalTable.size() ; i++ )
		{
			if( globalTable[i].structName == dataType )
			{
				vector<SymbolTableEntry> table = globalTable[i].attributes;
				for( int j = 0 ; j < table.size() ; j++ )
				{
					size += getSize(table[j].dataType);
				}
			}
		}
	}
	return size;
}

void printSymbolTable()
{
	cout << "Printing Symbol Table:" << endl;
	cout << endl;
	for( int i = 0 ; i < globalTable.size() ; i++ )
	{
		cout << "StructName = " << globalTable[i].structName << endl;
		cout << "Attributes = " << endl;
		cout << "name\tdatatype\tscope\tsize\tglobal\tlevels" << endl;

		vector<SymbolTableEntry> table = globalTable[i].attributes;
		for( int j = 0 ; j < table.size() ; j++ )
		{
			cout << table[j].name << "\t" << table[j].dataType << "\t\t" << table[j].scope << "\t" << table[j].size << "\t" << table[j].global << "\t";
			for( int k = 0 ; k < table[j].levels.size() ; k++ )
			{
				cout << table[j].levels[k] << " ";
			}
			cout << endl;
		}
		cout << endl;
		cout << "Functions" << endl;

		vector<FunctionTable> functionTable = globalTable[i].functions;
		for( int f = 0 ; f < functionTable.size() ; f++ )
		{
			cout << "Function = " << functionTable[f].functionName << endl;
			cout << "Parameters = " << endl;

			table = functionTable[f].parameters;
			for( int j = 0 ; j < table.size() ; j++ )
			{
				cout << table[j].name << "\t" << table[j].dataType << "\t\t" << table[j].scope << "\t" << table[j].size << "\t" << table[j].global << "\t";
				for( int k = 0 ; k < table[j].levels.size() ; k++ )
				{
					cout << table[j].levels[k] << " ";
				}
				cout << endl;
			}
			cout << endl;

			cout << "Variables = " << endl;
			table = functionTable[f].table;
			for( int j = 0 ; j < table.size() ; j++ )
			{
				cout << table[j].name << "\t" << table[j].dataType << "\t\t" << table[j].scope << "\t" << table[j].size << "\t" << table[j].global << "\t";
				for( int k = 0 ; k < table[j].levels.size() ; k++ )
				{
					cout << table[j].levels[k] << " ";
				}
				cout << endl;
			}
			cout << endl;
			cout << "return = " << endl;

			cout << functionTable[f].returnValue.name << "\t" << functionTable[f].returnValue.dataType << "\t\t" << functionTable[f].returnValue.scope << "\t" << functionTable[f].returnValue.size << "\t" << functionTable[f].returnValue.global << "\t";

			for( int k = 0 ; k < functionTable[f].returnValue.levels.size() ; k++ )
			{
				cout << functionTable[f].returnValue.levels[k] << " ";
			}
			cout << endl;
			cout << "label = " << functionTable[f].label << endl;
			cout << endl;
		}
	}
}

StructTable::StructTable( string name )
{
	structName = name;
	vector<SymbolTableEntry>* attr = new vector<SymbolTableEntry>;
	attributes = *attr;
	vector<FunctionTable>* func = new vector<FunctionTable>;
	functions = *func;
}

StructTable::StructTable()
{
}

FunctionTable::FunctionTable( string name, string rType )
{
	functionName = name;

	SymbolTableEntry* ste = new SymbolTableEntry();

	(*ste).name = "_" + name;

	(*ste).dataType = rType;
	(*ste).size = getSize(rType);
	if( scopeStack.size() == 0 )
	{
		(*ste).scope = 0;
	}
	else
	{
		(*ste).scope = scopeStack.top();
	}

	returnValue = (*ste);

	vector<SymbolTableEntry>* param = new vector<SymbolTableEntry>;
	parameters = *param;

	vector<SymbolTableEntry>* t = new vector<SymbolTableEntry>;
	table = *t;
}

FunctionTable::FunctionTable()
{
}

int insertStruct( string structName )
{
	StructTable* table = new StructTable( structName );
	globalTable.push_back(*table);
	return 1;
}

int insertAttribute( string structName, string variableName, string dataType, vector<string> levels)
{
	SymbolTableEntry* ste = new SymbolTableEntry();
	for( int i = 0 ; i < globalTable.size() ; i++ )
	{
		if( globalTable[i].structName == structName )
		{
			vector<SymbolTableEntry> table = globalTable[i].attributes;
			for( int j = 0 ; j < table.size() ; j++ )
			{
				if( table[j].name == variableName and table[j].scope == currentScope )
				{
					return -2;
				}
			}
			(*ste).name = variableName;
			(*ste).dataType = dataType;
			(*ste).size = getSize(dataType);
			(*ste).levels = levels;
			if( scopeStack.size() == 0 )
			{
				(*ste).scope = 0;
			}
			else
			{
				(*ste).scope = scopeStack.top();
			}
			globalTable[i].attributes.push_back(*ste);
			return 1;
		}
	}
	return -1;
}

int insertFunction( string structName, string returnType, string functionName )
{
	for( int i = 0 ; i < globalTable.size() ; i++ )
	{
		if( globalTable[i].structName == structName )
		{
			vector<FunctionTable> table = globalTable[i].functions;
			for( int j = 0 ; j < table.size() ; j++ )
			{
				if( table[j].functionName == functionName )
				{
					return -2;
				}
			}
			FunctionTable* func = new FunctionTable(functionName, returnType );
			globalTable[i].functions.push_back(*func);
			if( structName != "main" )
			{
				vector<string> levels;
				insertParam( structName, functionName, "this", structName, levels);
			}
			return 1;
		}
	}
	return -1;
}

int insertParam( string structName, string functionName, string variableName, string dataType, vector<string> levels )
{
	for( int i = 0 ; i < globalTable.size() ; i++ )
	{
		if( globalTable[i].structName == structName )
		{
			vector<FunctionTable> table = globalTable[i].functions;
			for( int j = 0 ; j < table.size() ; j++ )
			{
				if( table[j].functionName == functionName )
				{
					vector<SymbolTableEntry> param = table[j].parameters;
					for( int k = 0 ; k < param.size() ; k++ )
					{
						if( param[k].name == variableName and param[k].scope == currentScope )
						{
							return -3;
						} 
					}
					SymbolTableEntry* ste = new SymbolTableEntry();

					(*ste).name = variableName;
					(*ste).dataType = dataType;
					(*ste).size = getSize(dataType);
					(*ste).levels = levels;
					if( scopeStack.size() == 0 )
					{
						(*ste).scope = 0;
					}
					else
					{
						(*ste).scope = scopeStack.top();
					}
					globalTable[i].functions[j].parameters.push_back(*ste);
					insertVariable( structName, functionName, variableName, dataType, levels, false);
					return 1;
				}
			}
			return -2;
		}
	}
	return - 1;
}

int insertVariable( string structName, string functionName, string variableName, string dataType, vector<string> levels, bool global )
{
	for( int i = 0 ; i < globalTable.size() ; i++ )
	{
		if( globalTable[i].structName == structName )
		{
			vector<FunctionTable> table = globalTable[i].functions;
			for( int j = 0 ; j < table.size() ; j++ )
			{
				if( table[j].functionName == functionName )
				{
					vector<SymbolTableEntry> param = table[j].table;
					for( int k = 0 ; k < param.size() ; k++ )
					{
						if( param[k].name == variableName and param[k].scope == currentScope )
						{
							return -3;
						} }
					SymbolTableEntry* ste = new SymbolTableEntry();

					(*ste).name = variableName;
					(*ste).dataType = dataType;
					(*ste).size = getSize(dataType);
					(*ste).levels = levels;
					(*ste).global = global;
					if( scopeStack.size() == 0 )
					{
						(*ste).scope = 0;
					}
					else
					{
						(*ste).scope = scopeStack.top();
					}
					globalTable[i].functions[j].table.push_back(*ste);
					return 1;
				}
			}
			return -2;
		}
	}
	return - 1;
}

/*
 */
int insertFunction( string returnType, string functionName )
{
	return insertFunction( currentStruct,  returnType, functionName );
}

int insertParam( string variableName, string dataType, vector<string> levels )
{
	return insertParam( currentStruct, currentFunction, variableName, dataType, levels ); 
}

int insertVariable( string variableName, string dataType, vector<string> levels, bool global )
{
	return insertVariable( currentStruct, currentFunction, variableName, dataType, levels , global);
}

SymbolTableEntry getStructAttribute( string structName, string variableName ) 
{ 
	SymbolTableEntry ste;
	for( int i = 0 ; i < globalTable.size() ; i++ )
	{
		if( globalTable[i].structName == structName )
		{
			vector<SymbolTableEntry> table = globalTable[i].attributes;
			for( int j = 0 ; j < table.size() ; j++ )
			{
				if( table[j].name == variableName )
				{ 
					ste = table[j];
				}
			}
		}
	}
	return ste;
}

FunctionTable getStructFunction( string structName, string functionName )
{
	FunctionTable funcTable;
	for( int i = 0 ; i < globalTable.size() ; i++ )
	{
		if( globalTable[i].structName == structName )
		{
			vector<FunctionTable> table = globalTable[i].functions;
			for( int j = 0 ; j < table.size() ; j++ )
			{
				if( table[j].functionName == functionName )
				{ 
					funcTable = table[j];
				}
			}
		}
	}
	return funcTable;
}

SymbolTableEntry getFunctionReturnAddress( string structName, string functionName )
{
	FunctionTable tab = getStructFunction( structName , functionName );
	return tab.returnValue;
}

SymbolTableEntry  getVariable( string structName, string functionName, string variableName )
{
	if( variableName.substr(0, 5) == "this." )
	{
		variableName = variableName.substr(5, variableName.size());
	}
	SymbolTableEntry ste;
	for( int i = 0 ; i < globalTable.size() ; i++ )
	{
		if( globalTable[i].structName == structName )
		{
			vector<FunctionTable> table = globalTable[i].functions;
			for( int j = 0 ; j < table.size() ; j++ )
			{
				if( table[j].functionName == functionName )
				{ 
					vector<SymbolTableEntry> tab = table[j].table;

					bool b = true;
					int scope = 0;

					for( int k = 0 ; k < tab.size() ; k++ )
					{
						if( tab[k].name == variableName )
						{
							if( b )
							{
								stack<int> sk;
								while( !scopeStack.empty() )
								{
									int n = scopeStack.top();
									if( tab[k].scope == n )
									{
										ste = tab[k];
									}
									scopeStack.pop();
									sk.push(n);
								}

								while( !sk.empty() )
								{
									int n = sk.top();
									sk.pop();
									scopeStack.push(n);
								}
								b = false;
							}
							else
							{
								if( tab[k].scope > ste.scope )
								{
									stack<int> sk;
									while( !scopeStack.empty() )
									{
										int n = scopeStack.top();
										if( tab[k].scope == n )
										{
											ste = tab[k];
										}
										scopeStack.pop();
										sk.push(n);
									}

									while( !sk.empty() )
									{
										int n = sk.top();
										sk.pop();
										scopeStack.push(n);
									}
								}
							}
						}
					}
				}
			}
			if( ste.name == "" )
			{
				vector<SymbolTableEntry> tab = globalTable[i].attributes;
				for( int k = 0 ; k < tab.size() ; k++ )
				{
					if( tab[k].name == variableName )
					{
						ste = tab[k];
						ste.name = "this." + ste.name;
					}
				}
			}
		}
	}
	return ste;
}

SymbolTableEntry  getVariable( string variableName )
{
	return getVariable( currentStruct, currentFunction, variableName );
}

void appendCode( string statement )
{
	TemporaryCode += statement + "\n";
}

string getFunctionFrame()
{
	string res = "";

	for( int i = 0 ; i < globalTable.size() ; i++ )
	{
		res += "struct start " + globalTable[i].structName + "\n\n";

		vector<SymbolTableEntry> table = globalTable[i].attributes;
		for( int j = 0 ; j < table.size() ; j++ )
		{
			res += table[j].dataType + " " + to_string(table[j].size) + " " + table[j].name + "_" + to_string(table[j].scope) + " ";
			for( int k = 0 ; k < table[j].levels.size() ; k++ )
			{
				res += table[j].levels[k] + " ";
			}
			res += "\n";
		}

		vector<FunctionTable> functionTable = globalTable[i].functions;
		for( int f = 0 ; f < functionTable.size() ; f++ )
		{
			res += "function start " + functionTable[f].functionName + "\n\n";

			res += functionTable[f].returnValue.dataType + " " + to_string(functionTable[f].returnValue.size) + " " + functionTable[f].returnValue.name + "_" + to_string(functionTable[f].returnValue.scope) + " ";

			for( int k = 0 ; k < functionTable[f].returnValue.levels.size() ; k++ )
			{
				res += functionTable[f].returnValue.levels[k] + " ";
			}
			res += "\n";

			table = functionTable[f].parameters;
			res += "param start\n";
			for( int j = 0 ; j < table.size() ; j++ )
			{
				res += table[j].dataType + " " + to_string(table[j].size) + " " + table[j].name + "_" + to_string(table[j].scope) + " ";
				for( int k = 0 ; k < table[j].levels.size() ; k++ )
				{
					res += table[j].levels[k] + " ";
				}
				res += "\n";
			}
			res += "param end\n";

			table = functionTable[f].table;
			for( int j = 0 ; j < table.size() ; j++ )
			{
				res += table[j].dataType + " " + to_string(table[j].size) + " " + table[j].name + "_" + to_string(table[j].scope) + " " + to_string(table[j].global) + " ";
				for( int k = 0 ; k < table[j].levels.size() ; k++ )
				{
					res += table[j].levels[k] + " ";
				}
				res += "\n";
			}
			res += "\nfunction end\n";
		}
		res += "\nstruct end\n\n";
	}
	return res;
}

int setLabel( string functionName, string label )
{
	for( int i = 0 ; i < globalTable.size() ; i++ )
	{
		if( globalTable[i].structName == currentStruct )
		{
			vector<FunctionTable> table = globalTable[i].functions;
			for( int j = 0 ; j < table.size() ; j++ )
			{
				if( table[j].functionName == functionName )
				{ 
					globalTable[i].functions[j].label = label;
					return 1;
				}
			}
		}
	}
	return -1;
}

string getFunctionLabel( string structName, string functionName )
{
	string label = "";
	for( int i = 0 ; i < globalTable.size() ; i++ )
	{
		if( globalTable[i].structName == structName )
		{
			vector<FunctionTable> table = globalTable[i].functions;
			for( int j = 0 ; j < table.size() ; j++ )
			{
				if( table[j].functionName == functionName )
				{ 
					label = table[j].label;
				}
			}
		}
	}
	return label;
}

void setCallStack( string structName, string functionName )
{
	while( !callStack.empty() )
	{
		callStack.pop();
	}
	for( int i = 0 ; i < globalTable.size() ; i++ )
	{
		if( globalTable[i].structName == structName )
		{
			vector<FunctionTable> table = globalTable[i].functions;
			for( int j = 0 ; j < table.size() ; j++ )
			{
				if( table[j].functionName == functionName )
				{ 
					for( int k = table[j].parameters.size()-1 ; k >= 0  ; k-- )
					{
						callStack.push(table[j].parameters[k]);
					}
				}
			}
		}
	}
	return;
}

bool checkMain()
{
	for( int i = 0 ; i < globalTable.size() ; i++ )
	{
		if( globalTable[i].structName == "main" )
		{
			vector<FunctionTable> table = globalTable[i].functions;
			for( int j = 0 ; j < table.size() ; j++ )
			{
				if( table[j].functionName == "main" )
				{ 
					return true;
				}
			}
		}
	}
	return false;
}


/*
   int main()
   {
   int r = insertStruct( "complex" );
   cout << "insert struct returned = " << r << endl;
   vector<string> levels;
   r = insertAttribute( "complex", "real", "int", levels );
   cout << "insert attribute  returned = " << r  << endl;

   r = insertAttribute( "complex" , "complex", "int", levels );
   cout << "insert attribute returned = " << r << endl;


   r = insertFunction( "complex", "complex", "sum");
   cout << "insert funtion returned = " << r << endl;

   r = insertParam( "complex", "sum", "c1", "complex", levels );
   cout << "insert param returned = " << r << endl;

   r = insertParam( "complex", "sum", "c2", "complex", levels );
   cout << "insert param returned = " << r << endl;

   r = insertVariable( "complex", "sum", "temp1", "complex", levels );
   cout << "insert Variable returned = " << r << endl;

   r = insertVariable( "complex", "sum", "temp2", "complex", levels );
   cout << "insert Variable returned = " << r << endl;

   r = insertVariable( "complex", "sum", "sum", "complex", levels );
   cout << "insert Variable returned = " << r << endl;


   r = insertStruct( "node" );
   cout << "insert struct returned = " << r << endl;
   r = insertAttribute( "node", "real", "int", levels );
   cout << "insert attribute  returned = " << r  << endl;

   r = insertAttribute( "node" , "complex", "int", levels );
   cout << "insert attribute returned = " << r << endl;


   r = insertFunction( "node", "complex", "sum");
   cout << "insert funtion returned = " << r << endl;

   r = insertFunction( "n", "complex", "sub");
   cout << "insert funtion returned = " << r << endl;

   r = insertParam( "node", "sum", "c1", "complex", levels );
   cout << "insert param returned = " << r << endl;

   r = insertParam( "node", "sum", "c2", "complex", levels );
   cout << "insert param returned = " << r << endl;

   r = insertVariable( "node", "sum", "temp1", "complex", levels );
   cout << "insert Variable returned = " << r << endl;

   r = insertVariable( "node", "sum", "temp2", "complex", levels );
   cout << "insert Variable returned = " << r << endl;

   r = insertVariable( "node", "sum", "sum", "complex", levels );
   cout << "insert Variable returned = " << r << endl;

   printSymbolTable();
   return 0;
   }

 */
/*
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

void insertStruct(string structName)
{

}
*/
