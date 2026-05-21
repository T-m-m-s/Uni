#include <stdio.h>
#include <stdlib.h>

long fibonacci(int n) {
    if (n <= 0) return 0;
    if (n == 1) return 1;
    long a = 0, b = 1, temp;
    for (int i = 2; i <= n; i++) {
        temp = a + b;
        a = b;
        b = temp;
    }
    return b;
}

int main(int argc, char const *argv[])
{
    int i;
    
    printf("\nSono il comando %s\n", argv[0]);
    if(argc>1){
        printf("\nGli argomentisono:%d\n", argc-1);
        for (i = 1; i < argc; i++){
            printf("argomento %d:%s\n",i,argv[i]);
        }
    } else {
        printf("Non ci sono argomenti\n");
    }
    return 0;
}
