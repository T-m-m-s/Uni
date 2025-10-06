#include <stdio.h>
#include <stdlib.h>

// Funzione per scambiare due elementi nell'array.
void Swap3w(int *A, int i, int j) {
    int tmp = A[i];
    A[i] = A[j];
    A[j] = tmp;
}

/*
 * Implementazione di QuickSort a tre vie (3-way QuickSort).
 * Questo approccio è particolarmente utile per array con molti elementi ripetuti.
 * La partizione a tre vie divide l'array in tre sezioni:
 * - Elementi minori del pivot.
 * - Elementi uguali al pivot.
 * - Elementi maggiori del pivot.
 * Questo riduce il numero di confronti e scambi per gli elementi uguali al pivot,
 * migliorando le prestazioni in caso di molti duplicati.
 */
void QuickSort3w(int *A, int low, int high) {
    if (low >= high) return; // Caso base: array con uno o zero elementi.

    int pivot = A[low]; // Sceglie il primo elemento come pivot.
    int lt = low;       // Indice per la sezione degli elementi minori del pivot.
    int gt = high;      // Indice per la sezione degli elementi maggiori del pivot.
    int i = low + 1;    // Indice per scansionare l'array.

    // Partizione a tre vie.
    while (i <= gt) {
        if (A[i] < pivot) { // Elemento minore del pivot.
            Swap3w(A, lt, i); // Sposta l'elemento nella sezione dei minori.
            lt++;
            i++;
        } else if (A[i] > pivot) { // Elemento maggiore del pivot.
            Swap3w(A, i, gt); // Sposta l'elemento nella sezione dei maggiori.
            gt--;
        } else { // Elemento uguale al pivot.
            i++;
        }
    }

    // Ordina ricorsivamente le sezioni sinistra e destra.
    QuickSort3w(A, low, lt - 1); // Ordina la parte sinistra (minori del pivot).
    QuickSort3w(A, gt + 1, high); // Ordina la parte destra (maggiori del pivot).
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
    QuickSort3w(array, 0, n - 1);

    // Stampa l'array ordinato usando printArray.
    printArray(array, n);
    printf("\n");

    return 0;
}
