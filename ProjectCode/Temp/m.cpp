#include<bits/stdc++.h>
#include <fstream>
#include <cstring>
#include<string.h>
#include<stdlib.h>
using namespace std;

//vector<pair<vector<string>, pair<vector<vector<string>>, vector<vector<string>>>>> functions12;

class variable
{
    public:
    string type;
    int size;
    string vname;
};

class functions
{
    public:
    string name;
    variable returnType;

    vector<variable> params;
    vector<variable> vars; 
};

class struct_
{
    public:
    string name;
    vector<variable> attr;
    vector<functions> funcs;
};

vector<struct_> table;

void setStructTable()
{
    cout<<"start";
    fstream file; 
	file.open("file.txt",ios::in); 
	if (file.is_open())
	{  
		string s;
		vector<string> var;
        while(getline(file, s))
		{ 
            cout<<"file";
            char s1[s.size()+1];
            strcpy(s1, s.c_str());
            char* token = strtok(s1, " ");
            vector<string> tokens;
            while (token != NULL)
            {
                cout<<token;
                tokens.push_back(token);
                token = strtok(NULL, " ");
            }
            if(tokens[0] == "struct")
            {
                
                //struct_ *temp ;
                cout<<"struct";
                if(tokens[1] == "start")
                {
                    cout<<tokens[1]<<tokens[2];
                    struct_ *temp = new struct_();
                    //string te = "wef";//tokens[2];
                    (*temp).name = tokens[2];

                
                    while(getline(file, s))
                    {
                        cout<<"stin";
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
                        if(tokens[1] == "end")
                        {
                            break;
                        }
                        else
                        {
                            cout<<"fin";
                            if(tokens[0] == "function")
                            {
                                functions* fun1 = new functions();
                                (*fun1).name = tokens[2];
                                int f1 = 1, f2 = 0;
                                while(getline(file, s))
                                {
                                    cout<<"zzz";
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
                                    cout<<"**";
                                    if(tokens[1] == "end")
                                    {
                                        break;
                                        cout<<"break";
                                    }
                                    // else{
                                        cout<<"^^";
                                    // }
                                    if(f1 == 1)
                                    {
                                        cout<<"$$";
                                        (*fun1).returnType.type = tokens[0];
                                        string te = tokens[1];
                                        (*fun1).returnType.size = stoi(te);
                                        (*fun1).returnType.vname = tokens[2];
                                        f1 = 0;
                                    }
                                    else if(tokens[0] == "param")
                                    {
                                        if(tokens[1] == "start")
                                        {
                                            f2 = 1;
                                        }
                                        else
                                        {
                                            f2 = 0;
                                        }
                                    }
                                    else if(f2 == 1)
                                    {
                                        variable* v1 = new variable();
                                        (*v1).type = tokens[0];
                                        string te = tokens[1];
                                        (*v1).size = stoi(te);
                                        (*v1).vname = tokens[2];
                                        (*fun1).params.push_back((*v1));
                                    }
                                    else
                                    {
                                        variable* v1 = new variable();
                                        (*v1).type = tokens[0];
                                        string te = tokens[1];
                                        (*v1).size = stoi(te);
                                        (*v1).vname = tokens[2];
                                        (*fun1).vars.push_back((*v1));
                                    }
                                }
                                (*temp).funcs.push_back((*fun1));
                            }
                            else
                            {
                                cout<<"lm10";
                                variable* v1 = new variable();
                                (*v1).type = tokens[0];
                                string te = tokens[1];
                                (*v1).size = stoi(te);
                                (*v1).vname = tokens[2];
                                (*temp).attr.push_back((*v1));
                                cout<<"##";
                            }
                        }
                        
                    }
                    table.push_back(*temp);
                }
    
                //table.push_back(temp);
                cout<<"pushed";
            }
        }
    }
}



void print_structs()
{
    cout<<table.size();
    for(int i=0; i<table.size(); i++)
    {
        cout<<"in"<<endl<<endl;
        cout<<table[i].name<<"----"<<endl;
        cout<<table[i].funcs.size()<<"%%%"<<endl;
        for(int j=0; j<table[i].funcs.size(); j++)
        {
            cout<<table[i].funcs[j].name<<endl<<table[i].funcs[j].returnType.type<<" "<<table[i].funcs[j].returnType.size <<" "<< table[i].funcs[j].returnType.vname<<endl;
            cout<<"params start"<<endl;
            for(int k=0; k<table[i].funcs[j].params.size(); k++)
            {
                cout<<table[i].funcs[j].params[k].type<<" "<<table[i].funcs[j].params[k].size <<" "<<table[i].funcs[j].params[k].vname <<endl;
            }
            cout<<"params end"<<endl;
            for(int l=0; l<table[i].funcs[j].vars.size(); l++)
            {
                cout<<table[i].funcs[j].vars[l].type<<" "<<table[i].funcs[j].vars[l].size <<" "<<table[i].funcs[j].vars[l].vname <<endl;
            }
        }
        for(int m=0; m<table[i].attr.size(); m++)
        {
            cout<<table[i].attr[m].type<<" "<< table[i].attr[m].size<<" "<< table[i].attr[m].vname<<endl;
        }
    }
}


