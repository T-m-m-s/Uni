#include <stdio.h>
#include <stdlib.h>

void merge(int *A, int low, int middle, int high){
    int i, j, k;
    int n1 = middle - low + 1;
    int n2 = high - middle;
    
    int *L = (int *)malloc(n1 * sizeof(int));
    int *H = (int *)malloc(n2 * sizeof(int));

    for (i = 0; i < n1; i++) {
        L[i] = A[low + i];
    }
    for (j = 0; j < n2; j++) {
        H[j] = A[middle + 1 + j];
    }
    
    i = 0;
    j = 0;
    k = low;

    while (i < n1 && j < n2) {
        if (L[i] <= H[j]) {
            A[k] = L[i];
            i++;
        } else {
            A[k] = H[j];
            j++;
        }
        k++;
    }

    while (i < n1) {
        A[k] = L[i];
        i++;
        k++;
    }

    while (j < n2) {
        A[k] = H[j];
        j++;
        k++;
    }
}

void MergeSort(int *A, int low, int high){
    if (low < high) {
        int middle = low + (high - low) / 2;

        MergeSort(A, low, middle);
        MergeSort(A, middle + 1, high);

        merge(A, low, middle, high);
    }
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

void printArray(int *a, int n) {
    for (int i = 0; i < n; i++)
        printf("%d ", a[i]);
}

int main(int argc, char const *argv[])
{
    int *A = (int *)malloc(sizeof(int) * MAX_LINE_SIZE);
    int size = scanArray(A);
    MergeSort(A, 0, size - 1);
    printArray(A, size);
    return 0;
}