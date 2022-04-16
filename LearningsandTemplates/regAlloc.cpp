#include <iostream>
#include <vector>
#include <map>
#include <string>
#include <algorithm>
#include <cstring>
using namespace std;

vector<string>  registers;
map<string, vector<string> > addrDescriptor;
map<string, vector<string> > regDescriptor;

void init_registers(){

    for(int i = 8; i < 26; i++){
        string s = "$" + to_string(i);
        registers.push_back(s);
    }

}

string get_register(string key){

    int flag = 0;
    
    if (addrDescriptor.find(key) != addrDescriptor.end()) {
        vector<string>  s = addrDescriptor.find(key)->second;
        for(int i = 0; i < s.size(); i++)
            if(s[i].rfind("$", 0) == 0){
                flag = 1;
                return s[i];
            }  
    }
    else{
        cout << "Couldn't get the register as given key not found in Address Descriptor map";
        return "";
    }
    if(!flag){
        for (auto regDesc = regDescriptor.begin(); regDesc != regDescriptor.end(); ++regDesc) {
            if(regDesc->second.size() == 0){
                return regDesc->first;
            }       
        }
        map<string, int> regDescriptor_score;
        for(int i = 0; i < registers.size(); i++)
            regDescriptor_score.insert({registers[i], 0});
        for(int i = 0 ; i < registers.size(); i++){
              vector<string>  v (regDescriptor.find(registers[i])->second);    
              for(int j = 0 ; j < v.size(); j++){
                  vector <int> score;
                  vector<string> v2 (addrDescriptor.find(v[j])->second);
                  int registers_count = 0;
                  for(int k = 0 ; k < v2.size(); k++){
                      if(v2[k].rfind("$",0)== 0){
                            registers_count++;
                      }
                  }
                  if(registers_count == 1)
                    regDescriptor_score.find(registers[i])->second++;
              }

        }


        cout << "Register Descriptors Score :  \n";
        cout << "Key\t Value\n" ;
        for (auto regDesc = regDescriptor_score.begin(); regDesc != regDescriptor_score.end(); ++regDesc) {
                cout << regDesc->first << "\t " ;
                cout << regDesc->second << ' ';
                cout << endl;
            } 
        cout << endl;

        int max = -1;
        for (auto regDesc = regDescriptor_score.begin(); regDesc != regDescriptor_score.end(); ++regDesc) {
                if(regDesc->second > max);
                    max= regDesc->second;
        } 

        int min = max;
        string reg = "";

        for (auto regDesc = regDescriptor_score.begin(); regDesc != regDescriptor_score.end(); ++regDesc) {
                if(regDesc->second <= min);
                    max= regDesc->second;
                    reg = regDesc->first;
        } 


        return reg;


    }
    else{
        return "";      
    }
    return "";
}
void init_regDescriptor(){

    vector<string> s;
    for(int i = 0; i < registers.size(); i++)
        regDescriptor.insert({registers[i], s});
}

void insert_regDescriptor(string reg, string val){

    if (regDescriptor.find(reg) != regDescriptor.end()) {
        if(regDescriptor.find(reg)->second.size())
            regDescriptor.find(reg)->second.push_back(val);
        else{
            regDescriptor.find(reg)->second.clear();
            regDescriptor.find(reg)->second.push_back(val);

        }
    }
    else{
        cout << "Given key is not found in Register Descriptor map. Insert fn terminated\n";
    }
}

vector<string>  get_regDescriptor(string reg){

    vector<string> s;
    if (regDescriptor.find(reg) != regDescriptor.end()) {
        return regDescriptor.find(reg)->second;
    }
    else{
        cout << "Given key is not found in Register Descriptor map. Get fn terminated\n";
        return s;
    }
}

void remove_regDescriptor(string reg, string val){
    if (regDescriptor.find(reg) != regDescriptor.end()) {
        vector<string> vec = regDescriptor.find(reg)->second;
        vec.erase(remove(vec.begin(), vec.end(), val), vec.end());
        regDescriptor.find(reg)->second = vec;
    }
    else{
        cout << "Given key is not found in Register Descriptor map. Can't remove\n";
    }
}

void clear_regDescriptor(string reg){

    if (regDescriptor.find(reg) != regDescriptor.end()) {
        regDescriptor.find(reg)->second.clear();
    }
    else{
        cout << "Given key is not found in Register Descriptor map. Clear fn terminated \n";
    }
}

