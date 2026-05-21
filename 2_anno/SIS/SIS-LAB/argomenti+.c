#include <stdio.h>
#include <stdlib.h>

int main(int argc, char const *argv[])
{
    // Parte 1
    if(argc != 4) {
        printf("Uso: %s <numero1> <numero2> ...\n", argv[0]);
        return 1;
    }

    for (int i = 1; i < argc; i++)
    {
        
        printf("Elemento %d: %s\n", i, argv[i]);
    }
    
    // Parte 2
    int total_len = 1; // per '\0'
    for (int i = 1; i < argc; i++) {
        total_len += strlen(argv[i]);
    }

    char *str = (char *)calloc(total_len, sizeof(char));
    if (!str) {
        printf("Errore di allocazione memoria.\n");
        return 1;
    }

    strcpy(str, argv[1]);
    for (int i = 2; i < argc; i++) {
        strcat(str, argv[i]);
    }

    printf("Concatenazione: %s\n", str);

    free(str);
    return 0;
}
