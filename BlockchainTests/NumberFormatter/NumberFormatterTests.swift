//
//  NumberFormatterTests.swift
//  BlockchainTests
//
//  Created by kevinwu on 10/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

@testable import Blockchain
import PlatformKit

extension Locale {
    var safeDecimalSeparator: String {
        decimalSeparator ?? "."
    }
}

class NumberFormatterTests: XCTestCase {

    func testParseBitcoinValueFullStop() {
        let cases: [(String?, UInt64)] = [
            ("0", 0),
            (nil, 0),
            ("", 0),
            (".0", 0),
            ("0.0", 0),
            ("0.", 0),

            ("1", 100_000_000),
            ("1.", 100_000_000),
            (".1", 10_000_000),
            ("0.1", 10_000_000),

            ("12.01", 1_201_000_000),
            ("10.12345678", 1_012_345_678),
            ("123", 12_300_000_000),
            ("123456789.12345678", 12_345_678_912_345_678),

            ("123456789,12345678", 12_345_678_912_345_678)
        ]
        for (idx, test) in cases.enumerated() {
            let result = NumberFormatter.parseBitcoinValue(from: test.0)
            XCTAssertEqual(
                test.1,
                NumberFormatter.parseBitcoinValue(from: test.0),
                "Failed #\(idx) - \(test.0 ?? "nil"): expected to be \(test.1) but got \(result) instead"
            )
        }
    }

    // Test conversion from arabic indic value for "10.123456789"
    func testArabicIndicDigitsDecimalString() {
        let arabicIndicValue = "\u{0661}\u{0660}\u{066B}\u{0661}\u{0662}\u{0663}\u{0664}\u{0665}\u{0666}\u{0667}\u{0668}\u{0669}"
        let converted = NumberFormatter.convert(decimalString: arabicIndicValue)
        XCTAssertEqual(converted, "10.123456789")
    }

    // Test conversion from "," delimiter
    func testCommaDelimitedDecimalString() {
        let arabicIndicValue = "10,123456789"
        let converted = NumberFormatter.convert(decimalString: arabicIndicValue)
        XCTAssertEqual(converted, "10.123456789")
    }

    // TODO: IOS-1556 Add support for different locales.
    func testLocalCurrencyConversion() {
        // 2.532 ETH
        guard
            let amount = Decimal(string: "2.532"),
            let rate = Decimal(string: "212.23")
        else {
            XCTFail("Could not initialize amount or rate")
            return
        }
        let localCurrencyAmount = NumberFormatter.localCurrencyAmount(fromAmount: amount, fiatPerAmount: rate)
        XCTAssertEqual(localCurrencyAmount, "537\(Locale.current.safeDecimalSeparator)36",
                       "Formatted string should have two decimal places and round down when truncating")
    }
}