void insert_addrDescriptor(string addr, string val){

    if (addrDescriptor.find(addr) != addrDescriptor.end()) {
        vector<string>  s = addrDescriptor.find(addr)->second;
        s.push_back(val);
        addrDescriptor.find(addr)->second  = s;
    }
    else{
        vector<string>  s ;
        s.push_back(val);
        addrDescriptor.insert({addr, s});
    }
}

vector<string>  get_addrDescriptor(string addr){

    vector<string> s;
    if (addrDescriptor.find(addr) != addrDescriptor.end()) {
        return addrDescriptor.find(addr)->second;
    }
    else{
        cout << "Given key is not found in Address Descriptor map. Get fn terminated\n";
        return s;
    }
}

void remove_addrDescriptor(string addr, string val){
    if (addrDescriptor.find(addr) != addrDescriptor.end()) {
        vector<string> vec = addrDescriptor.find(addr)->second;
        vec.erase(remove(vec.begin(), vec.end(), val), vec.end());
        addrDescriptor.find(addr)->second = vec;
    }
    else{
        cout << "Given key is not found in Address Descriptor map. Can't remove\n";
    }
}

void clear_addrDescriptor(string addr){

    if (addrDescriptor.find(addr) != addrDescriptor.end()) {
        addrDescriptor.find(addr)->second.clear();
    }
    else{
        cout << "Given key is not found in Address Descriptor map \n";
    }
}

void print(int type){
    switch (type) {
        case 1 :
            cout << "Registers : " << endl;
            for(int i = 0; i < registers.size(); i++)
                cout << registers[i] << ' ';
            cout << endl;
            break;
        
        case 2 :
            cout << "Address Descriptors :  \n";
            cout << "Key\t Value\n" ;
            for (auto addrDesc = addrDescriptor.begin(); addrDesc != addrDescriptor.end(); ++addrDesc) {
                cout << addrDesc->first << "\t " ;
                for(int i = 0; i <  addrDesc->second.size(); i++)
                        cout << addrDesc->second[i] << ' ';
                cout << endl;
            } 
            cout << endl;
            break;
        case 3 :
            cout << "Register Descriptors :  \n";
            cout << "Key\t Value\n" ;
            for (auto regDesc = regDescriptor.begin(); regDesc != regDescriptor.end(); ++regDesc) {
                cout << regDesc->first << "\t " ;
                for(int i = 0; i <  regDesc->second.size(); i++)
                        cout << regDesc->second[i] << ' ';
                cout << endl;
            } 
            cout << endl;
            break;

        default :
            break;
    }

}

int main(){
    
    init_registers();
    print(1);

    insert_addrDescriptor("a","a");
    insert_addrDescriptor("a","$8");
    insert_addrDescriptor("b","b");
    insert_addrDescriptor("c", "$8");
    insert_addrDescriptor("c", "$10");
    insert_addrDescriptor("d", "d");
    insert_addrDescriptor("f", "f");

   

    init_regDescriptor();

insert_regDescriptor(registers[0], "a");
    for(int i = 1; i < registers.size(); i++){

        insert_regDescriptor(registers[i], "b");
        insert_addrDescriptor("b", registers[i]);


    }
    
 

    insert_regDescriptor("$8", "c");
    insert_regDescriptor("$10", "c");
    print(2);
print(3);
    // insert_regDescriptor("$9", "b");
    // insert_regDescriptor("$10", "c");
    // insert_regDescriptor("$10", "a");
    // insert_regDescriptor("$10", "b");
    // insert_regDescriptor("$11", "d");
    // insert_regDescriptor("$12", "f");
    // insert_regDescriptor("$13", "a");
    // insert_regDescriptor("$14", "b");
    // insert_regDescriptor("$15", "c");
    // insert_regDescriptor("$16", "d");
    // insert_regDescriptor("$17", "f");
    // insert_regDescriptor("$18", "a");
    // insert_regDescriptor("$19", "b");
    // insert_regDescriptor("$20", "c");
    // insert_regDescriptor("$21", "d");
    // insert_regDescriptor("$22", "f");
    // insert_regDescriptor("$23", "a");
    // insert_regDescriptor("$24", "b");
    // insert_regDescriptor("$25", "c");

    // vector<string> temp ;

    // temp = get_addrDescriptor("a");
    // for(int i = 0; i < temp.size(); i++)
    //             cout << temp[i] << ' ';
    // cout << endl;
    // cout << endl;

    // temp = get_regDescriptor("$9");
    // for(int i = 0; i < temp.size(); i++)
    //             cout << temp[i] << ' ';
    // cout << endl;

    // remove_regDescriptor("$9", "a");
    // print(3);

    string s = get_register("f");

    cout << s;

    return 0;
}