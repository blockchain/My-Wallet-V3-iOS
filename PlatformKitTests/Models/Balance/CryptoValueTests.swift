//
//  CryptoValueTests.swift
//  PlatformKitTests
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import XCTest

class CryptoValueTests: XCTestCase {
    func testMajorValue() {
        XCTAssertEqual(Decimal(100), CryptoValue.bitcoinFromSatoshis(string: "10000000000")!.majorValue)
        XCTAssertEqual(Decimal(10), CryptoValue.bitcoinFromSatoshis(int: 1_000_000_000).majorValue)
        XCTAssertEqual(Decimal(1), CryptoValue.bitcoinFromSatoshis(int: 100_000_000).majorValue)
        XCTAssertEqual(Decimal(0.1), CryptoValue.bitcoinFromSatoshis(int: 10_000_000).majorValue)
        XCTAssertEqual(Decimal(0.01), CryptoValue.bitcoinFromSatoshis(int: 1_000_000).majorValue)
        XCTAssertEqual(Decimal(0.001), CryptoValue.bitcoinFromSatoshis(int: 100_000).majorValue)
        XCTAssertEqual(Decimal(0.0001), CryptoValue.bitcoinFromSatoshis(int: 10_000).majorValue)
        XCTAssertEqual(Decimal(0.00001), CryptoValue.bitcoinFromSatoshis(int: 1_000).majorValue)
        XCTAssertEqual(Decimal(0.000001), CryptoValue.bitcoinFromSatoshis(int: 100).majorValue)
        XCTAssertEqual(Decimal(0.0000001), CryptoValue.bitcoinFromSatoshis(int: 10).majorValue)
        XCTAssertEqual(Decimal(0.00000001), CryptoValue.bitcoinFromSatoshis(int: 1).majorValue)

        // Comparing Strings below since the value Decimal(4.90993923) will produce precision issues
        // (i.e. the underlying value will be something like 4.9099392300000234821
        XCTAssertEqual("4.90993923", "\(CryptoValue.bitcoinFromSatoshis(int: 490993923).majorValue)")
    }
    
    func testCreateFromMajorBitcoin() {
        XCTAssertEqual(
            1_000_000_000,
            CryptoValue.createFromMajorValue(string: "10", assetType: .bitcoin)!.amount
        )
        XCTAssertEqual(
            100_000_000,
            CryptoValue.createFromMajorValue(string: "1", assetType: .bitcoin)!.amount
        )
        XCTAssertEqual(
            10_000_000,
            CryptoValue.createFromMajorValue(string: "0.1", assetType: .bitcoin)!.amount
        )
        XCTAssertEqual(
            1_000_000,
            CryptoValue.createFromMajorValue(string: "0.01", assetType: .bitcoin)!.amount
        )
        XCTAssertEqual(
            100_000,
            CryptoValue.createFromMajorValue(string: "0.001", assetType: .bitcoin)!.amount
        )
        XCTAssertEqual(
            10_000,
            CryptoValue.createFromMajorValue(string: "0.0001", assetType: .bitcoin)!.amount
        )
        XCTAssertEqual(
            1_000,
            CryptoValue.createFromMajorValue(string: "0.00001", assetType: .bitcoin)!.amount
        )
        XCTAssertEqual(
            100,
            CryptoValue.createFromMajorValue(string: "0.000001", assetType: .bitcoin)!.amount
        )
        XCTAssertEqual(
            10,
            CryptoValue.createFromMajorValue(string: "0.0000001", assetType: .bitcoin)!.amount
        )
        XCTAssertEqual(
            1,
            CryptoValue.createFromMajorValue(string: "0.00000001", assetType: .bitcoin)!.amount
        )
        XCTAssertEqual(
            490993923,
            CryptoValue.createFromMajorValue(string: "4.90993923", assetType: .bitcoin)!.amount
        )
    }

