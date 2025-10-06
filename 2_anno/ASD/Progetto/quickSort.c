#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Funzione per scambiare due elementi nell'array.
void Swap(int *A, int i, int j) {
    int tmp = A[i];
    A[i] = A[j];
    A[j] = tmp;
}

// Funzione per partizionare l'array nella versione classica di QuickSort.
int Partition(int *A, int p, int q) {
    int x = A[q]; // Sceglie l'ultimo elemento come pivot.
    int i = p - 1; // Indice per gli elementi minori del pivot.

    // Partiziona l'array in base al pivot.
    for (int j = p; j < q; j++) {
        if (A[j] < x) { // Elemento minore del pivot.
            i++;
            Swap(A, i, j); // Sposta l'elemento nella parte sinistra.
        }
    }
    i++;
    Swap(A, i, q); // Posiziona il pivot nella posizione corretta.
    return i; // Restituisce l'indice del pivot.
}

// Implementazione di QuickSort con Partition.
void QuickSort(int *A, int low, int high) {
    if (low < high) { // Continua solo se ci sono almeno due elementi.
        int r = Partition(A, low, high); // Partiziona l'array e ottiene il pivot.
        QuickSort(A, low, r - 1); // Ordina la parte sinistra.
        QuickSort(A, r + 1, high); // Ordina la parte destra.
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
    QuickSort(array, 0, n - 1);

    // Stampa l'array ordinato usando printArray.
    printArray(array, n);
    printf("\n");

    return 0;
}
