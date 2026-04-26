#include <stdio.h>
#include <stdlib.h>

#define MAX_SIZE 100

int factorial(int n) {
    if (n <= 1)
        return 1;
    return n * factorial(n - 1);
}

bool isPrime(int num) {
    if (num < 2) return false;
    for (int i = 2; i * i <= num; i++) {
        if (num % i == 0)
            return false;
    }
    return true;
}

int main() {
    int x = 10;
    float pi = 3.14159;
    double result = 0.0;
    char grade = 'A';
    string name = "Alamein";

    result = pi * x * x;

    if (x >= 5 && x <= MAX_SIZE) {
        x++;
    } else if (x == 0 || x != -1) {
        x--;
    }

    int sum = 0;
    for (int i = 0; i < x; i++) {
        sum += i;
    }

    int count = 0;
    while (count < 5) {
        count++;
    }

    switch (x) {
        case 0:
            break;
        case 1:
            result += 1.5e2;
            break;
        default:
            result -= 0.001;
    }

    printf("Factorial of %d = %d\n", x, factorial(x));
    printf("Sum = %d, Result = %.2f\n", sum, result);

    return 0;
}
