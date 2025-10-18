#include <iostream>
#include <vector>
#include <string>
#include "package_d/math_utils.hpp"
#include <nlohmann/json.hpp>

using json = nlohmann::json;
using namespace package_d;

void print_separator(const std::string& title = "") {
    std::cout << "=====================================" << std::endl;
    if (!title.empty()) {
        std::cout << title << std::endl;
        std::cout << "=====================================" << std::endl;
    }
}

int main() {
    print_separator("Package D - Math Utilities v1.0.0");
    
    try {
        std::cout << "\n✓ nlohmann/json dependency loaded (v" 
                  << NLOHMANN_JSON_VERSION_MAJOR << "." 
                  << NLOHMANN_JSON_VERSION_MINOR << "." 
                  << NLOHMANN_JSON_VERSION_PATCH << ")" << std::endl;
        std::cout << "✓ Math utilities initialized\n" << std::endl;
        
        // Create JSON output
        json results = json::array();
        
        // Test factorial
        std::vector<int> factorial_tests = {5, 10, 12};
        std::cout << "Factorial Results:" << std::endl;
        std::cout << "-------------------------------------" << std::endl;
        
        for (int n : factorial_tests) {
            try {
                unsigned long long result = factorial(n);
                std::cout << "factorial(" << n << ") = " << result << std::endl;
                
                results.push_back({
                    {"operation", "factorial"},
                    {"input", n},
                    {"result", result}
                });
            } catch (const std::exception& e) {
                std::cerr << "ERROR computing factorial(" << n << "): " << e.what() << std::endl;
                return 1;
            }
        }
        
        // Test is_prime
        std::vector<int> prime_tests = {2, 17, 25, 97};
        std::cout << "\nPrime Number Tests:" << std::endl;
        std::cout << "-------------------------------------" << std::endl;
        
        for (int n : prime_tests) {
            bool result = is_prime(n);
            std::cout << n << " is " << (result ? "prime" : "not prime") << std::endl;
            
            results.push_back({
                {"operation", "is_prime"},
                {"input", n},
                {"result", result}
            });
        }
        
        // Test gcd
        std::vector<std::pair<int, int>> gcd_tests = {{48, 18}, {100, 35}, {17, 19}};
        std::cout << "\nGCD (Greatest Common Divisor) Results:" << std::endl;
        std::cout << "-------------------------------------" << std::endl;
        
        for (const auto& [a, b] : gcd_tests) {
            try {
                int result = gcd(a, b);
                std::cout << "gcd(" << a << ", " << b << ") = " << result << std::endl;
                
                results.push_back({
                    {"operation", "gcd"},
                    {"input_a", a},
                    {"input_b", b},
                    {"result", result}
                });
            } catch (const std::exception& e) {
                std::cerr << "ERROR computing gcd(" << a << ", " << b << "): " << e.what() << std::endl;
                return 1;
            }
        }
        
        // Output JSON results
        std::cout << "\nJSON Output:" << std::endl;
        std::cout << "-------------------------------------" << std::endl;
        std::cout << results.dump(2) << std::endl;
        
        std::cout << std::endl;
        print_separator("Package D executed successfully!");
        std::cout << std::endl;
        
        return 0;
        
    } catch (const std::exception& e) {
        std::cerr << "\nFATAL ERROR: " << e.what() << std::endl;
        return 1;
    }
}
