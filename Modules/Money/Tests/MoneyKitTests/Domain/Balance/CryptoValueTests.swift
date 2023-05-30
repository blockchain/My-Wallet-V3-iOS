// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import BigInt
import MoneyKit
import XCTest

final class CryptoValueTests: XCTestCase {

    func testMajorValue() {
        XCTAssertEqual(
            Decimal(100),
            CryptoValue.create(minor: "10000000000", currency: .bitcoin)!.displayMajorValue
        )
        XCTAssertEqual(
            Decimal(10),
            CryptoValue.create(minor: 1000000000, currency: .bitcoin).displayMajorValue
        )
        XCTAssertEqual(
            Decimal(1),
            CryptoValue.create(minor: 100000000, currency: .bitcoin).displayMajorValue
        )
        XCTAssertEqual(
            Decimal(0.1),
            CryptoValue.create(minor: 10000000, currency: .bitcoin).displayMajorValue
        )
        XCTAssertEqual(
            Decimal(0.01),
            CryptoValue.create(minor: 1000000, currency: .bitcoin).displayMajorValue
        )
        XCTAssertEqual(
            Decimal(0.001),
            CryptoValue.create(minor: 100000, currency: .bitcoin).displayMajorValue
        )
        XCTAssertEqual(
            Decimal(0.0001),
            CryptoValue.create(minor: 10000, currency: .bitcoin).displayMajorValue
        )
        XCTAssertEqual(
            Decimal(0.00001),
            CryptoValue.create(minor: 1000, currency: .bitcoin).displayMajorValue
        )
        XCTAssertEqual(
            Decimal(0.000001),
            CryptoValue.create(minor: 100, currency: .bitcoin).displayMajorValue
        )
        XCTAssertEqual(
            Decimal(0.0000001),
            CryptoValue.create(minor: 10, currency: .bitcoin).displayMajorValue
        )
        XCTAssertEqual(
            Decimal(0.00000001),
            CryptoValue.create(minor: 1, currency: .bitcoin).displayMajorValue
        )

        // Comparing Strings below since the value Decimal(4.90993923) will produce precision issues
        // (i.e. the underlying value will be something like 4.9099392300000234821
        XCTAssertEqual(
            "4.90993923",
            "\(CryptoValue.create(minor: 490993923, currency: .bitcoin).displayMajorValue)"
        )
    }

    func testCreateFromMajorBitcoin() {
        XCTAssertEqual(
            1000000000,
            CryptoValue.create(major: "10", currency: .bitcoin)!.minorAmount
        )
        XCTAssertEqual(
            100000000,
            CryptoValue.create(major: "1", currency: .bitcoin)!.minorAmount
        )
        XCTAssertEqual(
            10000000,
            CryptoValue.create(major: "0.1", currency: .bitcoin)!.minorAmount
        )
        XCTAssertEqual(
            1000000,
            CryptoValue.create(major: "0.01", currency: .bitcoin)!.minorAmount
        )
        XCTAssertEqual(
            100000,
            CryptoValue.create(major: "0.001", currency: .bitcoin)!.minorAmount
        )
        XCTAssertEqual(
            10000,
            CryptoValue.create(major: "0.0001", currency: .bitcoin)!.minorAmount
        )
        XCTAssertEqual(
            1000,
            CryptoValue.create(major: "0.00001", currency: .bitcoin)!.minorAmount
        )
        XCTAssertEqual(
            100,
            CryptoValue.create(major: "0.000001", currency: .bitcoin)!.minorAmount
        )
        XCTAssertEqual(
            10,
            CryptoValue.create(major: "0.0000001", currency: .bitcoin)!.minorAmount
        )
        XCTAssertEqual(
            1,
            CryptoValue.create(major: "0.00000001", currency: .bitcoin)!.minorAmount
        )
        XCTAssertEqual(
            490993923,
            CryptoValue.create(major: "4.90993923", currency: .bitcoin)!.minorAmount
        )
    }

    func testCreateWithAnotherLocale() {
        XCTAssertEqual(
            123000000,
            CryptoValue.create(major: "1,23", currency: .bitcoin, locale: Locale.France)!.minorAmount
        )
    }

