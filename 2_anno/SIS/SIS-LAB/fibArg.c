#include <stdio.h>
#include <stdlib.h>

long fibonacci(int n) {
    if (n <= 0) return 0;
    if (n == 1) return 1;
    long a = 0, b = 1, temp;
    for (int i = 2; i <= n; i++) {
        temp = a + b;
        a = b;
        b = temp;
    }
    return b;
}

int main(int argc, char const *argv[]) {
    if (argc < 2) {
        printf("Uso: %s <numero1> <numero2> ...\n", argv[0]);
        return 1;
    }

    for (int i = 1; i < argc; i++) {
        char *endptr;
        long n = strtol(argv[i], &endptr, 10);

        if (*endptr != '\0' || argv[i][0] == '\0') {
            printf("L'argomento \"%s\" non è un intero valido.\n", argv[i]);
            continue;
        }
        if (n < 0) {
            printf("Inserire un intero non negativo per \"%s\".\n", argv[i]);
            continue;
        }
        printf("Fibonacci(%ld) = %ld\n", n, fibonacci((int)n));
    }
    return 0;
}