#include<iostream>
#include <fstream>
#include <string.h>
#include <vector>
#include <map>
using namespace std;

struct Var {
    string type;
    string size ;
    bool fn;
};

struct DS {
    vector <string> functions ;
    map <string, vector <string>> params;
    map <string, vector <string>> vars;

    map <string, struct Var> data_type;
};

int main(int argcount, char* arguments[]){

    fstream file; 
    vector <vector<string>> v;
	file.open(string(arguments[1]),ios::in); 
    if(file.is_open()){
        string s;
        while(getline(file, s)){

            vector <string> tokens;
            string token = "";
            for( auto x : s){
                if(x== ' '){

                    tokens.push_back(token);
                    token = "";
                }
                else{
                    token += x;
                }
            }

            tokens.push_back(token);

            v.push_back(tokens);

        }
        


        file.close();

        map<string, struct DS > m;
        int s_start = 0;
        int s_end = 1;
        int f_start = 0;
        int f_end = 1;

        int p_start = 0;
        int p_end = 1;
        int v_start = 0;
        int v_end = 1;
    

        string parent_fn = "";
        string child_fn = "";

        for(int i = 0 ; i < v.size(); i++){

            if(v[i][0] == "struct" ){
               
                    if(v[i][1] == "start" ){
                        if(s_start == 0 && s_end == 1){
                            s_start = 1;
                            s_end = 0;
                            struct DS ds;
                            parent_fn = v[i][2];
                            m.insert({parent_fn, ds});
                        }
                        else {
                            cout << "invalid syntax \n";
                            break;
                        }
                    }
                    else if(v[i][1] == "end"){
                        if(s_start == 1 && s_end == 0){
                            s_start = 0;
                            s_end = 1;
                            parent_fn = "";
                        }
                        else{
                            cout << "invalid syntax \n";
                            break;
                        }
                    }
            }
                
            else if(v[i][0] == "function" ){
                
                    if(v[i][1] == "start" ){
                        if(s_start == 1 && s_end == 0 && f_start == 0 && f_end == 1){
                            f_start = 1;
                            f_end = 0;
                            child_fn = v[i][2];

                            
                            m.find(parent_fn)->second.functions.push_back(child_fn);


                            
                            i = i+1;

                            struct Var v1 ;
                            v1.type = v[i][0];
                            v1.size = v[i][1];
                            v1.fn = true;

                            m.find(parent_fn)->second.data_type.insert({child_fn, v1});
                        
                            
                            vector<string> t ;
                            m.find(parent_fn)->second.params.insert({child_fn, t});
                            m.find(parent_fn)->second.vars.insert({child_fn, t});


                        }
                        else {
                            cout << "invalid syntax \n";
                            break;
                        }
                    }
                    else if(v[i][1] == "end"){
                        if(s_start == 1 && s_end == 0 && f_start == 1 && f_end == 0){
                            f_start = 0;
                            f_end = 1;

                            v_start = 0;
                            v_end = 1;

                            p_start = 0;
                            p_end = 1;

                            child_fn = "";
                        }
                        else{
                            cout << "invalid syntax \n";
                            break;
                        }
                    }
            }

            else if(v[i][0] == "param" ){
                if(v[i][1] == "start"){


                    if( p_start == 0 && p_end == 1){
                        p_start = 1;
                        p_end = 0;
                    }
                    else {
                       
                        cout << "invalid syntax at linenoo : " << i << endl ;
                    }
                }
                else  if(v[i][1] == "end"){
     

                    if( p_start == 1 && p_end == 0){
                        p_start = 0;
                        p_end = 1;

                        v_start = 1;
                        v_end = 0;
                    }
                    else {
                        cout << "invalid syntax at linenooo : " << i << endl ;
                    }
                }

                else{
                    cout << "booo\n";
                }
            }

            else{
                if( p_start == 1 && p_end == 0){

                    struct DS ds = m.find(parent_fn)->second;
                    ds.params.find(child_fn)->second.push_back(v[i][2]);
                  
                  m.find(parent_fn)->second = ds;

                }
                else   if( v_start == 1 && v_end == 0){
                    struct Var v2 ;
                    v2.type = v[i][0];
                    v2.size = v[i][1];
                    v2.fn = false;
                    string name = v[i][2];

                    struct DS ds = m.find(parent_fn)->second;

                    ds.vars.find(child_fn)->second.push_back(v[i][2]);
                    ds.data_type.insert({name, v2});
                  
                  m.find(parent_fn)->second = ds;
                  

                }
                else{
                        cout << "invalid syntax at line_no : " << i << endl ;

                }
            }
            
            
        }

        cout << endl;

                // map<string, struct DS > m;
    for( auto M = m.begin(); M != m.end(); ++M){
        cout << "Parent fn : " << M->first << endl;

        struct DS d = M->second;

        cout << "child funtions : " << endl;
        vector<string> child_fns = d.functions;
        for(int i =  0 ; i < child_fns.size() ; i++){
            cout << child_fns[i] << endl;

            struct Var v = d.data_type.find(child_fns[i])->second;
            cout << " type : " << v.type << endl;
            cout << " size : " << v.size << endl;
            cout << " fn   : "  << v.fn << endl;
            cout  << endl; 

            cout << "Parameters : " << endl;
            vector <string> params = d.params.find(child_fns[i] )->second;
            cout << "Parameters size : " << params.size()<< endl;

            for(int j = 0 ; j < params.size(); j++){
                cout << params[j] << endl;
            }

                        cout <<" Variables" << endl;\
            vector <string> vars = d.vars.find(child_fns[i] )->second;
            cout << "vaiables size : " << vars.size()<< endl;

            for(int j = 0 ; j < vars.size(); j++){
                cout << vars[j] << endl;
                              struct Var v = d.data_type.find(vars[j])->second;

                cout <<" data_type " << v.type ;
                cout << "\n size " << v.size;
                cout <<"\n fn " << v.fn;

                cout << endl;
            }

        }

      
        
    }

    }
    else{
        cout << " Unable to open file" ;
    }

}