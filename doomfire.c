#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include<GL/glut.h>


void myInit (void) 
{ 
    // making background color black as first  
    // 3 arguments all are 0.0 
    glClearColor(0.0, 0.0, 0.0, 1.0); 
      
    // making picture color green (in RGB mode), as middle argument is 1.0 
    glColor3f(0.0, 1.0, 0.0); 
      
    // breadth of picture boundary is 1 pixel 
    glPointSize(1.0); 
    glMatrixMode(GL_PROJECTION);  
    glLoadIdentity(); 
      
    // setting window dimension in X- and Y- direction 
    gluOrtho2D(-780, 780, -420, 420); 
} 

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

void printMatOpenGL(int** mat,int elem){
    for (int i = 0; i < elem; i++){
        for (int j = 0; j < elem; j++){
            int num =mat[i][j];
            if(num>10)
                glVertex2i(i * 5, j * 5);
            
        }
    }
}

void updateFireIntensityPerPixelSimple(int** mat,int tam ,int posX, int posY){
    int belowPosx = posX;
    if(posX<tam-1)
        belowPosx++;
    int decay = rand() % 3;
    
    int decayPosX = rand() % 3;

    int belowPixelFireIntensity = mat[belowPosx][posY];
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
/*
int main(int argc, char *argv[]){
    int elem = 40;
    int ** fireStruct =(int *) malloc(sizeof(int)*elem*elem);
    for (int i = 0; i < elem; i++)
        fireStruct[i] = (int *) malloc(sizeof(int)*elem);
    
    while (1){
        loadFireStruct(fireStruct,elem);
        creatFireSource(fireStruct,elem);
        calculeteFirePropagation(fireStruct,elem);
        printf("=================\n");
        prinrtMat(fireStruct,elem);
        sleep(1);
    }
    return 0;
}
*/

void display (void)  
{ 
    //glClear(GL_COLOR_BUFFER_BIT); 
    //glBegin(GL_POINTS); 
    
    int elem = 400;
    int ** fireStruct =(int *) malloc(sizeof(int)*elem*elem);
    for (int i = 0; i < elem; i++)
        fireStruct[i] = (int *) malloc(sizeof(int)*elem);
    
    while (1)
    {
    
        glClear(GL_COLOR_BUFFER_BIT); 
        glBegin(GL_POINTS); 

        loadFireStruct(fireStruct,elem);
        creatFireSource(fireStruct,elem);
        calculeteFirePropagation(fireStruct,elem);
        printMatOpenGL(fireStruct,elem);
        //printf("=================\n");
        //prinrtMat(fireStruct,elem);
        //sleep(1);

        // iterate y up to 2*pi, i.e., 360 degree 
        // with small increment in angle as 
        // glVertex2i just draws a point on specified co-ordinate 
        //for ( i = 0; i < (2 * pi); i += 0.001) 
        //{ 
            // let 200 is radius of circle and as, 
            // circle is defined as x=r*cos(i) and y=r*sin(i) 
            //x = 200 * cos(i); 
            //y = 200 * sin(i); 
            
            //glVertex2i(x, y); 
        //} 
        glEnd(); 
        glFlush(); 

    }
} 

int main (int argc, char** argv) 
{ 
    glutInit(&argc, argv); 
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB); 
      
    // giving window size in X- and Y- direction 
    glutInitWindowSize(400, 300); 
    glutInitWindowPosition(0, 0); 
      
    // Giving name to window 
    glutCreateWindow("Doom Fire 2d"); 
    myInit(); 
      
    glutDisplayFunc(display); 
    glutMainLoop(); 
} 