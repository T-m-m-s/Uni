#include <stdio.h>
#include <stdlib.h>

void fibN(int *p1, int n){
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

// Verifica se un intero appare nell'array
int contiene(int *arr, int n, int valore) {
    for (int i = 0; i < n; i++) {
        if (*(arr + i) == valore) return 1;
    }
    return 0;
}

// Restituisce l'i-esimo elemento dell'array, oppure 0 se l'array ha meno di i elementi
int iesimo(int *arr, int n, int i) {
    if (i < n) return *(arr + i);
    return 0;
}

// Calcola la somma degli elementi di un array
int somma(int *arr, int n) {
    int s = 0;
    for (int i = 0; i < n; i++) {
        s += *(arr + i);
    }
    return s;
}

// Verifica se due array sono uguali
int array_uguali(int *arr1, int *arr2, int n1, int n2) {
    if (n1 != n2) return 0;
    for (int i = 0; i < n1; i++) {
        if (*(arr1 + i) != *(arr2 + i)) return 0;
    }
    return 1;
}

int main(int argc, char *argv[]) {
    int N = 10;
    int *fib = malloc(N * sizeof(int));
    fibN(fib, N);

    printf("Fibonacci: ");
    for (int i = 0; i < N; i++) {
        printf("%d ", *(fib + i));
    }
    printf("\n");

    int cerca = 13;
    printf("Il valore %d %s nell'array.\n", cerca, contiene(fib, N, cerca) ? "e' presente" : "non e' presente");

    int idx = 5;
    printf("L'elemento in posizione %d e': %d\n", idx, iesimo(fib, N, idx));

    printf("Somma degli elementi: %d\n", somma(fib, N));

    int altro[] = {0, 1, 1, 2, 3, 5, 8, 13, 21, 34};
    printf("Gli array sono %s.\n", array_uguali(fib, altro, N, 10) ? "uguali" : "diversi");

    free(fib);
    return 0;
}