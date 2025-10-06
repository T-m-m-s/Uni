#include <stdio.h>
#include <stdlib.h>

void CountingSort(int *A, int n) {
    // Caso base: se l'array è vuoto o di dimensione non valida, termina la funzione.
    if (n <= 0) return; 

    // Trova il valore massimo (M) e minimo (m) nell'array.
    int M = A[0], m = A[0];
    for (int i = 1; i < n; i++) {
        if (A[i] < m) m = A[i]; // Aggiorna il minimo.
        else if (A[i] > M) M = A[i]; // Aggiorna il massimo.
    }

    // Calcola l'intervallo dei valori (range) e alloca un array di conteggio.
    int range = M - m + 1;
    int *countA = (int*)calloc(range, sizeof(int)); // Inizializza l'array a 0.
    if (!countA) exit(1); // Termina il programma se l'allocazione fallisce.

    // Conta la frequenza di ciascun elemento nell'array originale.
    for (int i = 0; i < n; i++) {
        countA[A[i] - m]++; // Usa l'indice normalizzato (A[i] - m).
    }

    // Calcola i prefissi cumulativi per determinare le posizioni finali.
    for (int i = 1; i < range; i++) {
        countA[i] += countA[i - 1]; // Somma cumulativa.
    }

    // Alloca un array temporaneo per l'output ordinato.
    int *outputA = (int*)malloc(n * sizeof(int));
    if (!outputA) exit(1); // Termina il programma se l'allocazione fallisce.

    // Costruisce l'array ordinato iterando dall'ultimo elemento (stabile).
    for (int i = n - 1; i >= 0; i--) {
        outputA[countA[A[i] - m] - 1] = A[i]; // Posiziona l'elemento nella posizione corretta.
        countA[A[i] - m]--; // Decrementa il conteggio per gestire duplicati.
    }

    // Copia l'array ordinato nell'array originale.
    for (int i = 0; i < n; i++) {
        A[i] = outputA[i];
    }

    // Libera la memoria allocata dinamicamente.
    free(countA);
    free(outputA);
}

void printArray(int *a, int n) {
    for (int i = 0; i < n; i++)
        printf("%d ", a[i]);
}

#define MAX_LINE_SIZE 10000  // maximum size of a line of input

int scanArray(int *a) {
    // scan line of text
    char line[MAX_LINE_SIZE];
    scanf("%[^\n]", line);
    getchar();

    // convert text into array
    int size = 0, offset = 0, numFilled, n;
    do {
        numFilled = sscanf(line + offset, "%d%n", &(a[size]), &n);
        if (numFilled > 0) {
            size++;
            offset += n;
        }
    } while (numFilled > 0);

    return size;
}


int main() {
    int array[MAX_LINE_SIZE];
    
    // Legge l'array da input usando scanArray.
    int n = scanArray(array);

    // Ordina l'array usando QuickSort.
    CountingSort(array, n);

    // Stampa l'array ordinato usando printArray.
    printArray(array, n);
    printf("\n");

    return 0;
}
