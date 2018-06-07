//
//  String+EscapeJSTests.swift
//  BlockchainTests
//
//  Created by Maurice A. on 5/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class StringEscapeJSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testEscapedForJSWithCleanString() {
        let input = "This string should not change after being escaped."
        let expected = input
        let result = input.escapedForJS()
        XCTAssertEqual(result, expected, "Expected \(result) to match \(expected).")
    }

//    //: Quotation mark
    func testEscapedForJSWithDoubleQuote() {
        let expected = "\\\"This string should escape the double quote (\\\") character.\\\""

        let input = "\"This string should escape the double quote (\") character.\""
        let result = input.escapedForJS()
        XCTAssertEqual(result, expected, "Expected strings to match")

        let input2 = NSString(string: "\"This string should escape the double quote (\") character.\"")
        let result2 = input2.escapedForJS()
        XCTAssertEqual(result2, expected, "Expected strings to match")
    }

    //: Reverse solidus
    func testEscapedForJSWithBackslash() {
        let input = "This string should escape the backslash (\\) character."
        let expected = "This string should escape the backslash (\\\\) character."
        let result = input.escapedForJS()
        XCTAssertEqual(result, expected, "Expected \(result) to match \(expected).")
    }

    //: Single quote
    func testEscapedForJSWithSingleQuote() {
        let input = "'This string should escape the single quote (') character.'"
        let expected = "\\'This string should escape the single quote (\\') character.\\'"
        let result = input.escapedForJS()
        XCTAssertEqual(result, expected, "Expected strings to match")
    }

    //: Formfeed
    func testEscapedForJSWithFormfeed() {
        let input = "This string should escape the formfeed \u{8} character."
        let expected = "This string should escape the formfeed \\b character."
        let result = input.escapedForJS()
        XCTAssertEqual(result, expected, "Expected strings to match")
    }

    //: Newline
    func testEscapedForJSWithNewLineString() {
        let input = "This string should escape the new line \n character."
        let expected = "This string should escape the new line \\n character."
        let result = input.escapedForJS()
        XCTAssertEqual(result, expected, "Expected strings to match")
    }

    //: Carriage return
    func testEscapedForJSWithCarriageReturn() {
        let input = "This string should escape the carriage return \r character."
        let expected = "This string should escape the carriage return \\r character."
        let result = input.escapedForJS()
        XCTAssertEqual(result, expected, "Expected strings to match")
    }

    //: Horizontal tab
    func testEscapedForJSWithHorizontalTab() {
        let input = "This string should escape the horizontal tab \t character."
        let expected = "This string should escape the horizontal tab \\t character."
        let result = input.escapedForJS()
        XCTAssertEqual(result, expected, "Expected strings to match")
    }

    //: Empty string
    func testEscapedForJSWithEmptyString() {
        let input = ""
        let expected = input
        let result = input.escapedForJS()
        XCTAssertEqual(result, expected, "Expected strings to match")
    }
}
