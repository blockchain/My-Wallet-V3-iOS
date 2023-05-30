// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@_spi(Test) import MoneyKit
import XCTest

class FiatValueTests: XCTestCase {

    func testInitalization() {
        XCTAssertEqual(
            1000,
            FiatValue.create(minor: "1000", currency: .USD).minorAmount
        )

        XCTAssertEqual(
            "0.01",
            FiatValue.create(minor: "1", currency: .USD)?.toDisplayString(includeSymbol: false)
        )

        XCTAssertEqual(
            8000000,
            FiatValue.create(minor: "8000000", currency: .USD).minorAmount
        )
    }

    func testUSDDecimalPlaces() {
        XCTAssertEqual(
            2,
            FiatValue.create(major: "1.00", currency: .USD)!.precision
        )
    }

    func testJPYDecimalPlaces() {
        XCTAssertEqual(
            0,
            FiatValue.create(major: "1.000000", currency: .JPY)!.precision
        )
    }

    func testSymbol() {
        _currentLocale = Locale.US as NSLocale
        let usdValue = FiatValue.zero(currency: .USD)
        XCTAssertEqual("$", usdValue.displaySymbol)

        let eurValue = FiatValue.zero(currency: .EUR)
        XCTAssertEqual("€", eurValue.displaySymbol)
    }

    func testIsZero() {
        XCTAssertTrue(FiatValue.create(major: "0", currency: .USD)!.isZero)
    }

    func testIsPositive() {
        XCTAssertTrue(FiatValue.create(major: "1.00", currency: .USD)!.isPositive)
    }

    func testNotPositive() {
        XCTAssertFalse(FiatValue.create(major: "-1.00", currency: .USD)!.isPositive)
    }

    func testAddition() throws {
        XCTAssertEqual(
            FiatValue.create(major: "3.00", currency: .USD),
            try FiatValue.create(major: "2.00", currency: .USD)! + FiatValue.create(major: "1.00", currency: .USD)!
        )
    }

    func testSubtraction() throws {
        XCTAssertEqual(
            FiatValue.create(major: "1.00", currency: .USD),
            try FiatValue.create(major: "3.00", currency: .USD)! - FiatValue.create(major: "2.00", currency: .USD)!
        )
    }

    func testMultiplication() throws {
        let expected = FiatValue.create(major: "9.00", currency: .USD)!
        let value = FiatValue.create(major: "3.00", currency: .USD)!
        let result = try value * value
        XCTAssertEqual(expected, result)
    }

    func testDivision() throws {
        let expected = FiatValue.create(major: "1.00", currency: .USD)!
        let value = FiatValue.create(major: "3.00", currency: .USD)!
        let result = try value / value
        XCTAssertEqual(expected, result)
    }

    func testMinorString() {
        let expected100MillionMajor = "10000000000"
        let value100MillionMajor = FiatValue.create(major: "100000000.00", currency: .USD)!
        XCTAssertEqual(expected100MillionMajor, value100MillionMajor.minorString)

        let expected1Minor = "1"
        let value1Minor = FiatValue.create(minor: "1", currency: .USD)!
        XCTAssertEqual(expected1Minor, value1Minor.minorString)
    }

    func testEquatable() {
        XCTAssertEqual(
            FiatValue.create(major: "9.00", currency: .USD),
            FiatValue.create(major: "9.00", currency: .USD)
        )
    }

    func testConvertToCryptoValue() {
        let expected = CryptoValue.create(major: "0.5", currency: .bitcoin)!
        let amount = FiatValue.create(major: "4000.00", currency: .USD)!
        let exchangeRate = FiatValue.create(major: "8000.00", currency: .USD)!
        let result: CryptoValue = amount.convert(usingInverse: exchangeRate, currency: .bitcoin)
        XCTAssertEqual(expected, result)
    }

    func testConvertToCryptoValueZeroExchangeRate() {
        let expected: CryptoValue = .zero(currency: .bitcoin)
        let amount = FiatValue.create(major: "4000.00", currency: .USD)!
        let exchangeRate: FiatValue = .zero(currency: .USD)
        let result: CryptoValue = amount.convert(usingInverse: exchangeRate, currency: .bitcoin)
        XCTAssertEqual(expected, result)
    }

    func testConvertToCryptoValueZeroValue() {
        let expected: CryptoValue = .zero(currency: .bitcoin)
        let amount: FiatValue = .zero(currency: .USD)
        let exchangeRate = FiatValue.create(major: "5.00", currency: .USD)!
        let result: CryptoValue = amount.convert(usingInverse: exchangeRate, currency: .bitcoin)
        XCTAssertEqual(expected, result)
    }

    // MARK: toDisplayString tests

    func testDisplayUSDinUS() {
        XCTAssertEqual(
            "$1.00",
            FiatValue.create(major: "1.00", currency: .USD)!
                .toDisplayString(locale: Locale.US)
        )
    }

    func testDisplayUSDinUSWithoutSymbol() {
        XCTAssertEqual(
            "1.00",
            FiatValue.create(major: "1.00", currency: .USD)!
                .toDisplayString(includeSymbol: false, locale: Locale.US)
        )
    }

    func testDisplayUSDinCanada() {
        XCTAssertEqual(
            "US$1.00",
            FiatValue.create(major: "1.00", currency: .USD)!
                .toDisplayString(locale: Locale.Canada)
        )
    }

    func testDisplayUSDinFrance() {
        XCTAssertEqual(
            "1,00 $US",
            FiatValue.create(major: "1.00", currency: .USD)!
                .toDisplayString(locale: Locale.France)
        )
    }

    func testDisplayCADinUS() {
        XCTAssertEqual(
            "CA$1.00",
            FiatValue.create(major: "1.00", currency: .CAD)!
                .toDisplayString(locale: Locale.US)
        )
    }

    func testDisplayCADinCanada() {
        XCTAssertEqual(
            "$1.00",
            FiatValue.create(major: "1.00", currency: .CAD)!
                .toDisplayString(locale: Locale.Canada)
        )
    }

    func testDisplayYENinUS() {
        XCTAssertEqual(
            "¥1",
            FiatValue.create(major: "1.00", currency: .JPY)!
                .toDisplayString(locale: Locale.US)
        )
    }

    func testDisplayYENinUSNoSymbol() {
        XCTAssertEqual(
            "1",
            FiatValue.create(major: "1.00", currency: .JPY)!
                .toDisplayString(includeSymbol: false, locale: Locale.US)
        )
    }

    func testDisplayYENinCanada() {
        XCTAssertEqual(
            "JP¥1",
            FiatValue.create(major: "1.00", currency: .JPY)!
                .toDisplayString(locale: Locale.Canada)
        )
    }

    func testDisplayYenInJapan() {
        XCTAssertEqual(
            "¥1",
            FiatValue.create(major: "1.00", currency: .JPY)!
                .toDisplayString(locale: Locale.US)
        )
    }

    func testValueIncrease() {
        let current = FiatValue.create(minor: "1100", currency: .USD)! // $USD 11.00
        let before = current.value(before: 0.1) // before 10% increase
        XCTAssertEqual(before.minorAmount, 1000)
    }

    func testValueDecrease() {
        let current = FiatValue.create(minor: "12000", currency: .USD)! // $USD 120.00
        let before = current.value(before: -0.2) // before 20% decrease
        XCTAssertEqual(before.minorAmount, 15000)
    }
}
