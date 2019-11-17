#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <GL/glut.h>
#include <cuda.h>

typedef struct Color 
{ 
   int red; 
   int green; 
   int blue; 
} Color_T;

Color_T ** colors;

Color_T * createColor(int red, int green, int blue)
{
    Color_T * color = malloc(sizeof(Color_T));
    color->red = red;
    color->green = green;
    color->blue = blue;
    return color;
}

Color_T ** createColorVector()
{
    colors = (Color_T **) malloc(sizeof(Color_T) * 37);
    colors[0]  = createColor(7, 7, 7);
    colors[1]  = createColor(31, 7, 7);
    colors[2]  = createColor(47, 15, 7);
    colors[3]  = createColor(71, 15, 7);
    colors[4]  = createColor(87, 23, 7);
    colors[5]  = createColor(103, 31, 7);
    colors[6]  = createColor(119, 31, 7);
    colors[7]  = createColor(143, 39, 7);
    colors[8]  = createColor(159, 47, 7);
    colors[9]  = createColor(175, 63, 7);
    colors[10] = createColor(191, 71, 7);
    colors[11] = createColor(199, 71, 7);
    colors[12] = createColor(223, 79, 7);
    colors[13] = createColor(223, 87, 7);
    colors[14] = createColor(223, 87, 7);
    colors[15] = createColor(215, 95, 7);
    colors[16] = createColor(215, 95, 7);
    colors[17] = createColor(215, 103, 15);
    colors[18] = createColor(207, 111, 15);
    colors[19] = createColor(207, 119, 15);
    colors[20] = createColor(207, 127, 15);
    colors[21] = createColor(207, 135, 23);
    colors[22] = createColor(199, 135, 23);
    colors[23] = createColor(199, 143, 23);
    colors[24] = createColor(199, 151, 31);
    colors[25] = createColor(191, 159, 31);
    colors[26] = createColor(191, 159, 31);
    colors[27] = createColor(191, 167, 39);
    colors[28] = createColor(191, 167, 39);
    colors[29] = createColor(191, 175, 47);
    colors[30] = createColor(183, 175, 47);
    colors[31] = createColor(183, 183, 47);
    colors[32] = createColor(183, 183, 55);
    colors[33] = createColor(207, 207, 111);
    colors[34] = createColor(223, 223, 159);
    colors[35] = createColor(239, 239, 199);
    colors[36] = createColor(255, 255, 255);
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

void updateFireIntensityPerPixel(int* fire, int line_length, int col_legth, int currentPixelIndex)
{
    int totalOfPixels = line_length * col_legth;
    int belowPixelIndex = currentPixelIndex + col_legth;

    if(belowPixelIndex >= totalOfPixels)
        return;

    int decay = rand() % 3;
    int decayIndex = rand() % 5 + (-2);
    int belowPixelFireIntensity = fire[belowPixelIndex];
    int newFireIntensity = belowPixelFireIntensity - decay >= 0 ? belowPixelFireIntensity - decay: 0;
    fire[currentPixelIndex - decayIndex] = newFireIntensity;
}

__global__ void updateFireIntensityPerPixelKernel(int* fire, int line_length, int col_legth, int currentPixelIndex)
{
    int totalOfPixels = line_length * col_legth;
    int belowPixelIndex = currentPixelIndex + col_legth;

    if(belowPixelIndex < totalOfPixels)
    {
        int decay = rand() % 3;
        int decayIndex = rand() % 5 + (-2);
        int belowPixelFireIntensity = fire[belowPixelIndex];
        int newFireIntensity = belowPixelFireIntensity - decay >= 0 ? belowPixelFireIntensity - decay: 0;
        fire[currentPixelIndex - decayIndex] = newFireIntensity;
    }
}

__global__ void calculeteFirePropagationKernel(int* fire, int line_length, int col_legth, size_t threadsPerBlock, size_t numberOfBlocks)
{
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    int stride = blockDim.x * gridDim.x;

    for (int i = index; i < n; i += stride) 
    {
        for (int j = index; j < n; j += stride)
        {
            int currentPixel = i * col_legth + j;
            updateFireIntensityPerPixelKernel<<<threadsPerBlock, numberOfBlocks>>>(fire, line_length, col_legth, currentPixel);

            cudaDeviceSynchronize();
        }
    }
}

void calculeteFirePropagation(int* fire, int line_length, int col_legth)
{
    for (int line = 0; line < line_length; line++)
    {
        for (int col = 0; col < col_legth; col++)
        {
            int currentPixel = line * col_legth + col;
            updateFireIntensityPerPixel(fire, line_length, col_legth, currentPixel);
        }
    }
}

int main()
{
  int deviceId;
  int numberOfSMs;

  cudaGetDevice(&deviceId);
  cudaDeviceGetAttribute(&numberOfSMs, cudaDevAttrMultiProcessorCount, deviceId);
  
  int num_elem_line = 40;
  int num_elem_col = 40;
  int num_elem_total = num_elem_line * num_elem_col;
  
  size_t size = num_elem_total * sizeof(int);
  int * fireStruct;

  cudaMallocManaged(&fireStruct, size);

  loadFireStruct(fireStruct, num_elem_line, num_elem_col);
  //colors = createColorVector();
  
  cudaMemPrefetchAsync(fireStruct, size, deviceId);

  size_t threadsPerBlock;
  size_t numberOfBlocks;

  threadsPerBlock = 256;
  numberOfBlocks = 32 * numberOfSMs;

  while (1)
  {
      calculeteFirePropagationKernel<<<numberOfBlocks, threadsPerBlock>>>(fireStruct, num_elem_line, num_elem_col, threadsPerBlock, numberOfBlocks);

      cudaDeviceSynchronize();

      prinrtMat(fireStruct, num_elem_line, num_elem_col);
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
