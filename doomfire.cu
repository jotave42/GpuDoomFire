#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <cuda.h>
#include <curand_kernel.h>
#include <assert.h>
#include <cuda_runtime.h>

inline cudaError_t checkCuda(cudaError_t result)
{
  if (result != cudaSuccess) {
    fprintf(stderr, "CUDA Runtime Error: %s\n", cudaGetErrorString(result));
    //assert(result == cudaSuccess);
  }
  return result;
}

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

__device__ void updateFireIntensityPerPixelSimple(int** mat,int tam ,int posX, int posY,int index)
{
    int belowPosX = posX;
    //int decay = rand() % 3;
    //int decayPosY = rand() % 5 + (-2); //random number between -3 and 3
    //int belowPosY = posY + decayPosY;
    
    curandState state;

    curand_init(1234, index, 0, &state);
    float res = curand_uniform(&state);
    printf("res = %f\n",res);
    return;

  /*  if(posX < tam - 1)
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

    mat[posX][posY]=newFireIntensity;*/
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

__global__ void calculeteFirePropagation(int** mat,int elem)
{
    int index_x = threadIdx.x + blockIdx.x * blockDim.x;
    int stride_x = blockDim.x * gridDim.x;

    int index_y = threadIdx.y + blockIdx.y * blockDim.y;
    int stride_y = blockDim.y * gridDim.y;

    for (int i = elem - 2; i >= 0; i--)
    {
        for (int j = 0; j < elem; j++)
        {
            updateFireIntensityPerPixelSimple(mat,elem ,i, j, index_x);
        }
    }
}

__global__ void creatFireSource(int** mat,int elem)
{
    int index = threadIdx.y + blockIdx.y * blockDim.y;
    int stride = blockDim.y * gridDim.y;

    int lestLine = elem - 1;
    
    for (int j = index; j < elem; j += stride)
    {
        mat[lestLine][j]= 36;
    }
}

__global__ void loadFireStruct(int** mat,int elem)
{
    int index_x = threadIdx.x + blockIdx.x * blockDim.x;
    int stride_x = blockDim.x * gridDim.x;

    int index_y = threadIdx.y + blockIdx.y * blockDim.y;
    int stride_y = blockDim.y * gridDim.y;

    for (int i = index_x; i < elem; i += stride_x)
    {
        for (int j = index_y; j < elem; j += stride_y)
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
    
    int size = elem * elem * sizeof(int);

    int ** fireStruct;
    printf("fazendo malloc ...\n");
    checkCuda(cudaMallocManaged((void**)&fireStruct, size));
    
    printf("fazendo chaamando loadFireStruct ...\n");
    loadFireStruct<<<numberOfBlocks, threadsPerBlock>>>(fireStruct,elem);
    checkCuda(cudaGetLastError());
    checkCuda(cudaDeviceSynchronize());

    printf("fazendo chamando creatFireSource ...\n");
    creatFireSource<<<numberOfBlocks, threadsPerBlock>>>(fireStruct,elem);
    checkCuda(cudaGetLastError() );
    checkCuda(cudaDeviceSynchronize());

    while (1)
    {
        printf("fazendo chamando calculeteFirePropagation ...\n");
        calculeteFirePropagation<<<numberOfBlocks, threadsPerBlock>>>(fireStruct,elem);
        checkCuda(cudaGetLastError() );
        checkCuda(cudaDeviceSynchronize());

        printf("=================\n");
        prinrtMat(fireStruct,elem);
        //sleep(1);
    }
    printf("fazendo chamando cudaFree ...\n");
    checkCuda(cudaFree(fireStruct));

    return 0;
}