#include <stdio.h>
#include <stdlib.h>

void Swap(int *A, int i, int j){
    int tmp = A[i];
    A[i] = A[j];
    A[j] = tmp;
}

int Partition(int *A, int p, int q){
    int x = A[q];
    int i = p-1;
    for(int j = p; j < q; j++){
        if (A[j] <= x){
            i++;
            Swap(A, i, j);
        }
    }
    i++;
    Swap(A, i, q);
    return i;
}

void QuickSort(int *A, int low, int high){
    if (low < high){
        int r = Partition(A, low, high);
        QuickSort(A, low, r - 1);
        QuickSort(A, r + 1, high);
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
    scanArray(A);
    int size = scanArray(A);
    QuickSort(A, 0, size - 1);
    printArray(A, size);
    return 0;
}