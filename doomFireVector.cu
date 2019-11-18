#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <GL/glut.h>
#include <curand.h>
#include <curand_kernel.h>
#include <cuda.h>

typedef struct Color 
{ 
    float red; 
    float green; 
    float blue; 
} Color_T;

Color_T ** colors;
int * fireStruct;
int line_length, col_legth, width, height, num_elem_total;
Color_T * createColor(float red, float green, float blue)
{
    int instesity =200;
    Color_T * color =(Color_T *) malloc(sizeof(Color_T));
    color->red = red / instesity;
    color->green = green / instesity;
    color->blue = blue / instesity;
    return color;
}

Color_T ** createColorVector()
{
    
    colors = (Color_T**) malloc(sizeof(Color_T)*37);
    colors[0]  = createColor(7.0f, 7.0f, 7.0f);
    colors[1]  = createColor(31.0f, 7.0f, 7.0f);
    colors[2]  = createColor(47.0f, 15.0f, 7.0f);
    colors[3]  = createColor(71.0f, 15.0f, 7.0f);
    colors[4]  = createColor(87.0f, 23.0f, 7.0f);
    colors[5]  = createColor(103.0f, 31.0f, 7.0f);
    colors[6]  = createColor(119.0f, 31.0f, 7.0f);
    colors[7]  = createColor(143.0f, 39.0f, 7.0f);
    colors[8]  = createColor(159.0f, 47.0f, 7.0f);
    colors[9]  = createColor(175.0f, 63.0f, 7.0f);
    colors[10] = createColor(191.0f, 71.0f, 7.0f);
    colors[11] = createColor(199.0f, 71.0f, 7.0f);
    colors[12] = createColor(223.0f, 79.0f, 7.0f);
    colors[13] = createColor(223.0f, 87.0f, 7.0f);
    colors[14] = createColor(223.0f, 87.0f, 7.0f);
    colors[15] = createColor(215.0f, 95.0f, 7.0f);
    colors[16] = createColor(215.0f, 95.0f, 7.0f);
    colors[17] = createColor(215.0f, 103.0f, 15.0f);
    colors[18] = createColor(207.0f, 111.0f, 15.0f);
    colors[19] = createColor(207.0f, 119.0f, 15.0f);
    colors[20] = createColor(207.0f, 127.0f, 15.0f);
    colors[21] = createColor(207.0f, 135.0f, 23.0f);
    colors[22] = createColor(199.0f, 135.0f, 23.0f);
    colors[23] = createColor(199.0f, 143.0f, 23.0f);
    colors[24] = createColor(199.0f, 151.0f, 31.0f);
    colors[25] = createColor(191.0f, 159.0f, 31.0f);
    colors[26] = createColor(191.0f, 159.0f, 31.0f);
    colors[27] = createColor(191.0f, 167.0f, 39.0f);
    colors[28] = createColor(191.0f, 167.0f, 39.0f);
    colors[29] = createColor(191.0f, 175.0f, 47.0f);
    colors[30] = createColor(183.0f, 175.0f, 47.0f);
    colors[31] = createColor(183.0f, 183.0f, 47.0f);
    colors[32] = createColor(183.0f, 183.0f, 55.0f);
    colors[33] = createColor(207.0f, 207.0f, 111.0f);
    colors[34] = createColor(223.0f, 223.0f, 159.0f);
    colors[35] = createColor(239.0f, 239.0f, 199.0f);
    colors[36] = createColor(255.0f, 255.0f, 255.0f);
    return colors;
}

void loadFireStruct(int* fire, int line_length, int col_legth)
{
    for (int line = 0; line < line_length; line++)
    {
        for (int col = 0; col < col_legth; col++)
        {
            int index = line * col_legth + col;
            if(line == line_length - 1)
                fire[index] = 36;
            else
                fire[index] = 0;
        }
    }
}

void prinrtMat(int* fire,int line_length, int col_legth){
    for (int line = 0; line < line_length; line++){
        printf("[ ");
        for (int col = 0; col < col_legth; col++){
            int index = line * col_legth + col;
            int num = fire[index];
            if(num<10)
                printf("0%d ", num);
            else
                printf("%d ", num);
        }
        printf("]\n");
    }
}


__device__ void updateFireIntensityPerPixelKernel(int* fire, int line_length, int col_legth, int currentPixelIndex)
{
    int totalOfPixels = line_length * col_legth;
    int belowPixelIndex = currentPixelIndex + col_legth;

    if(belowPixelIndex < totalOfPixels)
    {   float num_randf = 0.0f;  
        long int num;
        curandState state;
        curand_init(1234, currentPixelIndex,2, &state);

        num_randf = curand_uniform(&state);
        num = (long int) (num_randf*100);
        int decay =(int) (num %3);
        printf("decay => %d\n",decay);
        int decayIndex =(int) (num % 5 + (-2));
        int belowPixelFireIntensity = fire[belowPixelIndex];
        int newFireIntensity = belowPixelFireIntensity - decay >= 0 ? belowPixelFireIntensity - decay: 0;
        fire[currentPixelIndex - decayIndex] = newFireIntensity;
    }
}

__global__ void calculeteFirePropagationKernel(int* fire, int line_length, int col_legth, size_t threadsPerBlock, size_t numberOfBlocks, int n)
{
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    if(n>index){
        printf("index %d\n",index);
        int stride = blockDim.x * gridDim.x;
        printf("stride %d\n",stride);
        int currentPixel = index;
        printf("Pixel %d\n",currentPixel);
        updateFireIntensityPerPixelKernel(fire, line_length, col_legth, currentPixel);
    }
   
}

int main()
{
  int deviceId;
  int numberOfSMs;

  cudaGetDevice(&deviceId);
  cudaDeviceGetAttribute(&numberOfSMs, cudaDevAttrMultiProcessorCount, deviceId);
  
  int num_elem_line = 10;
  int num_elem_col = 10;
  int num_elem_total = num_elem_line * num_elem_col;
  
  size_t size = num_elem_total * sizeof(int);

  cudaMallocManaged(&fireStruct, size);

  loadFireStruct(fireStruct, num_elem_line, num_elem_col);
  //colors = createColorVector();
  
  cudaMemPrefetchAsync(fireStruct, size, deviceId);

  size_t threadsPerBlock;
  size_t numberOfBlocks;

  threadsPerBlock = 32;
  numberOfBlocks = 32 * numberOfSMs;
  char ch;
  while (1)
  {
      calculeteFirePropagationKernel<<<numberOfBlocks, threadsPerBlock>>>(fireStruct, num_elem_line, num_elem_col, threadsPerBlock, numberOfBlocks,num_elem_total);

      cudaDeviceSynchronize();

      prinrtMat(fireStruct, num_elem_line, num_elem_col);
      scanf("%c", &ch);
  }

  cudaFree(fireStruct);
}

/*
int main(int argc, int *argv[])
{
    int num_elem_line = 40;
    int num_elem_col = 40;
    int num_elem_total = num_elem_line * num_elem_col;
    fireStruct = (int*) malloc(sizeof(int) * num_elem_total);
    loadFireStruct(fireStruct, num_elem_line, num_elem_col);
    colors = createColorVector();
    int ch;
    while (1)
    {
        calculeteFirePropagation(fireStruct, num_elem_line, num_elem_col);
        prinrtMat(fireStruct, num_elem_line, num_elem_col);
        scanf("%c", &ch);
    }    
    free(fireStruct);
} 
*/
