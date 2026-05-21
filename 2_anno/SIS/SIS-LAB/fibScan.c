#include <stdio.h>
#include <stdlib.h>

void fib(int n, int *p1){
    if(n <= 0){
        return;
    }
    int *pa = p1;
    int *pb = p1 + 1;
    
    *pa = 0;

    if(n == 1){
        return;
    }

    *pb = 1;

    for(int i = 2; i < n; i++){
        *(p1 + i) = *(pa) + *(pb);
        pa++;
        pb++;
    }
}

void print(int n, int *p1){
    for(int i = 0; i < n; i++){
        printf("%d \n", *(p1 + i));
    }
}

int main(int argc, char const *argv[]) {
    int n;
    scanf("%d \n", &n);
    int *p1 = (int *)calloc(n, sizeof(int)); //int *p1 = (int *)calloc(n, sizeof(int));
    fib(n, p1);
    print(n, p1);

    free(p1);
    return 0;
}