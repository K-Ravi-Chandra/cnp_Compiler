#include<string.h>
#include<iostream>
#include<vector>
#include <fstream>
using namespace std;

string code = ".text \n.globl main \nmain:\n";
void appendCode(string s)
{
	code += s + "\n";
}
int main()
{
	string def = ".data\n";

	int looplabel = 1;

	fstream file;
	file.open("file.temp", ios::in);

	bool startCode = false;

	if( file.is_open() )
	{
		string s;
		vector<string> var;
		while( getline(file, s) )
		{
			if( s == "" )
			{
				continue;
			}
			char s1[s.size()+1];
			strcpy(s1, s.c_str());
			char* token = strtok(s1, " ");
			vector<string> tokens;
			while( token != NULL )
			{
				tokens.push_back(token);
				token = strtok(NULL, " ");
			}

			if( tokens[0] == "code" and tokens[1] == "starts" )
			{
				startCode = true;
			}
			if( startCode == false )
			{
				continue;
			}

			if( tokens[0].substr(tokens[0].size()-1, tokens[0].size()) == ":" )
			{
				string lname = tokens[0];
				appendCode(lname);
			}
			else if( tokens[0] == "goto" )
			{
				string gotolabel = tokens[1];
				appendCode( "j " + gotolabel);
			}
			else if( tokens[0] == "if" )
			{
				string lval = tokens[2];
				string c_op = tokens[3];
				string rval = tokens[4];
				string goto_label = tokens[7];
				string reg1 = "$8";
				string reg2 = "$9";

				if( c_op == "==b" or c_op == "!=b" )
				{
					appendCode("lw " + reg1 + ", " + lval);
					if( c_op == "==b" )
					{
						if( rval == "#true" )
						{
							appendCode("bnez " + reg1 + ", " + goto_label);
						}
						else if( rval == "#false" )
						{
							appendCode("beqz " + reg1 + ", " + goto_label);
						}
					}
					else if( c_op == "!=b" )
					{
						if( rval == "#true" )
						{
							appendCode("beqz " + reg1 + ", " + goto_label);
						}
						else if( rval == "#false" )
						{
							appendCode("bnez " + reg1 + ", " + goto_label);
						}
					}
				}
				if(c_op.substr(c_op.size()-1, c_op.size()) == "i")
				{
					if(lval[0] == '#')
					{
						appendCode("li "+reg1+", "+lval.substr(1, lval.length()));
					}
					else if(lval[0] == '*' )
					{
						appendCode("lw "+reg1+", "+lval.substr(1, lval.length()));
						appendCode("lw "+reg1+", "+"("+reg1+")");
					}
					else
					{
						appendCode("lw "+reg1+", "+lval);
					}

					if(rval[0] == '#')
					{
						appendCode("li "+reg2+", "+rval.substr(1, rval.length()));
					}
					else if(rval[0] == '*' )
					{
						appendCode("lw "+reg2+", "+rval.substr(1, rval.length()));
						appendCode("lw "+reg2+", "+"("+reg2+")");
					}
					else
					{
						appendCode("lw "+reg2+", "+rval);
					}


					if(c_op == "==i")
					{
						appendCode("beq "+reg1+", "+reg2+", "+goto_label);
					}
					else if(c_op == "<=i")
					{
						appendCode("ble "+reg1+", "+reg2+", "+goto_label);
					}
					else if(c_op == ">=i")
					{
						appendCode("bge "+reg1+", "+reg2+", "+goto_label);
					}
					else if(c_op == "<i")
					{
						appendCode("blt "+reg1+", "+reg2+", "+goto_label);
					}
					else if(c_op == ">i")
					{
						appendCode("bgt "+reg1+", "+reg2+", "+goto_label);
					}
					else if(c_op == "!=i")
					{
						appendCode("bne "+reg1+", "+reg2+", "+goto_label);
					}
				}
			}
		}
	}
	cout << "code = " << code << endl;

	ofstream myfile("machine.asm");
	myfile << code;
	myfile.close();
	return 0;
}
