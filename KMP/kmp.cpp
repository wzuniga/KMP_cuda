#include <iostream>
#include <cstring>
#include <fstream>
#include <ctime>

using namespace std;

void preKMP(char* pattern, int f[])
{
    int m = strlen(pattern), k;
    f[0] = -1;
    for (int i = 1; i < m; i++)
    {
        k = f[i - 1];
        while (k >= 0)
        {
            if (pattern[k] == pattern[i - 1])
                break;
            else
                k = f[k];
        }
        f[i] = k + 1;
    }
}
 
void KMP(char* pattern, char* target,int f[], int c[])
{
    int m = strlen(pattern);
    int n = strlen(target);
         
    int i = 0;
    int k = 0;        
    while (i < n)
    {
        if (k == -1)
        {
            i++;
            k = 0;
        }
        else if (target[i] == pattern[k])
        {
            i++;
            k++;
            if (k == m)
                {
                    c[i-m] = i-m;
                     i = i - k + 1;

                }
        }
        else
            k = f[k];
    }
    return ;
}
 
int main(int argc, char* argv[])
{
    clock_t start, end;
    

    const int S = 40000000;

    ifstream inputFileText;
    ifstream inputFilePattern;
    ofstream outputFileText;

    inputFileText.open(argv[1]);
    inputFilePattern.open(argv[2]);
    outputFileText.open("DATA/serial.txt");
    
    start = clock();

    int cSize = 4;

    char *tar;
    char *pat; 
    tar = new char[2000000];
    pat = new char[S];
    

    inputFileText>>tar;
    inputFilePattern>>pat;

    int m = strlen(tar);
    int n = strlen(pat);

    int *f;
    int *c;
    f = new int[m];
    c = new int[m];

    for(int i = 0;i<m; i++)
        c[i] = -1;
    
    preKMP(pat, f);
    start = clock();
    KMP(pat, tar,f,c);

    end = clock();

    for(int i = 0;i<m; i++)
        if(c[i]!=-1)
            outputFileText<<"position: "<<i<<"\tmatch: "<<c[i]<<'\n';

    printf("Tiempo ejecucion: %1.15f ml.\n", (double(end-start) / CLOCKS_PER_SEC) * 1000);
    return 0;
}