#include <stdio.h>

int main() {
    printf("RISC-V Test Environment\n");
    int a = 5;
    int b = 7;
    int c = a + b;
    printf("5 + 7 = %d\n", c);
    return c == 12 ? 0 : 1;
}
