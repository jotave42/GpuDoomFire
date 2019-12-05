#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
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
int main(int argc, char *argv[]){
    int num_elem_line = 5;
    int num_elem_col = 5;
    int num_elem_total = num_elem_line +num_elem_col;
    int * fireStruct = (int*) malloc(sizeof(int)*num_elem_total);
    for (int line = 0; line < num_elem_line; line++){
        for (int col = 0; col < num_elem_col; col++){
            int index =line*num_elem_col + col;
            //printf("endereco : %d\nindex: %d\nvalor: %d\n",&fireStruct[index],index,fireStruct[index]);
            //printf("=============================\n");
        }
    }
    //printf("\n\n============LOAD================\n\n\n");
    loadFireStruct(fireStruct,num_elem_line,num_elem_col);
    //printf("Load Fire Struct COMPLETE\n");
    //printf("\n\n============printig================\n\n\n");
    prinrtMat(fireStruct,num_elem_line,num_elem_col);
    free(fireStruct);
} 
