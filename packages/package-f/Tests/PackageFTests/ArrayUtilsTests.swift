import XCTest
@testable import PackageF

final class ArrayUtilsTests: XCTestCase {
    
    func testFindMax() {
        XCTAssertEqual(ArrayUtils.findMax([1, 5, 3, 9, 2]), 9)
        XCTAssertEqual(ArrayUtils.findMax(["a", "z", "m"]), "z")
        XCTAssertNil(ArrayUtils.findMax([Int]()))
    }
    
    func testFindMin() {
        XCTAssertEqual(ArrayUtils.findMin([1, 5, 3, 9, 2]), 1)
        XCTAssertEqual(ArrayUtils.findMin(["a", "z", "m"]), "a")
        XCTAssertNil(ArrayUtils.findMin([Int]()))
    }
    
    func testAverage() {
        XCTAssertEqual(ArrayUtils.average([1.0, 2.0, 3.0, 4.0, 5.0]), 3.0)
        XCTAssertEqual(ArrayUtils.average([10.0, 20.0]), 15.0)
        XCTAssertEqual(ArrayUtils.average([]), 0.0)
    }
    
    func testRemoveDuplicates() {
        XCTAssertEqual(ArrayUtils.removeDuplicates([1, 2, 2, 3, 3, 3, 4]), [1, 2, 3, 4])
        XCTAssertEqual(ArrayUtils.removeDuplicates(["a", "b", "a", "c"]), ["a", "b", "c"])
    }
    
    func testChunk() {
        XCTAssertEqual(ArrayUtils.chunk([1, 2, 3, 4, 5, 6], size: 2), [[1, 2], [3, 4], [5, 6]])
        XCTAssertEqual(ArrayUtils.chunk([1, 2, 3, 4, 5], size: 2), [[1, 2], [3, 4], [5]])
        XCTAssertEqual(ArrayUtils.chunk([1, 2, 3], size: 0), [])
    }
}
