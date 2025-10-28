#include "package_d/math_utils.hpp"
#include <cassert>
#include <iostream>

void test_factorial() {
    assert(package_d::factorial(0) == 1);
    assert(package_d::factorial(1) == 1);
    assert(package_d::factorial(5) == 120);
    assert(package_d::factorial(10) == 3628800);
    std::cout << "✓ factorial tests passed\n";
}

void test_is_prime() {
    assert(package_d::is_prime(2) == true);
    assert(package_d::is_prime(3) == true);
    assert(package_d::is_prime(4) == false);
    assert(package_d::is_prime(17) == true);
    assert(package_d::is_prime(100) == false);
    std::cout << "✓ is_prime tests passed\n";
}

void test_gcd() {
    assert(package_d::gcd(12, 8) == 4);
    assert(package_d::gcd(17, 5) == 1);
    assert(package_d::gcd(100, 50) == 50);
    assert(package_d::gcd(-12, 8) == 4);
    std::cout << "✓ gcd tests passed\n";
}

int main() {
    std::cout << "Running package-d tests...\n";
    test_factorial();
    test_is_prime();
    test_gcd();
    std::cout << "\n✅ All tests passed!\n";
    return 0;
}
