//
//  NumberFormatter+AssetsTests.swift
//  BlockchainTests
//
//  Created by kevinwu on 5/2/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class NumberFormatterAssetsTests: XCTestCase {

    let localCurrencyDecimalPlaces = 2
    let localCurrencyInput: NSNumber = 1234.56

    let assetDecimalPlaces = 8
    let assetInput: NSNumber = 1234.12345678

    let groupingAssertFormat = "Strings returned from %@ should have grouping separators"
    let noGroupingAssertFormat = "Strings returned from %@ should not have grouping separators"
    let decimalAssertFormat = "Strings returned from %@ should always have %d decimal places"

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: Local Currency
    func testLocalCurrencyFormatter() {
        let name = "localCurrencyFormatter"
        testFormatter(formatter: NumberFormatter.localCurrencyFormatter,
                      inputAmount: localCurrencyInput,
                      grouping: (false, String(format: noGroupingAssertFormat, name)),
                      decimalPlaces: (localCurrencyDecimalPlaces, String(format: decimalAssertFormat, name, localCurrencyDecimalPlaces)))
    }

    func testLocalCurrencyFormatterWithGroupingSeparator() {
        let name = "localCurrencyFormatterWithGroupingSeparator"
        testFormatter(formatter: NumberFormatter.localCurrencyFormatterWithGroupingSeparator,
                      inputAmount: localCurrencyInput,
                      grouping: (true, String(format: groupingAssertFormat, name)),
                      decimalPlaces: (localCurrencyDecimalPlaces, String(format: decimalAssertFormat, name, localCurrencyDecimalPlaces)))
    }

    // MARK: Digital Assets
    func testAssetFormatter() {
        let name = "assetFormatter"
        let decimalPlaces = 8
        testFormatter(formatter: NumberFormatter.assetFormatter,
                      inputAmount: assetInput,
                      grouping: (false, String(format: noGroupingAssertFormat, name)),
                      decimalPlaces: (decimalPlaces, String(format: decimalAssertFormat, name, decimalPlaces)))
    }

    func testAssetFormatterWithGroupingSeparator() {
        let name = "assetFormatterWithGroupingSeparator"
        let decimalPlaces = 8
        testFormatter(formatter: NumberFormatter.assetFormatterWithGroupingSeparator,
                      inputAmount: assetInput,
                      grouping: (true, String(format: groupingAssertFormat, name)),
                      decimalPlaces: (decimalPlaces, String(format: decimalAssertFormat, name, decimalPlaces)))
    }

    // MARK: Helpers
    private func testFormatter(formatter: NumberFormatter,
                               inputAmount: NSNumber,
                               grouping: (expect: Bool, assertStatement: String),
                               decimalPlaces: (expected: Int, assertStatement: String)) {
        let formatted = testNumberFormatterOutput(formatter: formatter, inputAmount: inputAmount)
        let groupingSeparator = testNumberFormatterGroupingSeparator(formatter: formatter, inputAmount: inputAmount)

        // Check for grouping separators
        let hasGroupingSeparator = formatted.contains(groupingSeparator)
        XCTAssert((hasGroupingSeparator && grouping.expect) ||
            (!hasGroupingSeparator && !grouping.expect),
                  grouping.assertStatement)

        // Check for decimal places
        guard let decimalSeparator = formatter.locale.decimalSeparator else {
            XCTFail("Could not get decimal separator from formatter")
            return
        }
        let numbersAfterDecimal = testNumberFormatterNumbersAfterDecimal(formatted: formatted,
                                                                         inputAmount: inputAmount,
                                                                         decimalSeparator: decimalSeparator)
        XCTAssert(numbersAfterDecimal == decimalPlaces.expected, decimalPlaces.assertStatement)
    }

    private func testNumberFormatterOutput(formatter: NumberFormatter, inputAmount: NSNumber) -> String {
        guard let formatted = formatter.string(from: inputAmount) else {
            XCTFail("Could not get formatted string from formatter")
            return ""
        }
        return formatted
    }

    private func testNumberFormatterGroupingSeparator(formatter: NumberFormatter, inputAmount: NSNumber) -> String {
        guard let groupingSeparator = formatter.locale.groupingSeparator else {
            XCTFail("Could not get grouping separator from formatter")
            return ""
        }
        return groupingSeparator
    }

    private func testNumberFormatterNumbersAfterDecimal(formatted: String, inputAmount: NSNumber, decimalSeparator: String) -> Int {
        guard let numbersAfterDecimal = formatted.components(separatedBy: decimalSeparator).last else {
            XCTFail("Could not get numbers after decimal from formatter")
            return 0
        }
        return numbersAfterDecimal.count
    }
}
