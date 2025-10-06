#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <string.h>
#include <windows.h>
#include "countingSort.c"
#include "mergeSort.c"
#include "quickSort.c"
#include "quickSort3w.c"

#define SAMPLES 1000
#define REP 25
#define N_MIN 100
#define N_FIXED 10000
#define N_MAX 100000
#define M_MIN 10
#define M_FIXED 100000
#define M_MAX 1000000

// Funzione per riempire un array con numeri casuali in un determinato range
void fill_array(int *A, int size, int range) {
    for (int i = 0; i < size; i++)
        A[i] = rand() % range + 1;
}

// Funzione per ottenere il tempo corrente ad alta precisione usando QueryPerformanceCounter
double get_time() {
    static LARGE_INTEGER freq = {0};
    LARGE_INTEGER now;
    if (freq.QuadPart == 0) {
        QueryPerformanceFrequency(&freq); // Inizializza la frequenza una sola volta
    }
    QueryPerformanceCounter(&now);
    return (double)now.QuadPart / freq.QuadPart;
}

// Funzione per testare le prestazioni degli algoritmi variando la dimensione dell'array (n)
void test_n(){
    FILE *f = fopen("benchmark_n.csv", "w");
    if (!f) {
        printf("Error opening file for writing\n");
        exit(1); // Termina il programma se il file non può essere aperto
    }
    fprintf(f, "n,CountingSort,MergeSort,QuickSort,QuickSort3w\n");

    srand(time(NULL)); // Inizializza il generatore di numeri casuali
    double A = N_MIN;
    double B = pow((double)N_MAX / N_MIN, 1.0 / (SAMPLES - 1)); // Fattore di crescita geometrica
    double t_counting, t_merge, t_quick, t_quick3w;

    for (int i = 0; i < SAMPLES; i++) {
        int n = floor(A * pow(B, i)); // Calcola la dimensione corrente dell'array

        t_counting = 0.0;
        t_merge = 0.0;
        t_quick = 0.0;
        t_quick3w = 0.0;

        // Alloca memoria per gli array da ordinare
        int *A1 = malloc(n * sizeof(int));
        int *A2 = malloc(n * sizeof(int));
        int *A3 = malloc(n * sizeof(int));
        int *A4 = malloc(n * sizeof(int));

        for (int rep = 0; rep < REP; rep++) {
            // Riempie l'array con valori casuali e copia i dati negli altri array
            fill_array(A1, n, M_FIXED);
            memcpy(A2, A1, n * sizeof(int));
            memcpy(A3, A1, n * sizeof(int));
            memcpy(A4, A1, n * sizeof(int));

            if (!A1 || !A2 || !A3 || !A4) {
                printf("malloc failed for n = %d\n", n);
                exit(1); // Termina il programma se l'allocazione fallisce
            }

            // Misura il tempo di esecuzione di CountingSort
            double t_tmp = get_time();
            CountingSort(A1, n);
            t_counting += get_time() - t_tmp;

            // Misura il tempo di esecuzione di MergeSort
            t_tmp = get_time();
            MergeSort(A2, 0, n - 1);
            t_merge += get_time() - t_tmp;

            // Misura il tempo di esecuzione di QuickSort
            t_tmp = get_time();
            QuickSort(A3, 0, n - 1);
            t_quick += get_time() - t_tmp;

            // Misura il tempo di esecuzione di QuickSort a 3 vie
            t_tmp = get_time();
            QuickSort3w(A4, 0, n - 1);
            t_quick3w += get_time() - t_tmp;
        }

        // Libera la memoria allocata
        free(A1);
        free(A2);
        free(A3);
        free(A4);

        // Scrive i risultati nel file CSV
        fprintf(f, "%d,%.8f,%.8f,%.8f,%.8f\n", n, t_counting / REP,
            t_merge / REP, t_quick / REP, t_quick3w / REP);
    }
    fclose(f);
    printf("Benchmarking completed. Results saved to benchmark_n.csv\n");
}

// Funzione per testare le prestazioni degli algoritmi variando il range dei valori (m)
void test_m(){
    FILE *f = fopen("benchmark_m.csv", "w");

    if (!f) {
        printf("Error opening file for writing\n");
        exit(1); // Termina il programma se il file non può essere aperto
    }
    fprintf(f, "m,CountingSort,MergeSort,QuickSort,QuickSort3w\n");

    srand(time(NULL)); // Inizializza il generatore di numeri casuali
    double A = M_MIN;
    double B = pow((double)M_MAX / M_MIN, 1.0 / (SAMPLES - 1)); // Calcola il fattore di crescita geometrica
    double t_counting, t_merge, t_quick, t_quick3w;

    for (int i = 0; i < SAMPLES; i++) {
        int m = floor(A * pow(B, i)); // Calcola il range corrente dei valori

        t_counting = 0.0;
        t_merge = 0.0;
        t_quick = 0.0;
        t_quick3w = 0.0;

        // Alloca memoria per gli array da ordinare
        int *A1 = malloc(N_FIXED * sizeof(int));
        int *A2 = malloc(N_FIXED * sizeof(int));
        int *A3 = malloc(N_FIXED * sizeof(int));
        int *A4 = malloc(N_FIXED * sizeof(int));

        for (int rep = 0; rep < REP; rep++) {
            // Riempie l'array con valori casuali e copia i dati negli altri array
            fill_array(A1, N_FIXED, m);
            memcpy(A2, A1, N_FIXED * sizeof(int));
            memcpy(A3, A1, N_FIXED * sizeof(int));
            memcpy(A4, A1, N_FIXED * sizeof(int));

            if (!A1 || !A2 || !A3 || !A4) {
                printf("malloc failed for n = %d\n", N_FIXED);
                exit(1); // Termina il programma se l'allocazione fallisce
            }

            // Misura il tempo di esecuzione di CountingSort
            double t_tmp = get_time();
            CountingSort(A1, N_FIXED);
            t_counting += get_time() - t_tmp;

            // Misura il tempo di esecuzione di MergeSort
            t_tmp = get_time();
            MergeSort(A2, 0, N_FIXED - 1);
            t_merge += get_time() - t_tmp;

            // Misura il tempo di esecuzione di QuickSort
            t_tmp = get_time();
            QuickSort(A3, 0, N_FIXED - 1);
            t_quick += get_time() - t_tmp;

            // Misura il tempo di esecuzione di QuickSort a 3 vie
            t_tmp = get_time();
            QuickSort3w(A4, 0, N_FIXED - 1);
            t_quick3w += get_time() - t_tmp;
        }

        // Libera la memoria allocata
        free(A1);
        free(A2);
        free(A3);
        free(A4);

        // Scrive i risultati nel file CSV
        fprintf(f, "%d,%.8f,%.8f,%.8f,%.8f\n", m,
            t_counting / REP,
            t_merge / REP,
            t_quick / REP,
            t_quick3w / REP);
    }
    fclose(f);
    printf("Benchmarking completed. Results saved to benchmark_m.csv\n");
}

int main(void) {
    test_n(); // Testa le prestazioni variando n
    test_m();   // Testa le prestazioni variando m
    return 0;
}