// void print()
// {
//     for(int i=0; i<functions12.size(); i++){
//                     for(int k=0; k<functions12[i].first.size(); k++){
//                         cout<<functions12[i].first[k]<<" ";
//                     }
//                     cout<<endl;
//                     for(int k=0; k<functions12[i].second.first.size(); k++){
//                         cout<<functions12[i].second.first[k][0]<<" ";
//                     }
//                     cout<<endl;
//                     for(int l=0; l<functions12[i].second.second.size(); l++){
//                         cout<<functions12[i].second.second[l][0]<<" ";
//                     }
//                     cout<<endl;
//                 }
// }



int main()
{
     cout<<"rg";
     setStructTable();
   
    print_structs();
    
    return 0;
}







// int main()
// {
// 	fstream file; 
// 	file.open("file.txt",ios::in); 
// 	if (file.is_open())
// 	{  
// 		string s;
// 		vector<string> var;
//         while(getline(file, s))
// 		{ 
            
//             //cout << s << endl;
//             char s1[s.size()+1];
//             strcpy(s1, s.c_str());
//             char* token = strtok(s1, " ");
//             vector<string> tokens;
//             while (token != NULL)
//             {

//                 tokens.push_back(token);
//                 token = strtok(NULL, " ");
//             }
//             if(tokens[0] == "function")
//             {
//                 //function structure = name, return type, size; vector of arguments, vector of arguments and variables used
//                 //vector<pair<vector<string>, pair<vector<vector<string>>, vector<vector<string>>>> functions12
//                 string name = tokens[1];
//                 vector<string>* prime = new vector<string>;
//                 vector<vector<string>>* args = new vector<vector<string>>;
//                 //vector<string> s_arg;
//                 vector<vector<string>>* vars = new vector<vector<string>>;
//                 //vector<string> s_var;
//                 (*prime).push_back(name);
//                 int f1 = 1, f2 = 0;
//                 while(getline(file, s))
//                 {
//                     if(s.substr(0, 3) == "end")
//                     {
//                         break;
//                     }
//                     //cout << s << endl;
//                     char s1[s.size()+1];
//                     strcpy(s1, s.c_str());
//                     char* token = strtok(s1, " ");
//                     vector<string> tokens;
//                     while (token != NULL)
//                     {

//                         tokens.push_back(token);
//                         token = strtok(NULL, " ");
//                     }
//                     if(f1 == 1)
//                     {
//                         (*prime).push_back(tokens[0]);
//                         (*prime).push_back(tokens[1]);
//                         (*prime).push_back(tokens[2]);
//                         f1 = 0;
//                     }
//                     else if(tokens[1] == "param")
//                     {
//                         if(tokens[2] == "start")
//                         {
//                             f2 = 1;
//                         }
//                         else
//                         {
//                             f2 = 0;
//                         }
//                     }
//                     // else if(f2 == 1)
//                     // {
//                     //     print();
//                     //     vector<string>* t1 = new vector<string>;
//                     //     (*t1).push_back(tokens[0]);
//                     //     (*t1).push_back(tokens[1]);
//                     //     (*t1).push_back(tokens[2]);
//                     //     (*args).push_back(*t1);
//                     //     (*vars).push_back(*t1);

//                     //     // vector<string> t2 = {tokens[0], tokens[1], tokens[2]};
//                     //     // vars.push_back(t2);
                
//                     //     // args.push_back(tokens[1]);
//                     //     // args.push_back(tokens[2]);
//                     //     // vars.push_back(tokens[0]);
//                     //     // vars.push_back(tokens[1]);
//                     //     // vars.push_back(tokens[2]);
//                     // }
//                     // else
//                     // {
//                     //     vector<string>* t1 = new vector<string>;
//                     //     // (*t1) = {tokens[0], tokens[1], tokens[2]};
//                     //     (*t1).push_back(tokens[0]);
//                     //     (*t1).push_back(tokens[1]);
//                     //     (*t1).push_back(tokens[2]);
//                     //     (*vars).push_back(*t1);
//                     //     //vars.push_back({tokens[0], tokens[1], tokens[2]});
//                     //     // vars.push_back(tokens[0]);
//                     //     // vars.push_back(tokens[1]);
//                     //     // vars.push_back(tokens[2]);
//                     // }
//                 }
//                 functions12.push_back(make_pair((*prime), make_pair((*args), (*vars))));
//                 print();
//             }
//         }
//     }
//     return 0;
// }

