#include<iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
using namespace std;

struct Var {
    string type;
    int size ;
    string name;
    int global =-1;
};

struct function
{
    string name;
    vector<string> parameters;  
    vector<string> variables;
    map <string, struct Var> params;
    map <string, struct Var> vars;
    struct  Var returnValue;
};

struct DS{
    string name;
    map <string, struct Var> attributes;
    map <string, struct function> funcs;
};

map<string, struct DS > m;

void printMap(){
    cout << "Printing Map " << endl;
    for(auto M = m.begin(); M!= m.end(); ++M){
        cout << "Parent Fn : " << M->first << endl;
        struct DS ds = M->second;

        map <string, struct Var> attributes = ds.attributes;
        cout << "Atrributes : " << endl;
        for( auto attr = attributes.begin(); attr != attributes.end(); ++attr){
            cout << "Atribute Name : " << attr->first<< endl;
            struct Var var = attr->second;

            cout << "type : " << var.type << endl;
            cout << "size : " << var.size<< endl;
            cout << "name : " << var.name<< endl;

        }
        map <string, struct function> funcs = ds.funcs;
        cout << "Functions : " << endl;
        for(auto fun = funcs.begin(); fun != funcs.end(); ++fun){
            cout << "funtion name : " << fun->first << endl;

            struct function fn = fun->second;

            cout << "name : " << fn.name << endl;
            cout << "Return value : " << endl;
            struct Var var ;
            var = fn.returnValue;
            cout << "type : " << var.type << endl;
            cout << "size : " << var.size<< endl;
            cout << "name : " << var.name<< endl;

            map <string, struct Var> params = fn.params; 
            cout << "Parameters : " << endl;
            for(auto par = params.begin(); par != params.end(); ++par){
                cout << "parameter name : " << par->first  << endl;
                var = par->second;
                cout << "type : " << var.type << endl;
                cout << "size : " << var.size<< endl;
                cout << "name : " << var.name<< endl;
            }

            map <string, struct Var> vars = fn.vars; 
            cout << "Variables : " << endl;
            for(auto v = vars.begin(); v != vars.end(); ++v){
                cout << "variable name : " << v->first  << endl;
                var = v->second;
                cout << "type : " << var.type << endl;
                cout << "size : " << var.size<< endl;
                cout << "name : " << var.name<< endl;
            }

            cout << endl;

        }
        cout << endl;

    }
}

int getVarSize(string parent_fn, string child_fn){
    int size = 0;
    if(m.find(parent_fn)!= m.end()){
        struct DS ds = m.find(parent_fn)->second;
        map <string, struct function> funcs = ds.funcs;
        if(funcs.find(child_fn)!= funcs.end()){
            struct function fn = funcs.find(child_fn)->second;

            map <string, struct Var> vars = fn.vars;

            struct Var var ;
            for(auto v = vars.begin(); v != vars.end(); ++v){
                var = v->second;
                size += var.size;
            }

        }
        else{
            cout << "Couldn't find the given fn : " + child_fn + " in funcs map "<< endl;
            return -1;
        }
    }
    else{
        cout << "Couldn't find the given struct : " + parent_fn + " in map "<< endl;
        return -1;
    }

    return size;
}

int stackAddresses(string s, int pars){
    string parent_fn = "";
    string child_fn = "";

    string word = "";
    for(auto x : s){
        if(x == '.'){
            parent_fn = word;
            word = "";
        }
        else{
            word += x;
        }
    }
    child_fn = word;


    int size = 0;
    if(m.find(parent_fn)!= m.end()){
        struct DS ds = m.find(parent_fn)->second;
        map <string, struct function> funcs = ds.funcs;
        if(funcs.find(child_fn)!= funcs.end()){
            struct function fn = funcs.find(child_fn)->second;

            map <string, struct Var> params = fn.params;
            vector <string> parameters = fn.parameters;

            int no_params = parameters.size();
            struct Var var ;
            if(pars > 0 && pars <= no_params){
                var = fn.returnValue;
                size += var.size;
                pars--;
                for(int i =0; pars>0 ; i++){
                    size += params.find(parameters[i])->second.size;
                    pars--;
                }
            }
            else{
                cout << "There are less parameters than given " << endl;
                return -1;
            }

        }
        else{
            cout << "Couldn't find the given fn : " + child_fn + " in funcs map "<< endl;
            return -1;
        }
    }
    else{
        cout << "Couldn't find the given struct : " + parent_fn + " in map "<< endl;
        return -1;
    }

    return size;


}

