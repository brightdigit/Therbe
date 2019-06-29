import XCTest
@testable import minues

final class minuesTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(minues().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
