#include <stdio.h>
#include <stdlib.h>

typedef struct numComp
{
    float intera;
    float immaginaria;
} numComp;

enum tipo_di_numero { INTERO, REALE, REALEDOPPIO, COMPLESSO} ;
struct numero {
    enum tipo_di_numero tipo;
    union {
        int intero;
        double reale;
        long double realelong;
        numComp complesso;
    };
};
struct numero x;

void stampa (numComp num){
    if(num.immaginaria < 0)
        printf("%f %fi\n", num.intera, num.immaginaria);
    else 
        printf("%f +%fi\n", num.intera, num.immaginaria);
}

void stampaNum (struct numero x){
    if (x.tipo == INTERO)
        printf("intero:%d\n", x.intero);
    else if (x.tipo == REALE)
        printf("reale :%f\n", x.reale);
    else if (x.tipo == REALEDOPPIO)
        printf("realel:%Lf\n", x.realelong);
    else if (x.tipo == COMPLESSO)
        stampa(x.complesso);
    else
        printf("Oh hell nah");
}

void compare (numComp num1, numComp num2){
    if ((num1.intera == num2.intera) && (num1.immaginaria == num2.immaginaria))
        printf("I numeri sono uguali\n");
    else
        printf("I numeri sono diversi\n");
}

numComp sum (numComp num1, numComp num2){
    numComp result = {
        num1.intera + num2.intera,
        num1.immaginaria + num2.immaginaria
    };
    return result;
}

numComp product (numComp num1, numComp num2){
    numComp result = {
        (num1.intera * num2.intera - num1.immaginaria * num2.immaginaria),
        (num1.intera * num2.immaginaria + num1.immaginaria * num2.intera)
    };
    return result;
}

numComp conjugate (numComp num){
    numComp result = {
        num.intera,
        0 - num.immaginaria
    };
    return result;
}

int main(int argc, char const *argv[])
{
    numComp num1 = {1, 1};
    numComp num2 = {1, 3};
    stampa(num1);
    stampa(num2);
    compare(num1, num2);
    stampa(sum(num1, num2));
    stampa(product(num1, num2));
    stampa(conjugate(num1));
    printf("\n\n\n\n\n\n");
    struct numero x = {.tipo = COMPLESSO, .complesso = num1};
    stampaNum(x);
    x.tipo = INTERO; x.intero = 34;
    stampaNum(x);
    x.tipo = REALE; x.reale = 3.14413;
    stampaNum(x);
    x.tipo = REALEDOPPIO; x.intero = 34;
    stampaNum(x);
}