int stackAdressesName(string s, string par){
    string parent_fn = "";
    string child_fn = "";

    string word = "";
    for(auto x : s){
        if(x == '.'){
            parent_fn = word;
            word = "";
        }
        else{
            word += x;
        }
    }
    child_fn = word;

    int size = 0;
    if(m.find(parent_fn)!= m.end()){
        struct DS ds = m.find(parent_fn)->second;
        map <string, struct function> funcs = ds.funcs;
        if(funcs.find(child_fn)!= funcs.end()){
            struct function fn = funcs.find(child_fn)->second;

            map <string, struct Var> params = fn.params;
            vector <string> parameters = fn.parameters;
            
            int index= 0;
            for(index= 0 ; index < parameters.size(); index++){
                if(parameters[index] == par)
                    break;
            }

            if (index != parameters.size())
            {
                size = stackAddresses(s,index+1);
            }
            else {
                cout << "Could'nt find the parameter" << endl;
                return -1;
            }

        }
        else{
            cout << "Couldn't find the given fn : " + child_fn + " in funcs map "<< endl;
            return -1;
        }
    }
    else{
        cout << "Couldn't find the given struct : " + parent_fn + " in map "<< endl;
        return -1;
    }

    return size;

}


int stackAddressesVars(string s, int var_index){
    string parent_fn = "";
    string child_fn = "";

    string word = "";
    for(auto x : s){
        if(x == '.'){
            parent_fn = word;
            word = "";
        }
        else{
            word += x;
        }
    }
    child_fn = word;


    int size = 0;
    if(m.find(parent_fn)!= m.end()){
        struct DS ds = m.find(parent_fn)->second;
        map <string, struct function> funcs = ds.funcs;
        if(funcs.find(child_fn)!= funcs.end()){
            struct function fn = funcs.find(child_fn)->second;

            map <string, struct Var> vars = fn.vars;
            vector <string> variables = fn.variables;

            int no_vars = variables.size();
            struct Var var ;
            if(var_index > 0 && var_index <= no_vars){
                var = fn.returnValue;
                size += var.size;
                var_index--;
                for(int i =0; var_index>0 ; i++){
                    size += vars.find(variables[i])->second.size;
                    var_index--;
                }
            }
            else{
                cout << "There are less Variables than given " << endl;
                return -1;
            }

        }
        else{
            cout << "Couldn't find the given fn : " + child_fn + " in funcs map "<< endl;
            return -1;
        }
    }
    else{
        cout << "Couldn't find the given struct : " + parent_fn + " in map "<< endl;
        return -1;
    }

    return size;


}

