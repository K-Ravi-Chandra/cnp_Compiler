#include<bits/stdc++.h>
#include <fstream>
#include <cstring>
#include<string.h>
using namespace std;

int main( int argcount, char* arguements[] )
{
	string mc = ".text \n.globl main \nmain:\n";
	string def = ".data\n";
	fstream file; file.open(arguements[1],ios::in); if (file.is_open())
	{  
		string s;
		vector<string> var;
		while(getline(file, s))
		{ 
			//cout << s << endl;
			char s1[s.size()+1];
			strcpy(s1, s.c_str());
			char* token = strtok(s1, " ");
			vector<string> tokens;
			while (token != NULL)
			{

				tokens.push_back(token);
				token = strtok(NULL, " ");
			}

			if(tokens[0].substr(tokens[0].size()-1, tokens[0].size()) == ":")
			{
				string lname = tokens[0]; 
				mc += lname+"\n";

			}
			else if(tokens[0] == "goto")
			{
				string gotolabel = tokens[1];
				mc += "j "+gotolabel+"\n";
			}
			else if(tokens[0] == "int")
			{
				if(tokens.size() > 2 )
				{
					mc += "li $8, 1\n";

					for( int i = 2 ; i < tokens.size() ; i++ )
					{
						mc += "lw $9, " + tokens[i] + "\n";
						mc += "mul $8, $8, $9\n";
					}
					mc += "li $10, 4\n";
					mc += "mul $8, $8, $10\n";
					mc += "li $2, 9\n";
					mc += "move $4, $8\n";
					mc += "syscall\n";
					mc += "sw $2, "+tokens[1]+"\n";
					def += tokens[1] + ": .word 0\n";
				}
				else
				{
					string v = tokens[1];
					def += v + ": .word 0\n";
				}
			}
			else if(tokens[0] == "char")
			{
				string v = tokens[1];
				def += v + ": .word 0\n";
			}
			else if(tokens[0] == "float")
			{
				string v = tokens[1];
				def += v + ": .float 0.0 \n";
			}
			else if(tokens[0] == "bool")
			{
				string v = tokens[1];
				def += v + ": .word 0 \n";
			}
			else if( tokens[0] == "string" )
			{
				string v = tokens[1];
				def += v + ": .asciiz \"\" \n";
			}
			else if(tokens[0] == "if")
			{
				string var1 = tokens[2];
				string c_op = tokens[3];
				string var2 = tokens[4];
				string goto_label = tokens[7];  
				string reg1 = "$8";
				string reg2 = "$9";
				if(c_op.substr(c_op.size()-1, c_op.size()) == "b")
				{
					mc += "lw "+reg1+", "+var1+"\n";
					if( c_op == "==b" )
					{
						if(var2 == "#true")
						{
							mc += "bnez " +  reg1 + ", " + goto_label + "\n";
						}
						else if(var2 == "#false"){
							mc += "beqz " + reg1 + ", " + goto_label + "\n";
						}
					}
					else if( c_op == "!=b" )
					{
						if(var2 == "#false")
						{
							mc += "bnez " +  reg1 + ", " + goto_label + "\n";
						}
						else if(var2 == "#true"){
							mc += "beqz " + reg1 + ", " + goto_label + "\n";
						}
					}
				}
				if(c_op.substr(c_op.size()-1, c_op.size()) == "i")
				{
					if(var1[0] == '#')
					{
						mc += "li "+reg1+", "+var1.substr(1, var1.length())+"\n";
					}
					else if(var1[0] == '*' )
					{
						mc += "lw "+reg1+", "+var1.substr(1, var1.length())+"\n";
						mc += "lw "+reg1+", "+"("+reg1+")\n";
					}
					else
					{
						mc += "lw "+reg1+", "+var1+"\n";
					}

					if(var2[0] == '#')
					{
						mc += "li "+reg2+", "+var2.substr(1, var2.length())+"\n";
					}
					else if(var2[0] == '*' )
					{
						mc += "lw "+reg2+", "+var2.substr(1, var2.length())+"\n";
						mc += "lw "+reg2+", "+"("+reg2+")\n";
					}
					else
					{
						mc += "lw "+reg2+", "+var2+"\n";
					}


					if(c_op == "==i")
					{
						mc += "beq "+reg1+", "+reg2+", "+goto_label+"\n";
					}
					else if(c_op == "<=i")
					{
						mc += "ble "+reg1+", "+reg2+", "+goto_label+"\n";
					}
					else if(c_op == ">=i")
					{
						mc += "bge "+reg1+", "+reg2+", "+goto_label+"\n";
					}
					else if(c_op == "<i")
					{
						mc += "blt "+reg1+", "+reg2+", "+goto_label+"\n";
					}
					else if(c_op == ">i")
					{
						mc += "bgt "+reg1+", "+reg2+", "+goto_label+"\n";
					}
					else if(c_op == "!=i")
					{
						mc += "bne "+reg1+", "+reg2+", "+goto_label+"\n";
					}
				}
				else if(c_op.substr(c_op.size()-1, c_op.size()) == "f")
				{
					string f1="$f0", f2="$f1", f3="$f2";

					if(var1[0] == '#')
					{
						mc += "li.s "+f1+", "+var1.substr(1, var1.length())+"\n";
					}
					else if (var1[0] == '*') 
					{
						mc += "lwc1 "+f1+", "+var1.substr(1, var1.length())+"\n";
						mc += "lwc1 "+f1+", "+"("+f1+")\n";
					}
					else
					{
						mc += "lwc1 "+f1+", "+var1+"\n";
					}

					if(var2[0] == '#')
					{
						mc += "li.s "+f2+", "+var2.substr(1, var2.length())+"\n";
					}
					else if (var2[0] == '*') 
					{
						mc += "lwc1 "+f2+", "+var2.substr(1, var2.length())+"\n";
						mc += "lwc1 "+f2+", "+"("+f2+")\n";
					}
					else
					{
						mc += "lwc1 "+f2+", "+var2+"\n";
					}


					if(c_op == "==f")
					{
						mc += "c.eq.s "+f1+", "+f2+"\n";
					}
					else if(c_op == "<=f")
					{
						mc += "c.le.s "+f1+", "+f2+"\n";
					}
					else if(c_op == ">=f")
					{
						mc += "c.le.s "+f2+", "+f1+"\n";
					}
					else if(c_op == "<f")
					{
						mc += "c.lt.s "+f1+", "+f2+"\n";
					}
					else if(c_op == ">f")
					{
						mc += "c.lt.s "+f2+", "+f1+"\n";
					}
					else if(c_op == "!=f")
					{
						mc += "c.ne.s "+f1+", "+f2+"\n";
					}
					mc += "bc1t "+goto_label+"\n";
				} 
			}
			else if(tokens[0] == "print")
			{
				string type = tokens[1];
				string var1 = tokens[2];

				if(type == "int")
				{
					if( var1[0] == '*' )
					{
						mc += "lw $8, " + var1.substr(1, var1.size()) + "\n";
						mc += "lw $8, ($8)\n";
						mc += "li $2, 1\n"; 
						mc += "move $4, $8\n";
						mc += "syscall\n";
					}
					else
					{
						mc += "li $2, 1\n"; 
						mc += "lw $4, " + var1 +"\n";
						mc += "syscall\n";
					}
				}
				else if(type == "char")
				{
					mc += "li $2, 11\n"; 
					mc += "lw $4, " + var1 +"\n";
					mc += "syscall\n";
				}
				else if(type == "string")
				{
					mc += "li $2, 4\n"; 
					mc += "la $4, " + var1 +"\n";
					mc += "syscall\n";
				}
				else if(type == "float")
				{
					mc += "li $2, 2\n";
					mc += "lwc1 $f12, "+var1+"\n";
					mc += "syscall\n";
				}
				else if(type == "bool")
				{
					mc += "li $2, 1\n"; 
					mc += "lw $4, " + var1 +"\n";
					mc += "syscall\n";
				}                
			}
			else if(tokens[0] == "scan")
			{
				string type = tokens[1];
				string var1 = tokens[2];

				if(type == "int")
				{
					mc += "li $2, 5\n"; 
					mc += "syscall\n";

					if(var1[0] != '*')
					{
						mc += "sw $2, " + var1 + "\n";
					}
					else
					{
						mc += "lw $4, " + var1.substr(1, var1.length()) + "\n";
						mc += "sw $2, ($4)\n";
					}
				}
				else if(type == "char")
				{
					mc += "li $2, 12\n"; 
					mc += "syscall\n";

					if(var1[0] != '*')
					{
						mc += "sw $2, " + var1 + "\n";
					}
					else
					{
						mc += "sw $2, (" + var1.substr(1, var1.length()) + ")\n";
					}
				}
				else if(type == "string")
				{
					mc += "li $4, 200\n";
					mc += "li $2, 9\n";
					mc += "syscall\n";
					mc += "move $2, $4\n";
					mc += "li $2, 8\n";
					mc += "li $5, 200\n";
					mc += "syscall\n";
					mc += "sw $4, "+var1+"\n";
				}
				else if(type == "float")
				{
					mc += "li $2, 6\n";
					mc += "syscall\n";
					mc += "swc1 $f0, "+var1+"\n";
				}  
			}
			else if( tokens[0] == "la" )
			{
				string reg = "$8";
				mc += "la " + reg + ", " + tokens[2] + "\n";
				mc += "sw " + reg + ", " + tokens[1] + "\n";
			}
			else if( tokens[0] == "exit" )
			{
				mc += "li $v0, 10\nsyscall\n";
			}
			else if( tokens.size() >= 3 )
			{
				string v1, v2, res, resreg, eq, op;

				string reg1 = "$8";
				string reg2 = "$9";
				string reg3 = "$10";
				string reg4 = "$11";

				string f1 = "$f0";
				string f2 = "$f1";
				string f3 = "$f2";
				string f4 = "$f3";

				res = tokens[0]; 
				eq = tokens[1];

				if(eq == "=i")
				{
					v1 = tokens[2];
					if( tokens.size() == 4 )	//t1 = minus t2
					{
						v1 = tokens[3];
					}

					if( v1[0] == '#')
					{
						mc += "li " + reg1 + ", " + v1.substr( 1, v1.size() )+"\n";
					}
					else if(v1[0] == '*')
					{
						mc += "lw "+reg1+", "+v1.substr(1, v1.size())+"\n";
						mc += "lw "+reg1+", "+"("+reg1+")\n";
					}
					else
					{
						mc += "lw "+reg1+", "+v1+"\n";
					}


					if( tokens.size() == 4 )
					{
						mc += "sub "+reg1+ ", $zero, "+reg1+"\n";
					}

					if( tokens.size() == 5 )
					{
						op = tokens[3];
						v2 = tokens[4];
						int t2 = 0;

						if( v2[0] == '#')
						{
							mc += "li " + reg2 + ", " + v2.substr( 1, v2.size() )+"\n";
							t2 = 1;
						}
						else if(v2[0] == '*')
						{
							mc += "lw "+reg2+", "+v2.substr(1, v2.size())+"\n";
							mc += "lw "+reg2+", "+"("+reg2+")\n";
						}
						else
						{
							mc += "lw "+reg2+", "+v2+"\n";
						}


						if(op == "+i")
						{
							t2 == 0 ? mc += "add "+ reg3 + ", " + reg1 + ", " + reg2 + "\n" : mc += "addi "+ reg3 + ", " + reg1 + ", " + v2.substr(1, v2.length()) + "\n";
						}
						else if(op == "-i")
						{
							mc += "sub "+ reg3 + ", " + reg1 + ", " + reg2 + "\n";
						}
						else if(op == "*i")
						{
							mc += "mul "+ reg3 + ", " + reg1 + ", " + reg2 + "\n";
						}
						else if(op == "/i")
						{
							mc += "div "+ reg1 + ", " + reg2 + "\n";
							mc += "mflo "+ reg3 + "\n";
						}
						else if( op == "%%i" )
						{
							mc += "div "+ reg1 + ", " + reg2 + "\n";
							mc += "mfhi "+ reg3 + "\n";
						}
						resreg = reg3;
					}

					if( tokens.size() == 3 or tokens.size() == 4 )
					{
						resreg = reg1;
					}

					if( res[0] == '*')
					{
						mc += "lw "+reg4+", "+res.substr(1, res.size())+"\n";
						mc += "sw "+resreg+", "+"("+reg4+")\n";
					}
					else
					{
						mc += "sw " + resreg + ", " + res + "\n";
					}
				}
				else if( eq == "=f")
				{
					v1 = tokens[2];
					if( tokens.size() == 4 )	//t1 = minus t2
					{
						v1 = tokens[3];
					}

					if( v1[0] == '#')
					{
						mc += "li.s " + f1 + ", " + v1.substr( 1, v1.size() )+"\n";
					}
					else if(v1[0] == '*')
					{
						mc += "lwc1 "+f1+", "+v1.substr(1, v1.size())+"\n";
						mc += "lwc1 "+f1+", "+"("+f1+")\n";
					}
					else
					{
						mc += "lwc1 "+f1+", "+v1+"\n";
					}

					if( tokens.size() == 4 )
					{
						mc += "sub.s "+f1+ ", $zero, "+f1+"\n";
					}


					if( tokens.size() == 5 )
					{
						op = tokens[3];
						v2 = tokens[4];
						int t2 = 0;

						if( v2[0] == '#')
						{
							mc += "li.s " + f2 + ", " + v2.substr( 1, v2.size() )+"\n";
						}
						else if(v2[0] == '*')
						{
							mc += "lwc1 "+f2+", "+v2.substr(1, v2.size())+"\n";
							mc += "lwc1 "+f2+", "+"("+f2+")\n";
						}
						else
						{
							mc += "lwc1 "+f2+", "+v2+"\n";
						}

						if(op == "+f")
						{
							mc += "add.s "+ f3 + ", " + f1 + ", " + f2 + "\n";
						}
						else if(op == "-f")
						{
							mc += "sub.s "+ f3 + ", " + f1 + ", " + f2 + "\n";
						}
						else if(op == "*f")
						{
							mc += "mul.s "+ f3 + ", " + f1 + ", " + f2 + "\n";
						}
						else if(op == "/f")
						{
							mc += "div.s "+ f3 + ", " + f1 + ", " + f2 + "\n";
						}
						resreg = f3;
					}

					if( tokens.size() == 3 or tokens.size() == 4 )
					{
						resreg = f1;
					}

					if( res[0] == '*')
					{
						mc += "lwc1 " + f4 + ", " + res.substr(1, res.length()) + "\n";
						mc += "swc1 " + resreg + ", (" + f4 + ")\n";  
					}
					else
					{
						mc += "swc1 " + resreg + ", " + res + "\n";
					}
				}
				if( eq == "=b" )
				{
					v1 = tokens[2];

					if( v1[0] == '#')
					{
						if( v1.substr(1, v1.size()) == "true" )
						{
							mc += "li " + reg1 + ", 1\n";
						}
						else if( v1.substr(1, v1.size()) == "false" )
						{
							mc += "li " + reg1 + ", 0\n";
						}
					}
					else
					{
						mc += "lw "+reg1+", "+v1+"\n";
					}

					if( res[0] == '*')
					{
						mc += "lw "+reg4+", "+res.substr(1, res.size())+"\n";
						mc += "sw "+reg1+", "+"("+reg4+")\n";
					}
					else
					{
						mc += "sw " + reg1 + ", " + res + "\n";
					}
				}
				else if( eq == "=s")
				{
					if (tokens[2] == "strcat")
					{

					}
					else if(tokens[2] == "strcatc")
					{

					}
					else if( tokens[2][0] == '#' )
					{
						v1 = tokens[2];
						string temp = v1.substr(1, v1.length());
						for( int i = 3 ; i < tokens.size() ; i++ )
						{
							temp += " " + tokens[i];
						}
						def += res + ": .asciiz " +temp + "\n";
					}
					else
					{
						mc += "la $10, " + tokens[2] + "\n"; 
						mc += "sw $10, " + tokens[0] + "\n";
					}

				}
				else if( eq == "=c")
				{
					v1 = tokens[2];

					if( v1[0] == '#')
					{
						if( v1.size() == 4 )
						{
							mc += "li " + reg1 + ", " + to_string((int)v1[2])+"\n";
						}
						else if( v1.size() == 5 )
						{
							if( v1[3] == 'n' )
							{
								mc += "li " + reg1 + ", 10\n";
							}
						}
					}
					else if(v1[0] == '*')
					{
						mc += "lw "+reg1+", "+v1.substr(1, v1.size())+"\n";
						mc += "lw "+reg1+", "+"("+reg1+")\n";
					}
					else
					{
						mc += "lw "+reg1+", "+v1+"\n";
					}

					if( res[0] == '*')
					{
						mc += "lw "+reg4+", "+res.substr(1, res.size())+"\n";
						mc += "sw "+reg1+", "+"("+reg4+")\n";
					}
					else
					{
						mc += "sw " + reg1 + ", " + res + "\n";
					}
				}
			}

			/*
			   {
			   int a = 0;
			   string v1, v2;
			   string reg1 = "$8";
			   string reg2 = "$9";
			   string reg3 = "$10";
			   string f1="$f0", f2="$f1", f3="$f2";

			   v1 = tokens[0];
			   v2 = tokens[2];
			   if(v2 == "true")
			   {
			   mc += "li "+reg2+", 1"+"\n";
			   }
			   else if(v2 == "false")
			   {
			   mc += "li "+reg2+", 0"+"\n";
			   }
			   else if(v2 == "minus")
			   {
			   if(tokens[1] == "=i")
			   {
			   mc += "lw "+reg1+", " + v2 +"\n";
			   mc += "sub "+reg2+ ", $zero, "+reg1+"\n";
			   mc += "sw "+reg2+", "+v1+"\n";
			   }
			   else if(tokens[1] == "=f")
			   {
			   mc += "lwc1 " +f1+ ", " + v2 +"\n";
			   mc += "sub.s "+f2+ ", $zero, " + f1 + "\n";
			   mc += "swc1 " +f2+ ", "+v1+"\n";
			   }
			   }
			   string eq = tokens[1];
			   if(eq == "=i")
			   {         //integer i
			   if(tokens.size() > 3)
			   {
			   string op = tokens[3];

			   string v3 = tokens[4];

			   if(v2[0] == '#')
			   {
			   mc += "li " +reg1+", "+v2.substr(1, v2.size())+"\n";
			   }
			   else if(v2[0] == '*')
			   {
			   mc += "lw "+reg1+", "+v2.substr(1, v2.size())+"\n";
			   mc += "lw "+reg1+", "+"("+reg1+")\n";
			   }
			   else
			   {
			   mc += "lw "+reg1+", "+v2+"\n";
			   }

			   int t2 = 0;
			   if(v3[0] == '#')
			   {
			   t2=1;
			   }
			   else if(v3[0] == '*')
			   {
			   mc += "lw "+reg2+", "+v3.substr(1, v3.size())+"\n";
			   mc += "lw "+reg2+", "+"("+reg2+")\n";
			   }
			   else
			   {
			   mc += "lw "+reg2+", "+v3+"\n";
			   }

			if(op == "+i")
			{
				t2 == 0 ? mc += "add "+ reg3 + ", " + reg1 + ", " + reg2 + "\n" : mc += "addi "+ reg3 + ", " + reg1 + ", " + v3.substr(1, v3.length()) + "\n";
			}
			else if(op == "-i")
			{
				mc += "sub "+ reg3 + ", " + reg1 + ", " + reg2 + "\n";
			}
			else if(op == "*i")
			{
				mc += "mul "+ reg3 + ", " + reg1 + ", " + reg2 + "\n";
			}
			else if(op == "/i")
			{
				mc += "div "+ reg1 + ", " + reg2 + "\n";
				mc += "mflo "+ reg3 + "\n";
			}
			mc += "sw " + reg3 + ", (" + reg2 + ")\n";
		}
			else {
				if(v2[0] == '#'){
					mc += "li "+reg2+", "+v2.substr(1, v2.length())+"\n";
				}
				else if(v2[0] == '*'){
					mc += "lw "+reg1+", "+v2.substr(1, v2.size())+"\n";
					mc += "lw "+reg1+", "+"("+reg1+")\n";
				}
				else{
					mc += "lw "+reg2+", "+v2+"\n";
				}
				mc += "lw " + reg1 + ", " + v1 + "\n";
				mc += "sw " + reg2 + "," + reg1 + "\n";
			}
		}
			   else if(eq == "=f")
			   {    //float =
				   //string f1="$f0", f2="$f1", f3="$f2";

				   if(tokens.size() > 3){
					   string op = tokens[3];

					   string v3 = tokens[4];
					   //mc += "lwc1 "+f1+", "+v2+"\n";
					   if(v2[0] == '#'){
						   mc += "li.s"+ f1 + ", " + v2.substr(1, v2.length()) + "\n";
					   }
					   else if(v2[0] == '*'){
						   mc += "lwc1 "+f1+", "+v2.substr(1, v2.length())+"\n";
						   mc += "lwc1 "+f1+", "+"("+f1+")\n";
					   }
					   else{
						   mc += "lwc1 "+f1+", "+v2+"\n";
					   }


					   if(v3[0] == '#'){
						   mc += "li.s"+ f2 + ", " + v3.substr(1, v3.length()) + "\n";
					   }
					   else if(v3[0] == '*'){
						   mc += "lwc1 "+f2+", "+v3.substr(1, v3.length())+"\n";
						   mc += "lwc1 "+f2+", "+"("+f2+")\n";
					   }
					   else{
						   mc += "lwc1 "+f2+", "+v3+"\n";
					   }

					   if(op == "+f"){
						   mc += "add.s "+ f3 + ", " + f1 + ", " + f2 + "\n";
					   }
					   else if(op == "-f"){
						   mc += "sub.s "+ f3 + ", " + f1 + ", " + f2 + "\n";
					   }
					   else if(op == "*f"){
						   mc += "mul.s "+ f3 + ", " + f1 + ", " + f2 + "\n";
					   }
					   else if(op == "/f"){
						   mc += "div.s "+ f3 + ", " + f1 + ", " + f2 + "\n";
					   }
					   if(v1[0] == '*'){

						   mc += "lwc1 " + f2 + ", " + v1.substr(1, v1.length()) + "\n";
						   mc += "swc1 " + f3 + ", (" + f2 + ")\n";  
					   }
					   else {
						   mc += "swc1 " + f3 + ", " + v1 + "\n";
					   }
				   }
				   else {

					   if(v2[0] == '#'){
						   mc += "li.s"+ f1 + ", " + v2.substr(1, v2.length()) + "\n";
					   }
					   else if(v2[0] == '*'){
						   mc += "lwc1 "+f2+", "+v2.substr(1, v2.length())+"\n";
						   mc += "lwc1 "+f2+", "+"("+f2+")\n";
					   }
					   else{
						   mc += "lwc1 "+f2+", "+v2+"\n";
					   }
					   if(v1[0] == '*'){
						   mc += "lwc1 " + f1 + ", " + v1.substr(1, v1.length()) + "\n";
						   mc += "swc1 " + f2 + ", (" + f1 + ")\n";  
					   }
					   else{
						   mc += "swc1 " + f2 + ", " + v1 + "\n";
					   }
				   }
			   }
			   else if(eq == "=b"){
				   if(v2[0] == '#'){
					   mc += "li.s "+f2+", "+v2.substr(1, v2.length())+"\n";
				   }
				   else{
					   mc += "lwc1 "+f2+", "+v2+"\n";
				   }
				   mc += "swc1 " + f2 + ", " + v1 + "\n";
			   }
			   else if(eq == "=c"){
				   if(v2[0] == '#'){
					   mc += "li "+reg2+", "+v2.substr(1, v2.length())+"\n";
				   }
				   else{
					   mc += "lw "+reg2+", "+v2+"\n";
				   }
				   mc += "sw " + reg2 + ", " + v1 + "\n";
			   }
			   else if( eq == "=s")
			   {
				   if (tokens[2] == "strcat")
				   {

				   }
				   else if(tokens[2] == "strcatc")
				   {

				   }
				   else
				   {
					   string temp = v2.substr(1, v2.length());
					   for( int i = 3 ; i < tokens.size() ; i++ )
					   {
						   temp += " " + tokens[i];
					   }
					   def += v1 + ": .asciiz " +temp + "\n";
				   }

			   }
			   else if( eq == "=b")
			   {
				   if(tokens[2] == "not"){
					   mc += "lw " + reg1 + ", " + v2;
					   mc += "slti " + reg2 + ", " + reg1 + ", 1" + "\n";
					   mc += "sw " + reg2 +", " + v2 + "\n";
				   }
			   }
			   else if(eq == "=s"){
				   if(tokens[3] == "strcat"){

				   }
				   else if(tokens[3] == "strcatc"){

				   }
			   }
		}
		*/
		}

	}
	mc += "li $v0, 10\nsyscall\n";
	mc = def + mc;
	//cout<<mc;
	file.close();
	cout << "completed" << endl;
	ofstream myfile("machine_code.txt");
	myfile << mc;
	myfile.close();
}


// 17487 HX - RJY - Boarding RU
