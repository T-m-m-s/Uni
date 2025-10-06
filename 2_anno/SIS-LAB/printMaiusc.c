#include <stdio.h>
#include <stdlib.h>

int main(int argc, char const *argv[])
{
    for(int i = 1; i < argc; i++){
        if(argv[i][0] > 64 && argv[i][0] < 91)
            printf("Argomento %d: %s\n", i, argv[i]);
    }
    return 0;
}