//
//  FiatValueTests.swift
//  PlatformKitTests
//
//  Created by Chris Arriola on 1/17/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class FiatValueTests: XCTestCase {

    func testUSDDecimalPlaces() {
        XCTAssertEqual(
            2,
            FiatValue.create(amountString: "1.00", currencyCode: "USD").maxDecimalPlaces
        )
    }

    func testJPYDecimalPlaces() {
        XCTAssertEqual(
            0,
            FiatValue.create(amountString: "1.000000", currencyCode: "JPY").maxDecimalPlaces
        )
    }

    func testSymbol() {
        let usdValue = FiatValue(currencyCode: "USD", amount: 0)
        XCTAssertEqual("$", usdValue.symbol)

        let eurValue = FiatValue(currencyCode: "EUR", amount: 0)
        XCTAssertEqual("€", eurValue.symbol)
    }

    func testIsZero() {
        XCTAssertTrue(FiatValue.create(amountString: "0", currencyCode: "USD").isZero)
    }

    func testIsPositive() {
        XCTAssertTrue(FiatValue.create(amountString: "1.00", currencyCode: "USD").isPositive)
    }

    func testNotPositive() {
        XCTAssertFalse(FiatValue.create(amountString: "-1.00", currencyCode: "USD").isPositive)
    }

    func testAddition() {
        XCTAssertEqual(
            FiatValue.create(amountString: "3.00", currencyCode: "USD"),
            try FiatValue.create(amountString: "2.00", currencyCode: "USD") + FiatValue.create(amountString: "1.00", currencyCode: "USD")
        )
    }

    func testSubtraction() {
        XCTAssertEqual(
            FiatValue.create(amountString: "1.00", currencyCode: "USD"),
            try FiatValue.create(amountString: "3.00", currencyCode: "USD") - FiatValue.create(amountString: "2.00", currencyCode: "USD")
        )
    }

    func testMultiplication() {
        XCTAssertEqual(
            FiatValue.create(amountString: "9.00", currencyCode: "USD"),
            try FiatValue.create(amountString: "3.00", currencyCode: "USD") * FiatValue.create(amountString: "3.00", currencyCode: "USD")
        )
    }

    func testEquatable() {
        XCTAssertEqual(
            FiatValue.create(amountString: "9.00", currencyCode: "USD"),
            FiatValue.create(amountString: "9.00", currencyCode: "USD")
        )
    }

    func testConvertToCryptoValue() {
        let amount = FiatValue.create(amountString: "4,000.00", currencyCode: "USD")
        let exchangeRate = FiatValue.create(amountString: "8,000.00", currencyCode: "USD")
        XCTAssertEqual(
            amount.convertToCryptoValue(exchangeRate: exchangeRate, cryptoCurrency: .bitcoin),
            CryptoValue.bitcoinFromMajor(string: "0.5")
        )
    }

    // MARK: toDisplayString tests

    func testDisplayUSDinUS() {
        XCTAssertEqual(
            "$1.00",
            FiatValue.create(amountString: "1.00", currencyCode: "USD")
                .toDisplayString(locale: Locale.US)
        )
    }

    func testDisplayUSDinUSWithoutSymbol() {
        XCTAssertEqual(
            "1.00",
            FiatValue.create(amountString: "1.00", currencyCode: "USD")
                .toDisplayString(includeSymbol: false, locale: Locale.US)
        )
    }

    func testDisplayUSDinCanada() {
        XCTAssertEqual(
            "US$1.00",
            FiatValue.create(amountString: "1.00", currencyCode: "USD")
                .toDisplayString(locale: Locale.Canada)
        )
    }

    func testDisplayUSDinFrance() {
        XCTAssertEqual(
            "1,00 $US",
            FiatValue.create(amountString: "1.00", currencyCode: "USD")
                .toDisplayString(locale: Locale.France)
        )
    }

    func testDisplayCADinUS() {
        XCTAssertEqual(
            "CA$1.00",
            FiatValue.create(amountString: "1.00", currencyCode: "CAD")
                .toDisplayString(locale: Locale.US)
        )
    }

    func testDisplayCADinCanada() {
        XCTAssertEqual(
            "$1.00",
            FiatValue.create(amountString: "1.00", currencyCode: "CAD")
                .toDisplayString(locale: Locale.Canada)
        )
    }

    func testDisplayYENinUS() {
        XCTAssertEqual(
            "¥1",
            FiatValue.create(amountString: "1.00", currencyCode: "JPY")
                .toDisplayString(locale: Locale.US)
        )
    }

    func testDisplayYENinUSNoSymbol() {
        XCTAssertEqual(
            "1",
            FiatValue.create(amountString: "1.00", currencyCode: "JPY")
                .toDisplayString(includeSymbol: false, locale: Locale.US)
        )
    }

    func testDisplayYENinCanada() {
        XCTAssertEqual(
            "JP¥1",
            FiatValue.create(amountString: "1.00", currencyCode: "JPY")
                .toDisplayString(locale: Locale.Canada)
        )
    }

    func testDisplayYenInJapan() {
        XCTAssertEqual(
            "¥1",
            FiatValue.create(amountString: "1.00", currencyCode: "JPY")
                .toDisplayString(locale: Locale.US)
        )
    }
}
