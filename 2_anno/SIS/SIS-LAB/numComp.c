#include <stdio.h>
#include <stdlib.h>

struct numComp
{
    float intera;
    float immaginaria;
};

void stampa (struct numComp num){
    if(num.immaginaria < 0)
        printf("%f %fi\n", num.intera, num.immaginaria);
    else 
        printf("%f +%fi\n", num.intera, num.immaginaria);
}

void compare (struct numComp num1, struct numComp num2){
    if ((num1.intera == num2.intera) && (num1.immaginaria == num2.immaginaria))
        printf("I numeri sono uguali\n");
    else
        printf("I numeri sono diversi\n");
}

struct numComp sum (struct numComp num1, struct numComp num2){
    struct numComp result = {
        num1.intera + num2.intera,
        num1.immaginaria + num2.immaginaria
    };
    return result;
}

struct numComp product (struct numComp num1, struct numComp num2){
    struct numComp result = {
        (num1.intera * num2.intera - num1.immaginaria * num2.immaginaria),
        (num1.intera * num2.immaginaria + num1.immaginaria * num2.intera)
    };
    return result;
}

struct numComp conjugate (struct numComp num){
    struct numComp result = {
        num.intera,
        0 - num.immaginaria
    };
    return result;
}

int main(int argc, char const *argv[])
{
    struct numComp num1 = {1, 1};
    struct numComp num2 = {1, 3};
    stampa(num1);
    stampa(num2);
    compare(num1, num2);
    stampa(sum(num1, num2));
    stampa(product(num1, num2));
    stampa(conjugate(num1));
}
