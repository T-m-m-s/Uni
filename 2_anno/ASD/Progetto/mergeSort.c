#include <stdio.h>
#include <stdlib.h>

void merge(int *A, int low, int middle, int high) {
    int i, j, k;
    int n1 = middle - low + 1; // Dimensione del sottoarray sinistro.
    int n2 = high - middle;    // Dimensione del sottoarray destro.
    
    // Alloca memoria per i due sottoarray (L = lower e H = higher).
    int *L = (int *)malloc(n1 * sizeof(int));
    int *H = (int *)malloc(n2 * sizeof(int));

    for (i = 0; i < n1; i++) {    // Copia i dati nel sottoarray sinistro (L).
        L[i] = A[low + i];
    }
    for (j = 0; j < n2; j++) {    // Copia i dati nel sottoarray destro (H).
        H[j] = A[middle + 1 + j];
    }
    
    i = 0; // Indice per il sottoarray sinistro.
    j = 0; // Indice per il sottoarray destro.
    k = low; // Indice per l'array principale.

    while (i < n1 && j < n2) {    // Confronta e unisce i due sottoarray in ordine crescente.
        if (L[i] <= H[j]) { // Se l'elemento in L è minore o uguale.
            A[k] = L[i];
            i++;
        } else { // Altrimenti, prendi l'elemento in H.
            A[k] = H[j];
            j++;
        }
        k++;
    }
    
    while (i < n1) {    // Copia gli elementi rimanenti del sottoarray sinistro (se presenti).
        A[k] = L[i];
        i++;
        k++;
    }
    
    while (j < n2) {    // Copia gli elementi rimanenti del sottoarray destro (se presenti).
        A[k] = H[j];
        j++;
        k++;
    }

    free(L);    // Libera la memoria allocata per sottoarray L.
    free(H);    // Libera la memoria allocata per sottoarray.
}

void MergeSort(int *A, int low, int high) {
    if (low < high) { // Condizione base: continua solo se ci sono almeno due elementi.
        int middle = low + (high - low) / 2; // Calcola il punto medio per dividere l'array.

        MergeSort(A, low, middle);      // Ordina ricorsivamente la metà sinistra.
        MergeSort(A, middle + 1, high); // Ordina ricorsivamente la metà destra.
        merge(A, low, middle, high);    // Unisce le due metà ordinate.

    }
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
    MergeSort(array, 0, n - 1);

    // Stampa l'array ordinato usando printArray.
    printArray(array, n);
    printf("\n");

    return 0;
}
