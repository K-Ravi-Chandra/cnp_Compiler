#include<bits/stdc++.h>
#include <fstream>
#include <cstring>
#include<string.h>
using namespace std;

int main()
{
	unordered_map<string, int> regMap;
	int looplabel = 1;
	fstream file; 
	file.open("file.temp",ios::in); 
	if (file.is_open())
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

			if(tokens[0] == "if")
			{
				string var1 = tokens[2];
				string c_op = tokens[3];
				string var2 = tokens[4];
				string goto_label = tokens[7];  
				string reg1 = "$8";
				string reg2 = "$9";
				if(c_op.substr(c_op.size()-1, c_op.size()) == "b")
				{
					regMap[var1]++;
				}
				else//(c_op.substr(c_op.size()-1, c_op.size()) == "i")
				{
					if(var1[0] == '#')
					{
						//mc += "li "+reg1+", "+var1.substr(1, var1.length())+"\n";
					}
					else if(var1[0] == '*' )
					{
						var1 = var1.substr(1, var1.length())+"\n";
						regMap[var1]++;
						//mc += "lw "+reg1+", "+"("+reg1+")\n";
					}
					else
					{
						regMap[var1]++;//mc += "lw "+reg1+", "+var1+"\n";
					}

					if(var2[0] == '#')
					{
						//mc += "li "+reg2+", "+var2.substr(1, var2.length())+"\n";
					}
					else if(var2[0] == '*' )
					{
						var2 = var2.substr(1, var2.length())+"\n";
						regMap[var2]++;
						//mc += "lw "+reg2+", "+"("+reg2+")\n";
					}
					else
					{
						regMap[var2]++;
						//mc += "lw "+reg2+", "+var2+"\n";
					}


				}
				
			}
			else if(tokens[0] == "print")
			{
				string type = tokens[1];
				string var1 = tokens[2];

				if(type == "int" || type == "char")
				{
					if( var1[0] == '*' )
					{
						var1 = var1.substr(1, var1.size());
						regMap[var1]++;
						}
					else
					{
						regMap[var1]++;
					}
				}
				
				else 
				{
					regMap[var1]++;
				}              
			}
			else if( tokens[0] == "la" )
			{
				string te1 = tokens[2];
				string te2 = tokens[1];
				regMap[te1]++; regMap[te2]++;
			}
			else if( tokens.size() >= 3 )
			{
				string v1, v2, res, resreg, eq, op;

				res = tokens[0]; 
				
				eq = tokens[1];

				if(eq == "=i" || eq == "=f")
				{
					/*if( tokens[2] == "len" )
					{
						mc += "lw $16, " + tokens[3] + "\n";
						string loop1 = "looplabel" + to_string(looplabel);
						looplabel++;
						string exit1 = "looplabel" + to_string(looplabel);
						looplabel++;

						mc += "addi $t0, $zero, 0\n";
						mc += loop1  + ":\n";
						mc += "lb $t1, 0($16)\n";
						mc += "beqz $t1, " + exit1 + "\n";

						mc += "addi $16, $16, 1\n";
						mc += "addi $t0, $t0, 1\n";
						mc +=  "j " + loop1 + "\n";
						mc += exit1 + ":\n";
						mc += "sw $t0, " + tokens[0] + "\n";
						continue;
					}*/
					v1 = tokens[2];
					if( tokens.size() == 4 )	//t1 = minus t2
					{
						v1 = tokens[3];
					}

					if( v1[0] == '#')
					{
						//mc += "li " + reg1 + ", " + v1.substr( 1, v1.size() )+"\n";
					}
					else if(v1[0] == '*')
					{
						v1 = v1.substr(1, v1.size());
						regMap[v1]++;
					}
					else
					{
						regMap[v1]++;//mc += "lw "+reg1+", "+v1+"\n";
					}

					if( tokens.size() == 5 )
					{
						op = tokens[3];
						v2 = tokens[4];
						int t2 = 0;

						if( v2[0] == '#')
						{
							
						}
						else if(v2[0] == '*')
						{
							v2 = v2.substr(1, v2.size());
							regMap[v2]++;
						}
						else
						{
							regMap[v2]++;//mc += "lw "+reg2+", "+v2+"\n";
						}
					}

					if( res[0] == '*')
					{
						res = res.substr(1, res.size());
						regMap[res]++;
					}
					else
					{
						regMap[res]++;//mc += "sw " + resreg + ", " + res + "\n";
					}
				}
				
				else if( eq == "=b" )
				{
					v1 = tokens[2];

					if( v1[0] == '#')
					{
						
					}
					else
					{
						regMap[v1]++;//mc += "lw "+reg1+", "+v1+"\n";
					}

					if( res[0] == '*')
					{
						res = res.substr(1, res.size());
						regMap[res]++;
					}
					else
					{
						regMap[res]++;//mc += "sw " + reg1 + ", " + res + "\n";
					}
				}
				else if( eq == "=s")
				{
					if (tokens[2] == "strcat")
					{
						
						string te1 = tokens[3];
						string te2 = tokens[4];
						regMap[te1]++;
						regMap[te2]++;

					}
					else if(tokens[2] == "strcatc")
					{  
						string te1 = tokens[3];
						regMap[te1]++;
						
						if( tokens[4][0] == '*' )
						{
							string te2 = tokens[4].substr(1, tokens[4].length()) + "\n";
							regMap[te2]++;//mc += "lb $t2, 0($t2)\n";
						}
						else
						{
							string te2 = tokens[4];
							regMap[te2]++;
						}
					}
					else if( tokens[2][0] == '#' )
					{
						regMap[res]++;
					}
					else
					{
						string te1 = tokens[2];
						regMap[te1]++;
					}

				}
				else if( eq == "=c")
				{
					v1 = tokens[2];

					if( v1[0] == '#')
					{
						
					}
					else if(v1[0] == '*')
					{
						v1 = v1.substr(1, v1.size());
						regMap[v1]++;
					}
					else
					{
						regMap[v1]++;//mc += "lb "+reg1+", "+v1+"\n";
					}

					if( res[0] == '*')
					{
						res = res.substr(1, res.size())+"\n";
						regMap[res]++;
					}
					else
					{
						regMap[res]++;
					}
				}
			}
		}

	}
	
	file.close();
	
	for(auto x: regMap)
	{
		cout<< x.first<< " - "<< x.second<< endl;
	}
	return 0;
}


// 17487 HX - RJY - Boarding RU
