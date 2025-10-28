import Foundation

/// Array utility functions
public struct ArrayUtils {

    /// Find the maximum value in an array
    /// - Parameter array: The array to search
    /// - Returns: The maximum value, or nil if array is empty
    public static func findMax<T: Comparable>(_ array: [T]) -> T? {
        return array.max()
    }

    /// Find the minimum value in an array
    /// - Parameter array: The array to search
    /// - Returns: The minimum value, or nil if array is empty
    public static func findMin<T: Comparable>(_ array: [T]) -> T? {
        return array.min()
    }

    /// Calculate the average of numeric values
    /// - Parameter array: The array of numbers
    /// - Returns: The average value
    public static func average(_ array: [Double]) -> Double {
        guard !array.isEmpty else { return 0.0 }
        return array.reduce(0, +) / Double(array.count)
    }

    /// Remove duplicates from an array
    /// - Parameter array: The array with potential duplicates
    /// - Returns: Array with duplicates removed
    public static func removeDuplicates<T: Hashable>(_ array: [T]) -> [T] {
        var seen = Set<T>()
        return array.filter { seen.insert($0).inserted }
    }

    /// Chunk an array into smaller arrays of specified size
    /// - Parameters:
    ///   - array: The array to chunk
    ///   - size: The size of each chunk
    /// - Returns: Array of chunks
    public static func chunk<T>(_ array: [T], size: Int) -> [[T]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: array.count, by: size).map {
            Array(array[$0..<min($0 + size, array.count)])
        }
    }
}
