// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureProveUI
import XCTest

class FeatureProveUITests: XCTestCase {

    func test_format_phone_empty() throws {
        let phone = String.formatPhone(phone: "")

        XCTAssertEqual(phone, "")
    }

    func test_format_phone_with_country_code_should_remove_code() throws {
        let phone = String.formatPhone(phone: "+1 (888) 555-5512")

        XCTAssertEqual(phone, "(888) 555-5512")
    }

    func test_format_phone_with_wrong_format_should_format_phone() throws {
        let phone = String.formatPhone(phone: "8885555512")

        XCTAssertEqual(phone, "(888) 555-5512")
    }

    func test_format_phone_with_too_many_numbers_should_format_phone_takes_last_10_digits() throws {
        let phone = String.formatPhone(phone: "+1 88855555122342344")

        XCTAssertEqual(phone, "(512) 234-2344")
    }

    func test_format_phone_with_not_expected_chars_should_format() throws {
        let phone = String.formatPhone(phone: "+1 8_8,8.5a5555_122342#3.4,4")

        XCTAssertEqual(phone, "(512) 234-2344")
    }
}
