import XCTest
@testable import Minues

final class minuesTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
      XCTAssertEqual(try? minues().run(), "<h2><a href=\"https://github.com/iwasrobbed/Down\">Down</a></h2>\n<ul>\n<li>1st</li>\n<li>2nd</li>\n</ul>\n")
      
      
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
