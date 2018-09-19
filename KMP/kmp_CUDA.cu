#include <iostream>
#include <cstring>
#include <fstream>
#include "time.h"


using namespace std;

__host__ void preprocesamientoKMP(char* pattern, int m, int f[])
{
    int k;
    f[0] = -1;
    for (int i = 1; i < m; i++){
        k = f[i - 1];
        while (k >= 0){
            if (pattern[k] == pattern[i - 1])
                break;
            else
                k = f[k];
        }
        f[i] = k + 1;
    }
}
 
//check whether target string contains pattern 
__global__ void KMP(char* pattern, char* target,int f[],int c[],int sizePattern, int sizeText)
{
    int index = blockIdx.x*blockDim.x + threadIdx.x;

    int i = sizePattern * index;
    int j = sizePattern * (index + 2)-1;

    //printf("1-i: %i j: %i n: %i index: %i\n", i, j, sizePattern, index);

    if(i > sizeText)
        return;
    if(j > sizeText)
        j = sizeText;

    //printf("2-i: %i j: %i n: %i index: %i\n", i, j, sizePattern, index);

    int k = 0;        
    while (i < j)
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
            if (k == sizePattern)
            {
                c[i - sizePattern] = i - sizePattern;
                i = i - k + 1;
            }
        }
        else
            k = f[k];
    }
    return;
}
 
int main(int argc, char* argv[])
{
    // constante de tamaño
    const int S = 40000000;
    
    // cantidad de threads
    int M = 1024;

    // controla tamaño de char 1 a 4
    int charSize = 4;

    // varibles en CPU
    char *tar;
    char *pat;
    tar = (char*)malloc(2000000);
    pat = (char*)malloc(S*charSize);
    
    // Variables en GPU
    char *d_tar;
    char *d_pat;

    // Stream Files
    ifstream inputFileText;
    ifstream inputFilePattern;
    ofstream outputFileText;

    // Abrir archivos
    inputFileText.open(argv[1]);
    inputFilePattern.open(argv[2]);
    outputFileText.open("DATA/result.txt");

    inputFileText>>tar;
    inputFilePattern>>pat;

    int m = strlen(tar);
    int n = strlen(pat);
    int *fault;
    int *coin;

    fault = new int[m];
    coin = new int[m];

    int *d_fault;
    int *d_coin;

    // inicializar arreglo c con -1 para procesamiento y resultados
    for(int i = 0;i<m; i++)
        coin[i] = -1;


    //num blocks
    int blocks = (m/n+M)/M;

    printf("Copiando datos a GPU\n");
    
    //time_t timeL_init, timeL_end, timeT_end, timeT_init;
    cudaEvent_t start, stop, local_s, local_e;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventCreate(&local_s);
    cudaEventCreate(&local_e);
    
    preprocesamientoKMP(pat, m, fault);
    cudaEventRecord(start);
    /* Crear variables en cuda */
    cudaMalloc((void **)&d_tar, m*charSize);
    cudaMalloc((void **)&d_pat, n*charSize);
    cudaMalloc((void **)&d_fault, m*charSize);
    cudaMalloc((void **)&d_coin, m*charSize);

    /* Copia de datos a GPU */
    cudaMemcpy(d_tar, tar, m*charSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_pat, pat, n*charSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_fault, fault, m*charSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_coin, coin, m*charSize, cudaMemcpyHostToDevice);
    
    cudaEventRecord(local_s);
    KMP<<<blocks,M>>>(d_pat, d_tar ,d_fault, d_coin, n, m);
    cudaEventRecord(local_e);

    cudaMemcpy(coin, d_coin, m*charSize, cudaMemcpyDeviceToHost);

    // liberar memoria de GPU
    cudaFree(d_tar);
    cudaFree(d_pat);
    cudaFree(d_fault);
    cudaFree(d_coin);
    cudaEventRecord(stop);

    float milis, local;
    cudaEventSynchronize(stop);
    cudaEventSynchronize(local_e);
    cudaEventElapsedTime(&milis, start, stop);
    cudaEventElapsedTime(&local, local_s, local_e);
    
    // mostrar resultados
    for(int i = 0;i<m; i++)
        if(coin[i]!=-1)
            outputFileText<<"position: "<<i<<"\tmatch: "<<coin[i]<<'\n';
    
    
    printf("Blocks: %i Threads: %i n: %i m:%i\n", (m/n+M)/M, M, n, m);
    printf("Tiempo ejecucion: %1.15f ml.\n", milis);
    printf("Tiempo ejecucion kernel: %1.15f ml.\n", local);

    return 0;
}
