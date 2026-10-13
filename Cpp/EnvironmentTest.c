#include <stdio.h>

int main(void) {
    int numbers[] = {3, 1, 4, 1, 5};
    int length = sizeof(numbers) / sizeof(numbers[0]);
    int total = 0;

    for (int i = 0; i < length; i++) {
        total += numbers[i];
    }

    printf("C environment is ready.\n");
    printf("Array length: %d\n", length);
    printf("Sum: %d\n", total);

    return 0;
}
