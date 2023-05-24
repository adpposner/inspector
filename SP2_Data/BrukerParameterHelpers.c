//Regex parsing for Bruker acqp file

//Lines start with ##$,param name, =, then value
#include <regex.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


struct matrixDimensions{
    unsigned int ndims;
    unsigned int x,y,z;
};

void printDimensions(FILE * fh,struct matrixDimensions *d){
    fprintf(fh,"%d: %d,%d,%d\n",d->ndims,d->x,d->y,d->z);
}

int parseKeyValueLine(const char * line, char * key, char * value){
    int res = 0;
    res = sscanf(line,"##$%[^=]=%[^\n]",key,value);
    return res;
}

//Parse a set of dimensions -  it should be a string with values, comma-separated, inside parentheses
int getDimensions(const char * str, struct matrixDimensions * dims){
    int res = 0;
    dims->ndims = dims->x = dims->y = dims->z = 0;
    char insideParens[255];
    char * s = insideParens;
    char * token;
    //get data inside parenthesis
    sscanf(str," (%250[^)])]",insideParens);
    printf("%s\n%s",insideParens,str);
    //tokenization - 1,2,3
    if ((token=strtok_r(s,",",&s)))
    {
        dims->x = strtol(token,NULL,10);
        dims->ndims = 1;
        if ((token=strtok_r(s,",",&s)))
        {    
            dims->y = strtol(token,NULL,10);
            dims->ndims = 2;
            if ((token=strtok_r(s,",",&s)))
                {
                    dims->z = strtol(token,NULL,10);
                    dims->ndims = 3;
                }
        }
    }
    return res;

}



int main(){
    char lines[] = "##$ACQ_RfShapes=( 64, 220 )\n";
    char key[25];
    char value[25];
    int res;
    res = parseKeyValueLine(lines,key,value);
    struct matrixDimensions d;
    getDimensions(value,&d);
    printDimensions(stdout,&d);
    return res;
}
