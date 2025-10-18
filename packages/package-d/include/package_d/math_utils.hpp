#pragma once

namespace package_d {

/**
 * @brief Calculate factorial of a number
 * @param n The number to calculate factorial for
 * @return The factorial of n
 */
unsigned long long factorial(int n);

/**
 * @brief Check if a number is prime
 * @param n The number to check
 * @return true if prime, false otherwise
 */
bool is_prime(int n);

/**
 * @brief Calculate greatest common divisor
 * @param a First number
 * @param b Second number
 * @return GCD of a and b
 */
int gcd(int a, int b);

} // namespace package_d
