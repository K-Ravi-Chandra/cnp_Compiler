#include<bits/stdc++.h>
#include <fstream>
#include <cstring>
#include<string.h>
using namespace std;

int main()
{
    vector<pair<vector<string>, pair<vector<vector<string>>, vector<vector<string>>>>> functions12;
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
            if(tokens[0] == "function")
            {
                //function structure = name, return type, size; vector of arguments, vector of arguments and variables used
                //vector<pair<vector<string>, pair<vector<vector<string>>, vector<vector<string>>>> functions12
                string name = tokens[1];
                vector<string> prime;
                vector<string> args;
                //vector<string> s_arg;
                vector<string> vars;
                //vector<string> s_var;
                prime.push_back(name);
                int f1 = 1, f2 = 0;
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
                    if(f1 == 1)
                    {
                        prime.push_back(tokens[0]);
                        prime.push_back(tokens[1]);
                        prime.push_back(tokens[2]);
                        f1 = 0;
                    }
                    else if(tokens[1] == "param")
                    {
                        if(tokens[2] == "start")
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
                        args.insert(args.end(), {tokens[0], tokens[1], tokens[2]});
                        vars.insert(args.end(), {tokens[0], tokens[1], tokens[2]});
                    }
                    else
                    {
                        vars.insert(args.end(), {tokens[0], tokens[1], tokens[2]});
                    }
                }
                functions12.push_back(make_pair(prime, make_pair(args, vars)));
                for(int i=0; i<functions12.size(); i++){
                    for(int k=0; k<functions12[i].first.size(); k++){
                        cout<<functions12[i].first[k]<<" ";
                    }
                    cout<<endl;
                    for(int k=0; k<functions12[i].second.first.size(); k++){
                        cout<<functions12[i].second.first[k]<<" ";
                    }
                    cout<<endl;
                    for(int l=0; l<functions12[i].second.second.size(); l++){
                        cout<<functions12[i].second.second[l]<<" ";
                    }
                    cout<<endl;
                }
            }
        }
    }
}
