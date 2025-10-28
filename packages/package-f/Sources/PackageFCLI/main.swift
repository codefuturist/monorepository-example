import Foundation
import PackageF
import Rainbow

@main
struct PackageFCLI {
    static func main() {
        printSeparator(title: "Package F - Array Utilities v1.0.0")

        // Verify dependency
        print("\n✓ Rainbow dependency loaded successfully".green)
        print("✓ Array utilities initialized\n".green)

        do {
            try runTests()

            print()
            printSeparator(title: "Package F executed successfully!".green)
            print()
        } catch {
            print("\nERROR: \(error)".red)
            Foundation.exit(1)
        }
    }

    static func runTests() throws {
        let numbers = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]

        print("Array Utilities Demonstration:".cyan.bold)
        print(String(repeating: "-", count: 60))

        print("\nOriginal array: \(numbers)".yellow)

        // Test findMax
        if let maxVal = ArrayUtils.findMax(numbers) {
            print("Maximum value: \(maxVal)".cyan)
        }

        // Test findMin
        if let minVal = ArrayUtils.findMin(numbers) {
            print("Minimum value: \(minVal)".cyan)
        }

        // Test average
        let doublesForAvg = numbers.map { Double($0) }
        let avg = ArrayUtils.average(doublesForAvg)
        print("Average: \(String(format: "%.2f", avg))".cyan)

        // Test removeDuplicates
        let unique = ArrayUtils.removeDuplicates(numbers)
        print("Without duplicates: \(unique)".cyan)

        // Test chunk
        let chunks = ArrayUtils.chunk(numbers, size: 3)
        print("Chunked (size 3): \(chunks)".cyan)

        // Test with strings
        print("\n" + "String Array Test:".cyan.bold)
        print(String(repeating: "-", count: 60))

        let words = ["apple", "banana", "apple", "cherry", "banana"]
        print("\nOriginal: \(words)".yellow)

        let uniqueWords = ArrayUtils.removeDuplicates(words)
        print("Unique words: \(uniqueWords)".cyan)

        // Error handling test
        print("\n" + "Error Handling Test:".cyan.bold)
        print(String(repeating: "-", count: 60))

        let emptyArray: [Int] = []
        if ArrayUtils.findMax(emptyArray) == nil {
            print("✓ Empty array handled correctly (returns nil)".green)
        }

        // Test invalid chunk size (ArrayUtils.chunk returns empty array for size 0)
        let invalidChunks = ArrayUtils.chunk([1, 2, 3], size: 0)
        if invalidChunks.isEmpty {
            print("✓ Invalid chunk size handled correctly (returns empty array)".green)
        } else {
            print("✗ Invalid chunk size not handled correctly".red)
        }
    }

    static func printSeparator(title: String = "") {
        print(String(repeating: "=", count: 60))
        if !title.isEmpty {
            print(title)
            print(String(repeating: "=", count: 60))
        }
    }
}
