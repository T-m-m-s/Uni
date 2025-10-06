#include <stdio.h>
#include <stdlib.h>

void CountingSort(int *A, int n) {
    if (n <= 0) return;

    int M = A[0], m = A[0];
    for (int i = 1; i < n; i++) {
        if (A[i] < m) m = A[i];
        else if (A[i] > M) M = A[i];
    }

    int range = M - m + 1;
    int *countA = (int*)calloc(range, sizeof(int));
    if (!countA) exit(1);

    for (int i = 0; i < n; i++) {
        countA[A[i] - m]++;
    }

    for (int i = 1; i < range; i++) {
        countA[i] += countA[i - 1];
    }

    int *outputA = (int*)malloc(n * sizeof(int));
    if (!outputA) exit(1);

    for (int i = n - 1; i >= 0; i--) {
        outputA[countA[A[i] - m] - 1] = A[i];
        countA[A[i] - m]--;
    }

    for (int i = 0; i < n; i++) {
        A[i] = outputA[i];
    }

    free(countA);
    free(outputA);
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
    CountingSort(A, size);
    printArray(A, size);
    return 0;
}