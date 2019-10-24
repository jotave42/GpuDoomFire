#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>

void prinrtMat(int** mat,int elem){
    for (int i = 0; i < elem; i++){
        printf("[ ");
        for (int j = 0; j < elem; j++){
            int num =mat[i][j];
            if(num<10)
                printf("0%d ",num);
            else
                printf("%d ",num);
        }
        printf("]\n");
    }
}

void updateFireIntensityPerPixelSimple(int** mat,int tam ,int posX, int posY){
    int belowPosX = posX;
    if(posX<tam-1)
        belowPosX++;
    int decay = rand() % 3;

    int decayPosY = rand() % 5 + (-2);//random number between -3 and 3
    
    int belowPosY = posY + decayPosY;
    if(belowPosY<0){
        if(posX>0){
            posX --;
            belowPosY = tam-1+belowPosY;
   //         printf("newPosY %d\n", belowPosY);
        }else
            belowPosY=0;
    }else if(belowPosY>tam-1){
        if(posX<tam-1){
            posX ++;
            belowPosY = belowPosY -tam-1;
        //    printf("newPosY %d\n", belowPosY);
        }else
            belowPosY =tam-1;
        
    }
    int belowPixelFireIntensity = mat[belowPosX][belowPosY];
    int newFireIntensity = belowPixelFireIntensity - decay >= 0 ? belowPixelFireIntensity - decay: 0;

    mat[posX][posY]=newFireIntensity;

}
void updateFireIntensityPerPixel(int** mat,int elem ,int posX, int posY){
    int belowPosX = posX+1;
    if(belowPosX == elem-1);
        belowPosX = posX;
    int belowPosY = posY;
    int decay = rand() % 3;
    //printf("decay -> %d\n",decay);
    
    int decayPosX = rand() % 3;
    int decayPosY = rand() % 3;
    //printf("decayPosX -> %d\n",decayPosX);
    //printf("decayPosY -> %d\n",decayPosY);
    int belowPixelFireIntensity = mat[belowPosX][belowPosY];
    int newFireIntensity = belowPixelFireIntensity - decay >= 0 ? belowPixelFireIntensity - decay: 0;

    int newPosX = belowPosX + decayPosX < elem ? belowPosX + decayPosX: belowPosX;
    int newPosY = 0;
    if(newPosY+decayPosY< elem){
        newPosY =newPosY+decayPosY;
    }else{
        if(newPosX +1 <elem-2){
            newPosX++;
            newPosY =newPosY+decayPosY;
        }
        else
            newPosY =elem-1;
    }
    printf("mat[%d][%d]=%d\n",newPosX,newPosY,newFireIntensity);
    if(newPosX<elem-1);
        mat[newPosX][newPosY]=newFireIntensity;

}
void calculeteFirePropagation(int** mat,int elem){
    for (int i = elem-2; i >=0; i--){
        for (int j = 0; j < elem; j++){
            updateFireIntensityPerPixelSimple(mat,elem ,i, j);
        }
    }
}
void creatFireSource(int** mat,int elem){
    int lestLine =elem-1;
    for (int j = 0; j < elem; j++)
        mat[lestLine][j]= 36;
}
int loadFireStruct(int** mat,int elem){
    for (int i = 0; i < elem; i++)
        for (int j = 0; j < elem; j++)
            mat[i][j]=0;
    
    return 0;
}

int main(int argc, char *argv[]){
    int elem = 40;
    int ** fireStruct =(int *) malloc(sizeof(int)*elem*elem);
    for (int i = 0; i < elem; i++)
        fireStruct[i] = (int *) malloc(sizeof(int)*elem);
    loadFireStruct(fireStruct,elem);
    creatFireSource(fireStruct,elem);
    while (1){
        calculeteFirePropagation(fireStruct,elem);
        printf("=================\n");
        prinrtMat(fireStruct,elem);
        sleep(1);
    }
    return 0;
}