    func testCreateFromMajorEth() {
        let decimalPlaces = CryptoCurrency.ethereum.precision
        XCTAssertEqual(
            BigInt(1) * BigInt(10).power(decimalPlaces),
            CryptoValue.create(major: "1", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(12) * BigInt(10).power(decimalPlaces - 1),
            CryptoValue.create(major: "1.2", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(123) * BigInt(10).power(decimalPlaces - 2),
            CryptoValue.create(major: "1.23", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(1234) * BigInt(10).power(decimalPlaces - 3),
            CryptoValue.create(major: "1.234", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(12345) * BigInt(10).power(decimalPlaces - 4),
            CryptoValue.create(major: "1.2345", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(123456) * BigInt(10).power(decimalPlaces - 5),
            CryptoValue.create(major: "1.23456", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(1234567) * BigInt(10).power(decimalPlaces - 6),
            CryptoValue.create(major: "1.234567", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(12345678) * BigInt(10).power(decimalPlaces - 7),
            CryptoValue.create(major: "1.2345678", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(123456789) * BigInt(10).power(decimalPlaces - 8),
            CryptoValue.create(major: "1.23456789", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(1234567890) * BigInt(10).power(decimalPlaces - 9),
            CryptoValue.create(major: "1.234567890", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(12345678901) * BigInt(10).power(decimalPlaces - 10),
            CryptoValue.create(major: "1.2345678901", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(123456789012) * BigInt(10).power(decimalPlaces - 11),
            CryptoValue.create(major: "1.23456789012", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(1234567890123) * BigInt(10).power(decimalPlaces - 12),
            CryptoValue.create(major: "1.234567890123", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(12345678901234) * BigInt(10).power(decimalPlaces - 13),
            CryptoValue.create(major: "1.2345678901234", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(123456789012345) * BigInt(10).power(decimalPlaces - 14),
            CryptoValue.create(major: "1.23456789012345", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(1234567890123456) * BigInt(10).power(decimalPlaces - 15),
            CryptoValue.create(major: "1.234567890123456", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(12345678901234567) * BigInt(10).power(decimalPlaces - 16),
            CryptoValue.create(major: "1.2345678901234567", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(123456789012345678) * BigInt(10).power(decimalPlaces - 17),
            CryptoValue.create(major: "1.23456789012345678", currency: .ethereum)!.minorAmount
        )
        XCTAssertEqual(
            BigInt(1234567890123456789),
            CryptoValue.create(major: "1.234567890123456789", currency: .ethereum)!.minorAmount
        )
    }

    func testIsZero() {
        XCTAssertTrue(CryptoValue.create(major: "0", currency: .bitcoin)!.isZero)
        XCTAssertFalse(CryptoValue.create(major: "0.1", currency: .bitcoin)!.isZero)
    }

    func testIsPositive() {
        XCTAssertFalse(CryptoValue.create(major: "0", currency: .bitcoin)!.isPositive)
        XCTAssertTrue(CryptoValue.create(major: "0.1", currency: .bitcoin)!.isPositive)
        XCTAssertFalse(CryptoValue.create(major: "-0.1", currency: .bitcoin)!.isPositive)
    }

    func testEquatable() {
        XCTAssertEqual(
            CryptoValue.create(major: "0.123", currency: .bitcoin),
            CryptoValue.create(major: "0.123", currency: .bitcoin)
        )
    }

    func testCreateFromMajorRoundOff() {
        XCTAssertEqual(
            300000,
            CryptoValue.create(major: "0.00300000000002", currency: .bitcoin)!.minorAmount
        )
    }

    func testAddition() throws {
        XCTAssertEqual(
            CryptoValue.create(major: "3.00", currency: .ethereum),
            try CryptoValue.create(major: "2.00", currency: .ethereum)! + CryptoValue.create(major: "1.00", currency: .ethereum)!
        )
    }

    func testSubtraction() throws {
        XCTAssertEqual(
            CryptoValue.create(major: "1.00", currency: .ethereum),
            try CryptoValue.create(major: "3.00", currency: .ethereum)! - CryptoValue.create(major: "2.00", currency: .ethereum)!
        )
    }

    func testMultiplication() throws {
        let expected = CryptoValue(storeAmount: BigInt(stringLiteral: "1111111111111111111111111088888888"), currency: .ethereum)
        let value = CryptoValue.create(minor: "33333333333333333333333333", currency: .ethereum)!
        let result = try value * value
        XCTAssertEqual(expected, result)
    }

    func testDivision() throws {
        let expected = CryptoValue.create(major: "1.00", currency: .ethereum)!
        let value = CryptoValue.create(major: "3.00", currency: .ethereum)!
        let result = try value / value
        XCTAssertEqual(expected, result)
    }

    func testMinorString() {
        let expected100MillionMajor = "100000000000000000000000000"
        let value100MillionMajor = CryptoValue.create(major: "100000000.00", currency: .ethereum)!
        XCTAssertEqual(expected100MillionMajor, value100MillionMajor.minorString)

        let expected1Minor = "1"
        let value1Minor = CryptoValue.create(minor: "1", currency: .ethereum)!
        XCTAssertEqual(expected1Minor, value1Minor.minorString)
    }
}

extension CryptoValue {

    fileprivate static func create(major value: String, currency: CryptoCurrency, locale: Locale) -> CryptoValue? {
        guard let majorDecimal = Decimal(string: value, locale: locale), !majorDecimal.isNaN else {
            return nil
        }
        return create(major: majorDecimal, currency: currency)
    }
}
