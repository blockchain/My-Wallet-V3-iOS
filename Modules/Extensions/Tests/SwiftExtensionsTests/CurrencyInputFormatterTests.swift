@testable import SwiftExtensions
import XCTest

class CurrencyInputFormatterTests: XCTestCase {

    func test_append_number_to_zero() {
        var formatter = CurrencyInputFormatter()
        XCTAssertTrue(formatter.append("1"))
        XCTAssertEqual(formatter.suggestion, "1")
    }

    func test_append_zero_to_zero() {
        var formatter = CurrencyInputFormatter()
        XCTAssertFalse(formatter.append("0"))
        XCTAssertEqual(formatter.suggestion, "0")
    }

    func test_append_decimal_to_zero() {
        var formatter = CurrencyInputFormatter()
        XCTAssertTrue(formatter.append("."))
        XCTAssertEqual(formatter.suggestion, "0.")
    }

    func test_append_decimal_when_already_exists() {
        var formatter = CurrencyInputFormatter("0.1")
        XCTAssertFalse(formatter.append("."))
        XCTAssertEqual(formatter.suggestion, "0.1")
    }

    func test_append_number_with_full_precision() {
        var formatter = CurrencyInputFormatter("0.00", precision: 2)
        XCTAssertFalse(formatter.append("1"))
        XCTAssertEqual(formatter.suggestion, "0.00")
    }

    func test_backspace_number() {
        var formatter = CurrencyInputFormatter("10")
        XCTAssertEqual(formatter.backspace().suggestion, "1")
    }

    func test_backspace_decimal_point() {
        var formatter = CurrencyInputFormatter("1.")
        XCTAssertEqual(formatter.backspace().suggestion, "1")
    }

    func test_backspace_number_after_decimal() {
        var formatter = CurrencyInputFormatter("1.0")
        formatter.backspace()
        formatter.backspace()
        XCTAssertEqual(formatter.suggestion, "0")
    }

    func test_backspace_multiple_number_after_decimal() {
        var formatter = CurrencyInputFormatter("1.00")
        formatter.backspace()
        formatter.backspace()
        XCTAssertEqual(formatter.suggestion, "1")
    }

    func test_reset_input() {
        var formatter = CurrencyInputFormatter("100")
        XCTAssertEqual(formatter.reset().suggestion, "0")
    }

    func test_append_to_zero_until_precision_limit_of_8() {
        var formatter = CurrencyInputFormatter(precision: 8)
        formatter.append("0", ".", "0", "0", "0", "0", "0", "1")
        XCTAssertEqual(formatter.suggestion, "0.000001")
    }

    func test_append_to_zero_until_precision_limit_of_2() {
        var formatter = CurrencyInputFormatter(precision: 2)
        formatter.append("0", ".", "0", "0", "0", "0", "0", "1")
        XCTAssertEqual(formatter.suggestion, "0.00")
    }

    func test_backspace_until_zero() {
        var formatter = CurrencyInputFormatter("0.000001", precision: 8)
        for _ in 0..<7 { formatter.backspace() }
        XCTAssertEqual(formatter.suggestion, "0")
    }

    func test_append_to_zero_until_hundred() {
        var formatter = CurrencyInputFormatter()
        formatter.append("1", "0", "0")
        XCTAssertEqual(formatter.suggestion, "100")
    }

    func test_backspace_until_zero_from_hundred() {
        var formatter = CurrencyInputFormatter("100")
        for _ in 0..<3 { formatter.backspace() }
        XCTAssertEqual(formatter.suggestion, "0")
    }

    func test_append_non_numeric_characters() {
        var formatter = CurrencyInputFormatter()

        XCTAssertFalse(formatter.append("a"))
        XCTAssertEqual(formatter.suggestion, "0")

        XCTAssertFalse(formatter.append("!"))
        XCTAssertEqual(formatter.suggestion, "0")

        XCTAssertFalse(formatter.append(" "))
        XCTAssertEqual(formatter.suggestion, "0")
    }

    func test_append_with_different_decimal_separator() {
        var formatter = CurrencyInputFormatter(decimalSeparator: ",")
        formatter.append("1", ",", "2")
        XCTAssertEqual(formatter.suggestion, "1,2")
    }

    func test_append_with_number_as_decimal_separator() {
        var formatter = CurrencyInputFormatter(decimalSeparator: "1")
        formatter.append("1", "1", "2")
        XCTAssertEqual(formatter.suggestion, "012")
    }

    func test_initial_non_zero_string() {
        let formatter = CurrencyInputFormatter("123")
        XCTAssertEqual(formatter.suggestion, "123")
    }

    func test_enter_method() {
        let formatter = CurrencyInputFormatter()
        XCTAssertEqual(formatter.enter(), "0")
    }

    func test_appending_multiple_zeroes_before_decimal_point() {
        var formatter = CurrencyInputFormatter()
        formatter.append("0", "0", ".", "0")
        XCTAssertEqual(formatter.suggestion, "0.0")
    }
}

extension CurrencyInputFormatter {

    mutating func append(_ first: Character, _ second: Character, _ rest: Character...) {
        for character in [first, second] + rest {
            append(character)
        }
    }
}
