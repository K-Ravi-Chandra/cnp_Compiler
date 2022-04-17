#include<bits/stdc++.h>
using namespace std;
int getK(string str)
{
    return 0;
}

int getM(string n, string attr)
{
    return 1;
}

string getAddress(string var)
{
    if(var.substr(0, 1) == "&")
    {
        string n = var.substr(1, var.length());
        return to_string(getK(n));
    }
    else{
        int i=0;
        while(i < var.length() && var[i] != '.')
        {
            i++;
        }
        if(i == var.length())
        {
            return to_string(getK(var)) + "($sp)";
        }
        else
        {
            string n = var.substr(0, i);
            string attr = var.substr(i+1, var.length());
            //cout<<n<<" "<<attr;
            int m = getM(n, attr);
            int k = getK(n);
            return to_string(k+m)+"($sp)";
        }
        return "--";
    }
}

int main()
{
    cout<<getAddress("nattr");
}