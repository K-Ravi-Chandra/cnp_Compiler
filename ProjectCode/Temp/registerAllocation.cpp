#include<bits/stdc++.h>
#include <fstream>
#include <cstring>
#include<string.h>
using namespace std;

int main( /*int argcount, char* arguments[]*/ )
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
				if(var2.substr(0, 1) == "#"){
					var2 = "";
				}
				else{
					regMap[var2]++;	
				}
				cout<< var1<< " "<< var2<< endl;
				regMap[var1]++;
				
			}
			else if(tokens[0] == "print")
			{
				string type = tokens[1];
				string var1 = tokens[2];
				cout<< var1<< endl;  
				regMap[var1]++;         
			}
			else if(tokens[0] == "scan")
			{
				string type = tokens[1];
				string var1 = tokens[2]; 
				if(var1.substr(0, 1) == "*"){
					var1 = "";
				}
				else{
					regMap[var1]++;
				}
				cout<< var1<< endl;
				
			}
			else if( tokens[0] == "la" )
			{
				cout<< tokens[2]<<endl;
				string te = tokens[2];
				regMap[te]++;
			}
			else if( tokens.size() >= 3 )
			{
				string v1 = "", v2 = "", res = "", resreg, eq, op;
				res = tokens[0];
				regMap[res]++;
				eq = tokens[1];
				if(eq == "=i")
				{
					if( tokens[2] == "len" )
					{
						cout<< tokens[0]<< " "<< tokens[3] + " ";
						
						continue;
					}
					
					
					v1 = tokens[2];
					if( tokens.size() == 4 )	//t1 = minus t2
					{
						v1 = tokens[3];
					}
					
					if( v1[0] == '#')
					{
						v1 = "";
					}
					else if(v1[0] == '*')
					{
					
						v1 = v1.substr(1, v1.size());
						regMap[v1]++;
					}
					else
					{
						regMap[v1]++;
					}
						

					if( tokens.size() == 5 )
					{

						v2 = tokens[4];
						if(v2.substr(0, 1) == "#"){
							v2 = "";
						}
						else if(v2[0] = '*'){
							v2 = v2.substr(1, v2.size());
							regMap[v2]++;
						}
						else{
							regMap[v2]++;
						}
					}
					cout<< res<< " "<< v1<< " "<<v2 <<endl;

				}
				else if( eq == "=f")
				{
					v1 = tokens[2];
					if( tokens.size() == 4 )	//t1 = minus t2
					{
						v1 = tokens[3];
					}

					if( tokens.size() == 5 )
					{
						op = tokens[3];
						v2 = tokens[4];
					}
					cout<< res<< " "<< v1<< " "<< v2<< endl;
					regMap[v1]++; regMap[v2]++;
				}
				if( eq == "=b" )
				{
					v1 = tokens[2];
					if(v1.substr(0, 1) == "#"){
						v1 = "";
					}
					else{
						regMap[v1]++;
					}
					cout<< res<< " "<< v1<< endl;
					regMap[res]++;
				}
				else if( eq == "=s")
				{
					if (tokens[2] == "strcat")
					{
						cout<< tokens[3]<< " "<<tokens[4]<<endl;
						string te1 = tokens[3], te2 = tokens[4];
						regMap[te1]++; regMap[te2]++;

					}
					else if(tokens[2] == "strcatc")
					{  
						
						if( tokens[4][0] == '*' )
						{
							string te1 = tokens[3], te2 = tokens[4].substr(1, tokens[4].length());
							regMap[te1]++; regMap[te2]++;
							cout<< tokens[3]<< " "<< tokens[4].substr(1, tokens[4].length()) + "\n";
							
						}
						else
						{
							string te1 = tokens[3], te2 = tokens[4];
							regMap[te1]++; regMap[te2]++;
							cout<< tokens[3]<< " "<< tokens[4];
						}
					}
					else if( tokens[2][0] == '#' )
					{
						cout<< res<< endl;
						regMap[res]++;
					}
					else
					{
						cout<< tokens[2]<< endl; 
						string te1 = tokens[2];
						regMap[te1]++;
					}

				}
				else if( eq == "=c")
				{
					v2 = tokens[2];
					if(v2.substr(0, 1) == "#" || v2.substr(0, 1) == "*"){
						v2 = "";
					}
					else if(v2.substr(0, 1) == "*"){
						v2 = v2.substr(1, v2.size());
						regMap[v2]++;
					}
					else{
						regMap[v2]++;
					}
					cout<< res<< v2<< endl;
					regMap[res]++;

				}
			}
		}

	}
	cout<<endl<<endl;
	for(auto x: regMap)
	{
		cout<< x.first<< " - "<< x.second<< endl;
	}
	file.close();
	return 0;
}


// 17487 HX - RJY - Boarding RU
