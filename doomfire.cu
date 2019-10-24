#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>

void prinrtMat(int** mat,int elem)
{
    for (int i = 0; i < elem; i++)
    {
        printf("[ ");
        for (int j = 0; j < elem; j++)
        {
            int num =mat[i][j];
        
            if(num<10)
                printf("0%d ",num);
            else
                printf("%d ",num);
        }
        printf("]\n");
    }
}

void updateFireIntensityPerPixelSimple(int** mat,int tam ,int posX, int posY)
{
    int belowPosX = posX;
    int decay = rand() % 3;
    int decayPosY = rand() % 5 + (-2); //random number between -3 and 3
    int belowPosY = posY + decayPosY;

    if(posX < tam - 1)
        belowPosX++;
    
    if(belowPosY < 0)
    {
        if(posX > 0)
        {
            posX --;
            belowPosY = tam - 1 + belowPosY;
        }
        else
            belowPosY=0;
    }
    else if(belowPosY > tam - 1)
    {
        if(posX < tam - 1)
        {
            posX ++;
            belowPosY = belowPosY - tam - 1;
        }
        else
            belowPosY = tam - 1;
    }

    int belowPixelFireIntensity = mat[belowPosX][belowPosY];
    int newFireIntensity = belowPixelFireIntensity - decay >= 0 ? belowPixelFireIntensity - decay: 0;

    mat[posX][posY]=newFireIntensity;
}

void updateFireIntensityPerPixel(int** mat,int elem ,int posX, int posY){
    
    int belowPosX = posX + 1;
    if(belowPosX == elem - 1);
        belowPosX = posX;
    
    int belowPosY = posY;
    int decay = rand() % 3;
    
    int decayPosX = rand() % 3;
    int decayPosY = rand() % 3;
    int belowPixelFireIntensity = mat[belowPosX][belowPosY];
    int newFireIntensity = belowPixelFireIntensity - decay >= 0 ? belowPixelFireIntensity - decay: 0;

    int newPosX = belowPosX + decayPosX < elem ? belowPosX + decayPosX: belowPosX;
    int newPosY = 0;
    
    if(newPosY+decayPosY< elem)
    {
        newPosY = newPosY+decayPosY;
    }
    else
    {
        if(newPosX +1 < elem - 2)
        {
            newPosX++;
            newPosY = newPosY + decayPosY;
        }
        else
            newPosY = elem - 1;
    }

    printf("mat[%d][%d]=%d\n", newPosX, newPosY, newFireIntensity);
    if(newPosX < elem - 1);
        mat[newPosX][newPosY] = newFireIntensity;

}

__global__ void calculeteFirePropagation(int ** mat,int elem)
{
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    int stride = blockDim.x * gridDim.x;

    for (int i = elem - 2; i >= 0; i--)
    {
        for (int j = 0; j < elem; j++)
        {
            updateFireIntensityPerPixelSimple(mat,elem ,i, j);
        }
    }
}

__global__ void creatFireSource(int** mat,int elem)
{
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    int stride = blockDim.x * gridDim.x;

    int lestLine = elem - 1;
    
    for (int j = index; j < elem; j += stride)
    {
        mat[lestLine][j]= 36;
    }
}

__global__ void loadFireStruct(int** mat,int elem)
{
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    int stride = blockDim.x * gridDim.x;

    for (int i = index; i < elem; i += stride)
    {
        for (int j = index; j < elem; j += stride)
        {
            mat[i][j]=0;
        }
    }
}

int main(int argc, char *argv[])
{
    int deviceId;
    int numberOfSMs;

    cudaGetDevice(&deviceId);
    cudaDeviceGetAttribute(&numberOfSMs, cudaDevAttrMultiProcessorCount, deviceId);
   
    size_t threadsPerBlock;
    size_t numberOfBlocks;
    
    threadsPerBlock = 256;
    numberOfBlocks = 32 * numberOfSMs;
    
    int elem = 40;
    
    int size = elem*elem*sizeof(int);
    int * fireStruct;
    cudaMallocManaged (&fireStruct, size);
    

    loadFireStruct(fireStruct,elem);
    creatFireSource(fireStruct,elem);
    while (1)
    {
        calculeteFirePropagation(fireStruct,elem);
        printf("=================\n");
        prinrtMat(fireStruct,elem);
        sleep(1);
    }
    cudaFree(fireStruct);
    //REMEMBER CUDAFREE cudaFree();

    return 0;
}