int stackAdressesVarsName(string s, string var_name){
    string parent_fn = "";
    string child_fn = "";

    string word = "";
    for(auto x : s){
        if(x == '.'){
            parent_fn = word;
            word = "";
        }
        else{
            word += x;
        }
    }
    child_fn = word;

    int size = 0;
    if(m.find(parent_fn)!= m.end()){
        struct DS ds = m.find(parent_fn)->second;
        map <string, struct function> funcs = ds.funcs;
        if(funcs.find(child_fn)!= funcs.end()){
            struct function fn = funcs.find(child_fn)->second;

            map <string, struct Var> vars = fn.vars;
            vector <string> variables = fn.variables;
            
            int index= 0;
            for(index= 0 ; index < variables.size(); index++){
                if(variables[index] == var_name)
                    break;
            }

            if (index != variables.size())
            {
                size = stackAddressesVars(s,index+1);
            }
            else {
                cout << "Could'nt find the Variable" << endl;
                return -1;
            }

        }
        else{
            cout << "Couldn't find the given fn : " + child_fn + " in funcs map "<< endl;
            return -1;
        }
    }
    else{
        cout << "Couldn't find the given struct : " + parent_fn + " in map "<< endl;
        return -1;
    }

    return size;

}


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
                            ds.name = v[i][2];
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
                            
                            struct DS ds = m.find(parent_fn)->second;

                            struct function fn ;
                            fn.name = child_fn;
           
                            i++;

                            struct Var v1 ;
                            v1.type = v[i][0];
                            v1.size = stoi(v[i][1]);
                            v1.name = v[i][2];

                            fn.returnValue = v1;
                            
                            ds.funcs.insert({child_fn,fn});
                            m.find(parent_fn)->second= ds;

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

                    if(s_start == 1 && s_end == 0 && f_start == 1 && f_end == 0 && p_start == 0 && p_end == 1){
                        p_start = 1;
                        p_end = 0;
                    }
                    else {
                        cout << "invalid syntax at linenoo : " << i << endl ;
                    }
                }
                else  if(v[i][1] == "end"){
     
                    if(s_start == 1 && s_end == 0 && f_start == 1 && f_end == 0 && p_start == 1 && p_end == 0){
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
                if(s_start == 1 && s_end == 0 && f_start == 0 && f_end == 1){
                    struct DS ds =  m.find(parent_fn)->second;
                    struct Var var ;
                    var.type = v[i][0];
                    var.size = stoi(v[i][1]);
                    var.name = v[i][2];
                    if(v.size() == 4){
                        var.global = stoi(v[i][3]);
                    }
                    ds.attributes.insert({v[i][2], var});
                    m.find(parent_fn)->second = ds;

                }
                else if( p_start == 1 && p_end == 0){

                    struct DS ds = m.find(parent_fn)->second;

                    struct Var var;
                    var.type = v[i][0];
                    var.size = stoi(v[i][1]);
                    var.name = v[i][2];
                    if(v.size() == 4){
                        var.global = stoi(v[i][3]);
                    }

                    if(ds.funcs.find(child_fn) !=ds.funcs.end()){
                        
                        ds.funcs.find(child_fn)->second.parameters.push_back(var.name);
                        ds.funcs.find(child_fn)->second.params.insert({var.name, var});
                        m.find(parent_fn)->second = ds;

                    }
                    else{
                        cout << "Invalid syntax ! at line : " << i << endl;
                        break;
                    }
                  
                }
                else   if(p_start == 0 && p_end == 1 && v_start == 1 && v_end == 0){
                    
                    struct DS ds = m.find(parent_fn)->second;

                    struct Var var;
                    var.type = v[i][0];
                    //cout << "At i = " << i << " v[i][1] : "<< v[i][1] << endl;

                    var.size = stoi(v[i][1]);
                    var.name = v[i][2];
                    if(v.size() == 4){
                            cout << "At i = " << i << " v[i][3] : "<< v[i][3] << endl;
                        var.global = stoi(v[i][3]);
                    }

                    if(ds.funcs.find(child_fn) !=ds.funcs.end()){
                        ds.funcs.find(child_fn)->second.variables.push_back(var.name);
                        ds.funcs.find(child_fn)->second.vars.insert({var.name, var});
                        m.find(parent_fn)->second = ds;

                    }
                    else{
                        cout << "Invalid syntax ! at line : " << i << endl;
                        break;
                    }
                  

                }
                else{
                        cout << "invalid syntax at line_no : " << i << endl ;

                }
            }
            
            
        }


        // printMap();
        // cout << "Variables size : " << getVarSize("main","main" );
        // cout << stackAddresses("main.fibonacci", 4)<< endl;
        // cout << stackAdressesName("main.fibonacci", "n_5")<< endl << endl;

        // cout << stackAddresses("main.fibonacci", 1)<< endl;
        // cout << stackAdressesName("main.fibonacci", "n_7")<< endl<< endl;

        // cout << stackAddresses("main.fibonacci", 2)<< endl;
        // cout << stackAdressesName("main.fibonacci", "n_3")<< endl<< endl;

        // cout << stackAddresses("main.fibonacci", 3)<< endl;
        // cout << stackAdressesName("main.fibonacci", "n_1")<< endl << endl;



        cout << stackAddressesVars("main.fibonacci", 7)<< endl;
        cout << stackAdressesVarsName("main.fibonacci", "_t6_3")<< endl << endl;

    }
    else{
        cout << " Unable to open file" ;
    }

}