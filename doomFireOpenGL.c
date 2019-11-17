#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <GL/glut.h>

typedef struct Color 
{ 
   float red; 
   float green; 
   float blue; 
} Color_T;

Color_T** colors;

int* fireStruct;

int line_length, col_legth, width, height, num_elem_total;

Color_T* createColor(float red, float green, float blue)
{
    int instesity =200;
    Color_T * color = malloc(sizeof(Color_T));
    color->red = red / instesity;
    color->green = green / instesity;
    color->blue = blue / instesity;
    return color;
}

Color_T** createColorVector()
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

void prinrtMat(int* fire, int line_length, int col_legth)
{
    for (int line = 0; line < line_length; line++)
    {
        printf("[ ");
        for (int col = 0; col < col_legth; col++)
        {
            int index = line * col_legth + col;
            int num = fire[index];
            if(num < 10)
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

void calculeteFirePropagation()
{
    for (int line = 0; line < line_length; line++)
    {
        for (int col = 0; col < col_legth; col++)
        {
            int currentPixel = line * col_legth + col;
            updateFireIntensityPerPixel(fireStruct, line_length, col_legth, currentPixel);
        }
    }
    glutPostRedisplay();
    glutTimerFunc(100, calculeteFirePropagation, 1);
}

void init(void)
{
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glViewport(0, 0, width, height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);     // Select The Modelview Matrix
    glLoadIdentity();
    glOrtho (0, width, 0, height, -1 , 1);
}

void display(void)
{
    glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    width = glutGet(GLUT_WINDOW_WIDTH);
    height = glutGet(GLUT_WINDOW_HEIGHT);
    glViewport(0, 0, width, height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);     // Select The Modelview Matrix
    glLoadIdentity();
    glOrtho (0, width, 0, height, -1 ,1);
    float aspect = width / height;
    //glPolygonMode(GL_BACK, GL_LINE);
    float squareWidth =  (float)width / (float)col_legth;
    float squareHeight =  (float)height / (float)line_length;
    
    for (int line = line_length - 1; line > - 1; line--)
    {
        for (int col = 0; col < col_legth; col++)
        {
            int index = line * col_legth + col;
            float thisSquareWidth = squareWidth * (col + 1);
            float lastSquareWidth = thisSquareWidth - squareWidth;
            int heightOffset = line_length - line;
            float thisSquareHeight = squareHeight * (heightOffset);
            float lastSquareHeight = thisSquareHeight - squareHeight;

            int fireIntensity = fireStruct[index];
            Color_T* color = colors[fireIntensity];
            glColor3f(color->red, color->green, color->blue);
            glBegin(GL_QUADS);
            glVertex3f(thisSquareWidth, thisSquareHeight, 0.0); //top rigt
            glVertex3f(lastSquareWidth, thisSquareHeight, 0.0); //top left
            glVertex3f(lastSquareWidth, lastSquareHeight, 0.0); // botton left
            glVertex3f(thisSquareWidth, lastSquareHeight, 0.0);// botton right
            glEnd();
        }
    }
	glFlush();
    glutSwapBuffers();
 }

void keyboard(unsigned char key, int x, int y)
{
  switch (key)
  {
    case 27:
	    exit(0);
	break;
  }
}

int main(int argc, char** argv)
{
    int num_elem_line = 40;
    int num_elem_col = 40;
    line_length = 40;
    col_legth = 40;
    width = 1280;
    height = 720;
    num_elem_total = num_elem_line * num_elem_col;
    
    fireStruct = (int*) malloc(sizeof(int) * num_elem_total);
    loadFireStruct(fireStruct, num_elem_line, num_elem_col);
    colors =createColorVector();
    
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);
    glutInitWindowSize (width, height);
    glutInitWindowPosition (100, 100); 
    glutCreateWindow ("DOOM FIRE");
    init();
    glutDisplayFunc(display);
    glutTimerFunc(100, calculeteFirePropagation, 1);
    glutKeyboardFunc(keyboard);
    glutMainLoop();
} 
