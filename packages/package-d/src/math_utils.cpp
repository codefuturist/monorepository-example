#include "package_d/math_utils.hpp"
#include <cmath>
#include <stdexcept>

namespace package_d {

unsigned long long factorial(int n) {
    if (n < 0) {
        throw std::invalid_argument("Factorial not defined for negative numbers");
    }
    if (n == 0 || n == 1) {
        return 1;
    }
    unsigned long long result = 1;
    for (int i = 2; i <= n; ++i) {
        result *= i;
    }
    return result;
}

bool is_prime(int n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    
    for (int i = 5; i * i <= n; i += 6) {
        if (n % i == 0 || n % (i + 2) == 0) {
            return false;
        }
    }
    return true;
}

int gcd(int a, int b) {
    a = std::abs(a);
    b = std::abs(b);
    
    while (b != 0) {
        int temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}

} // namespace package_d
