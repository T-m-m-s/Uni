#include <stdio.h>
#include <stdlib.h>

void Swap3w(int *A, int i, int j){
    int tmp = A[i];
    A[i] = A[j];
    A[j] = tmp;
}

void QuickSort3w(int *A, int low, int high){
    if (low >= high) return;

    int pivot = A[low];
    int lt = low;
    int gt = high;
    int i = low + 1;

    while(i <= gt){
        if (A[i] < pivot){
            Swap3w(A, lt, i);
            lt++;
            i++;
        } else if (A[i] > pivot){
            Swap3w(A, i, gt);
            gt--;
        } else {
            i++;
        }
    }

    QuickSort3w(A, low, lt - 1);
    QuickSort3w(A, gt + 1, high);
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
    QuickSort3w(A, 0, size - 1);
    printArray(A, size);
    return 0;
}