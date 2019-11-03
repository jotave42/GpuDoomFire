#include <stdio.h>
#include <stdlib.h>
#include <time.h>
void loadFireStruct(int* fire,int line_length, int col_legth){
    for (int line = 0; line < line_length; line++){
        for (int col = 0; col < col_legth; col++){
            int index =line*col_legth + col;
            if(line == line_length-1)
                fire[index]=36;
            else
                fire[index]=0;
            //printf("endereco : %d\nindex: %d\nvalor: %d\n",&fire[index],index,fire[index]);
            //printf("=============================\n");
        }
    }
    
}
void prinrtMat(int* fire,int line_length, int col_legth){
    for (int line = 0; line < line_length; line++){
        printf("[ ");
        for (int col = 0; col < col_legth; col++){
            int index =line*col_legth + col;
            //printf("index: %d ->",index);
            int num =fire[index];
            if(num<10)
                printf("0%d ",num);
            else
                printf("%d ",num);
        }
        printf("]\n");
    }
}
void updateFireIntensityPerPixel(int* fire,int line_length, int col_legth, int currentPixelIndex){
    int totalOfPixels = line_length * col_legth;
    int belowPixelIndex = currentPixelIndex +col_legth;
    if(belowPixelIndex >= totalOfPixels){
        return;
    }
    int decay = 1;
    int decayIndex =0;
    int belowPixelFireIntensity =fire[belowPixelIndex];
    int newFireIntensity = belowPixelFireIntensity - decay >= 0 ? belowPixelFireIntensity - decay: 0;
    fire[currentPixelIndex - decayIndex] = newFireIntensity;



}
void calculeteFirePropagation(int* fire,int line_length, int col_legth){
    for (int line = 0; line < line_length; line++){
        for (int col = 0; col < col_legth; col++){
            int currentPixel =line*col_legth + col;
            updateFireIntensityPerPixel(fire,line_length,col_legth,currentPixel);
        }
    }
}
int main(int argc, char *argv[]){
    int num_elem_line = 40;
    int num_elem_col = 40;
    int num_elem_total = num_elem_line *num_elem_col;
    int* fireStruct = (int*) malloc(sizeof(int)*num_elem_total);
    //printf("\n\n============LOAD================\n\n\n");    
    loadFireStruct(fireStruct,num_elem_line,num_elem_col);
    //printf("Load Fire Struct COMPLETE\n");
    //printf("\n\n============printig================\n\n\n");
    char ch;
    while (1)
    {
        calculeteFirePropagation(fireStruct,num_elem_line,num_elem_col);
        prinrtMat(fireStruct,num_elem_line,num_elem_col);  
        scanf("%c",&ch);
    }
    
    free(fireStruct);
} 
