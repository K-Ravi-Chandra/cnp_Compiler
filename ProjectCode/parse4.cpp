#include<bits/stdc++.h>
#include <fstream>
#include <cstring>
#include<string.h>
using namespace std;

int main(){
	string mc = ".text \n.globl main \nmain:\n";
	string def = ".data\n";
   fstream file;
   file.open("output.txt",ios::in);
   if (file.is_open()){  
      string s;
      vector<string> var;
      while(getline(file, s)){ 
			char s1[s.size()+1];
			strcpy(s1, s.c_str());
			char* token = strtok(s1, " ");
			vector<string> tokens;
			while (token != NULL){
				
			    tokens.push_back(token);
			    token = strtok(NULL, " ");
			}
			
			if(tokens[0].substr(tokens[0].size()-1, tokens[0].size()) == ":"){
				string lname = tokens[0]; 
				mc += lname+"\n";
				
			}
			else if(tokens[0] == "goto"){
				string gotolabel = tokens[1];
				cout<<"goto"<<" "<<gotolabel<<endl;
				mc += "j "+gotolabel+"\n";
			}
			else if(tokens[0] == "int"){
				if(tokens.size() == 4){
					mc += "lw $2, 9\n";
					mc += "lw $4, "+ tokens[4]+"\n";
					mc += "sw $2, "+tokens[2]+"\n";
				}
				else{ 
					string v = tokens[1];
					//var.push_back(v);
					def += v + ": .word 0\n";
				}
			}
			else if(tokens[0] == "char"){
				string v = tokens[1];
				def += v + ": .byte '\0' \n";
			}
			else if(tokens[0] == "float"){
				string v = tokens[1];
				def += v + ": .float 0 \n";
			}
			else if(tokens[0] == "bool"){
				string v = tokens[1];
				def += v + ": .byte 0 \n";
			}
			else if(tokens[0] == "if"){
				string var1 = tokens[2];
				string c_op = tokens[3];
				string var2 = tokens[4];
				string goto_label = tokens[7];	
				string reg1 = "$8";
				string reg2 = "$9";
				if(var2 == "true"){
					mc += "bnez " +  reg1 + ", " + goto_label + "\n";
				}
				else if(var2 == "false"){
					mc += "beqz " + reg1 + ", " + goto_label + "\n";
				}
				if(c_op.substr(c_op.size()-1, c_op.size()) == "i"){
					if(var1[0] == '#'){
						mc += "li "+reg1+", "+var1.substr(1, var1.length())+"\n";
					}
					else if(var1[0] == '*' )
					{
						mc += "lw "+reg1+", "+var1.substr(1, var1.length())+"\n";
						mc += "lw "+reg1+", "+"("+reg1+")\n";
					}
					else{
						mc += "lw "+reg1+", "+var1+"\n";
					}
					if(var2[0] == '#'){
						mc += "li "+reg2+", "+var2.substr(1, var2.length())+"\n";
					}
					else if(var2[0] == '*' )
					{
						mc += "lw "+reg2+", "+var2.substr(1, var2.length())+"\n";
						mc += "lw "+reg2+", "+"("+reg2+")\n";
					}
					else{
						mc += "lw "+reg2+", "+var2+"\n";
					}
					
					
					if(c_op == "==i"){
						mc += "beq "+reg1+", "+reg2+" "+goto_label+"\n";
					}
					else if(c_op == "<=i"){
						mc += "ble "+reg1+", "+reg2+" "+goto_label+"\n";
					}
					else if(c_op == ">=i"){
						mc += "bge "+reg1+", "+reg2+" "+goto_label+"\n";
					}
					else if(c_op == "<i"){
						mc += "blt "+reg1+", "+reg2+" "+goto_label+"\n";
					}
					else if(c_op == ">i"){
						mc += "bgt "+reg1+", "+reg2+" "+goto_label+"\n";
					}
					else if(c_op == "!=i"){
						mc += "bne "+reg1+", "+reg2+" "+goto_label+"\n";
					}
				}
				else if(c_op.substr(c_op.size()-1, c_op.size()) == "f"){
					string f1="$f0", f2="$f1", f3="$f2";
					if(var1[0] == '#'){
						mc += "li.s "+f1+", "+var1.substr(1, var1.length())+"\n";
					}
					else if (var1[0] == '*') {
						mc += "lwcl "+f1+", "+var1.substr(1, var1.length())+"\n";
						mc += "lwcl "+f1+", "+"("+f1+")\n";
					}
					else{
						mc += "lwcl "+f1+", "+var1+"\n";
					}
					if(var2[0] == '#'){
						mc += "li.s "+f2+", "+var2.substr(1, var2.length())+"\n";
					}
					else if (var2[0] == '*') {
						mc += "lwcl "+f2+", "+var2.substr(1, var2.length())+"\n";
						mc += "lwcl "+f2+", "+"("+f2+")\n";
					}
					else{
						mc += "lwcl "+f2+", "+var2+"\n";
					}
					
					
					if(c_op == "==f"){
						mc += "c.eq.s "+f1+", "+f2+"\n";
					}
					else if(c_op == "<=f"){
						mc += "c.le.s "+f1+", "+f2+"\n";
					}
					else if(c_op == ">=f"){
						mc += "c.ge.s "+f1+", "+f2+"\n";
					}
					else if(c_op == "<f"){
						mc += "c.lt.s "+f1+", "+f2+"\n";
					}
					else if(c_op == ">f"){
						mc += "c.gt.s "+f1+", "+f2+"\n";
					}
					else if(c_op == "!=f"){
						mc += "c.ne.s "+f1+", "+f2+"\n";
					}
					mc += "bclt "+goto_label+"\n";
				} 
			}
			else if(tokens[0] == "print"){
				string type = tokens[1];
				string var1 = tokens[2];
				if(type == "int"){
					mc += "li $2, 1\n"; 
					mc += "lw $4, " + var1 +"\n";
					mc += "syscall\n";
				}
				else if(type == "char"){
					mc += "li $2, 11\n"; 
					mc += "la $4, " + var1 +"\n";
					mc += "syscall\n";
				}
				else {
					
				}
				
			}
			else if(tokens[0] == "scan"){
				string type = tokens[1];
				string var1 = tokens[2];
				if(type == "int"){
					mc += "li $2, 5\n"; 
					//mc += "lw $4, " + var1 +"\n";
					
					mc += "syscall\n";
					if(var2[0] != '0'){
						mc += "sw $2, " + var2 + "\n";
					}
					else{
						mc += "sw $2, (" + var2 + ")\n";
					}
				}
				else if(type == "char"){
					mc += "li $2, 12\n"; 
					//mc += "la $4, " + var1 +"\n";
					mc += "syscall\n";
					if(var2[0] != '0'){
						mc += "sw $2, " + var2 + "\n";
					}
					else{
						mc += "sw $2, (" + var2 + ")\n";
					}
				}
			}
			
			else{
				int a = 0;
				string v1, v2;
				string reg1 = "$8";
				string reg2 = "$9";
				string reg3 = "$10";
				v1 = tokens[0];
				v2 = tokens[2];
				if(v2 == "true"){
					mc += "li "+reg2+", 1"+"\n";
				}
				if(v2 == "false"){
					mc += "li "+reg2+", 0"+"\n";
				}
				string eq = tokens[1];
				if(eq == "=i"){			//integer i
				
					
					if(tokens.size() > 3){
						string op = tokens[3];
						
						 string v3 = tokens[4];
						//mc += "lw "+reg1+", "+v2+"\n";
						
						if(v2[0] == '#'){
							mc += "li " +reg1+", "+v2.substr(1, v2.size())+"\n";
						}
						else if(v2[0] == '*'){
							mc += "lw "+reg1+", "+v2.substr(1, v2.size())+"\n";
							mc += "lw "+reg1+", "+"("+reg1+")\n";
						}
						else{
							mc += "lw "+reg1+", "+v2+"\n";
						}
						
						int t2 = 0;
						if(v3[0] == '#'){
							t2=1;
						}
						else if(v3[0] == '*'){
							mc += "lw "+reg2+", "+v3,substr(1, v3.size())+"\n";
							mc += "lw "+reg2+", "+"("+reg2+")\n";
						}
						else{
							mc += "lw "+reg2+", "+v3+"\n";
						}
						
						if(op == "+i"){
						 	t2 == 0 ? mc += "add "+ reg3 + ", " + reg1 + ", " + reg2 + "\n" : mc += "addi "+ reg3 + ", " + reg1 + ", " + v3.substr(1, v3.length()) + "\n";
						}
						else if(op == "-i"){
							mc += "sub "+ reg3 + ", " + reg1 + ", " + reg2 + "\n";
						}
						else if(op == "*i"){
							mc += "mul "+ reg3 + ", " + reg1 + ", " + reg2 + "\n";
						}
						else if(op == "/i"){
							mc += "div "+ reg1 + ", " + reg2 + "\n";
							mc += "mflo "+ reg3 + "\n";
						}
						mc += "sw " + reg3 + ", " + v1 + "\n";	
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
						mc += "sw " + reg2 + ", " + v1 + "\n";
					}
				}
				else if(eq == "=f"){	//float =
					string f1="$f0", f2="$f1", f3="$f2";
					
					if(tokens.size() > 3){
						string op = tokens[3];
						
						 string v3 = tokens[4];
						//mc += "lwcl "+f1+", "+v2+"\n";
						if(v2[0] == '#'){
							mc += "li.s"+ f1 + ", " + v2.substr(1, v2.length()) + "\n";
						}
						else if(v2[0] == '*'){
							mc += "lwcl "+f1+", "+v2.substr(1, v2.length())+"\n";
							mc += "lwcl "+f1+", "+"("+f1+")\n";
						}
						else{
							mc += "lwcl "+f1+", "+v2+"\n";
						}
						
						
						if(v3[0] == '#'){
							mc += "li.s"+ f2 + ", " + v3.substr(1, v3.length()) + "\n";
						}
						else if(v3[0] == '*'){
							mc += "lwcl "+f2+", "+v3.substr(1, v3.length())+"\n";
							mc += "lwcl "+f2+", "+"("+f2+")\n";
						}
						else{
							mc += "lwcl "+f2+", "+v3+"\n";
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
						mc += "swcl " + f3 + ", " + v1 + "\n";	
					}
					else {

						if(v2[0] == '#'){
							mc += "li.s"+ f1 + ", " + v2.substr(1, v2.length()) + "\n";
						}
						else if(v2[0] == '*'){
							mc += "lwcl "+f2+", "+v2.substr(1, v2.length())+"\n";
							mc += "lwcl "+f2+", "+"("+f2+")\n";
						}
						else{
							mc += "lwcl "+f2+", "+v2+"\n";
						}
						mc += "swcl " + f2 + ", " + v1 + "\n";
					}
				}
				/*else if(eq == "=b"){
					if(v2[0] == '#'){
							mc += "li.s "+f2+", "+v2.substr(1, v2.length())+"\n";
						}
						else{
							mc += "lwcl "+f2+", "+v2+"\n";
						}
						mc += "swcl " + f2 + ", " + v1 + "\n";
				}*/
				else if(eq == "=c"){
					if(v2[0] == '#'){
							mc += "li "+reg2+", "+v2.substr(1, v2.length())+"\n";
						}
						else{
							mc += "lw "+reg2+", "+v2+"\n";
						}
						mc += "sw " + reg2 + ", " + v1 + "\n";
				}
			}
		}
			
      }
      mc = def + mc;
      cout<<mc;
      file.close();
      ofstream myfile("machine_code.txt");
      myfile << mc;
      myfile.close();
   }
   
   
   // 17487 HX - RJY - Boarding RU