    func testCreateFromMajorEth() {
        let decimalPlaces = CryptoCurrency.ethereum.maxDecimalPlaces
        XCTAssertEqual(
            BigInt(1) * BigInt(10).power(decimalPlaces),
            CryptoValue.createFromMajorValue(string: "1", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(12) * BigInt(10).power(decimalPlaces-1),
            CryptoValue.createFromMajorValue(string: "1.2", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(123) * BigInt(10).power(decimalPlaces-2),
            CryptoValue.createFromMajorValue(string: "1.23", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(1234) * BigInt(10).power(decimalPlaces-3),
            CryptoValue.createFromMajorValue(string: "1.234", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(12345) * BigInt(10).power(decimalPlaces-4),
            CryptoValue.createFromMajorValue(string: "1.2345", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(123456) * BigInt(10).power(decimalPlaces-5),
            CryptoValue.createFromMajorValue(string: "1.23456", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(1234567) * BigInt(10).power(decimalPlaces-6),
            CryptoValue.createFromMajorValue(string: "1.234567", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(12345678) * BigInt(10).power(decimalPlaces-7),
            CryptoValue.createFromMajorValue(string: "1.2345678", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(123456789) * BigInt(10).power(decimalPlaces-8),
            CryptoValue.createFromMajorValue(string: "1.23456789", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(1234567890) * BigInt(10).power(decimalPlaces-9),
            CryptoValue.createFromMajorValue(string: "1.234567890", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(12345678901) * BigInt(10).power(decimalPlaces-10),
            CryptoValue.createFromMajorValue(string: "1.2345678901", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(123456789012) * BigInt(10).power(decimalPlaces-11),
            CryptoValue.createFromMajorValue(string: "1.23456789012", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(1234567890123) * BigInt(10).power(decimalPlaces-12),
            CryptoValue.createFromMajorValue(string: "1.234567890123", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(12345678901234) * BigInt(10).power(decimalPlaces-13),
            CryptoValue.createFromMajorValue(string: "1.2345678901234", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(123456789012345) * BigInt(10).power(decimalPlaces-14),
            CryptoValue.createFromMajorValue(string: "1.23456789012345", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(1234567890123456) * BigInt(10).power(decimalPlaces-15),
            CryptoValue.createFromMajorValue(string: "1.234567890123456", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(12345678901234567) * BigInt(10).power(decimalPlaces-16),
            CryptoValue.createFromMajorValue(string: "1.2345678901234567", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(123456789012345678) * BigInt(10).power(decimalPlaces-17),
            CryptoValue.createFromMajorValue(string: "1.23456789012345678", assetType: .pax)!.amount
        )
        XCTAssertEqual(
            BigInt(1234567890123456789),
            CryptoValue.createFromMajorValue(string: "1.234567890123456789", assetType: .pax)!.amount
        )
    }
    
    func testIsZero() {
        XCTAssertTrue(CryptoValue.createFromMajorValue(string: "0", assetType: .bitcoin)!.isZero)
        XCTAssertFalse(CryptoValue.createFromMajorValue(string: "0.1", assetType: .bitcoin)!.isZero)
    }
    
    func testIsPositive() {
        XCTAssertTrue(CryptoValue.createFromMajorValue(string: "0", assetType: .bitcoin)!.isPositive)
        XCTAssertTrue(CryptoValue.createFromMajorValue(string: "0.1", assetType: .bitcoin)!.isPositive)
        XCTAssertFalse(CryptoValue.createFromMajorValue(string: "-0.1", assetType: .bitcoin)!.isPositive)
    }

    func testEquatable() {
        XCTAssertEqual(
            CryptoValue.createFromMajorValue(string: "0.123", assetType: .bitcoin),
            CryptoValue.createFromMajorValue(string: "0.123", assetType: .bitcoin)
        )
    }   
    
    func testCreateFromMajorRoundOff() {
        XCTAssertEqual(
            300_000,
            CryptoValue.createFromMajorValue(string: "0.00300000000002", assetType: .bitcoin)!.amount
        )
    }
} 
