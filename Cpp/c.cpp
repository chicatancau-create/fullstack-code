#include <iostream>
#include <vector>

int main() {
    std::vector<int> numbers = {3, 1, 4, 1, 5};
    int sum = 0;

    for (int number : numbers) {
        sum += number;
    }

    std::cout << "C++ environment is ready." << std::endl;
    std::cout << "Array length: " << numbers.size() << std::endl;
    std::cout << "Sum: " << sum << std::endl;

    return 0;
}