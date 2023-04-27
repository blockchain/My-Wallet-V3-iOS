// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
@testable import MoneyKitMock
import XCTest

// Tests default implementations of MoneyOperating
final class MoneyOperatingTests: XCTestCase {

    func moneyValueUSD(_ int: Int) -> MoneyValue {
        MoneyValue.create(minor: BigInt(int), currency: .fiat(.USD))
    }

    func moneyValueIQD(_ int: Int) -> MoneyValue {
        MoneyValue.create(minor: BigInt(int), currency: .fiat(.IQD))
    }

    func moneyValue(_ int: Int, _ currency: CurrencyType) -> MoneyValue {
        MoneyValue.create(minor: BigInt(int), currency: currency)
    }

    func testMoneyValueMultiplication() throws {
        let r = try moneyValueUSD(1501) * moneyValueUSD(10002)
        XCTAssertEqual(r.minorAmount, BigInt(150130))
    }

    private func divide(
        x: MoneyValue,
        y: MoneyValue,
        shouldBe result: BigInt
    ) {
        XCTAssertEqual(try (x / y).minorAmount, result)
    }

    private func percentage(
        x: MoneyValue,
        y: MoneyValue,
        shouldBe result: Decimal
    ) {
        XCTAssertEqual(try x.percentage(in: y), result)
    }

    func testPercentage() {
        percentage(
            x: moneyValueUSD(000),
            y: moneyValueUSD(100000000000),
            shouldBe: Decimal(string: "0")!
        )
        percentage(
            x: moneyValueUSD(-12281),
            y: moneyValueUSD(76461),
            shouldBe: Decimal(string: "-0.1606")!
        )
    }

    // USD 2 decimal places division
    func testMoneyValueDivisionUSD() throws {
        divide(
            x: moneyValueUSD(000),
            y: moneyValueUSD(100000000000),
            shouldBe: BigInt(000)
        )
        divide(
            x: moneyValueUSD(001),
            y: moneyValueUSD(100000000),
            shouldBe: BigInt(000)
        )
        divide(
            x: moneyValueUSD(001),
            y: moneyValueUSD(100000000000),
            shouldBe: BigInt(000)
        )
        divide(
            x: moneyValueUSD(100),
            y: moneyValueUSD(10000),
            shouldBe: BigInt(001)
        )
        divide(
            x: moneyValueUSD(100),
            y: moneyValueUSD(100),
            shouldBe: BigInt(100)
        )
        divide(
            x: moneyValueUSD(100),
            y: moneyValueUSD(100000),
            shouldBe: BigInt(000)
        )
        divide(
            x: moneyValueUSD(1501),
            y: moneyValueUSD(10002),
            shouldBe: BigInt(015)
        )
        divide(
            x: moneyValueUSD(3850),
            y: moneyValueUSD(68400),
            shouldBe: BigInt(005)
        )
        divide(
            x: moneyValueUSD(15001),
            y: moneyValueUSD(10002),
            shouldBe: BigInt(149)
        )
        divide(
            x: moneyValueUSD(38500),
            y: moneyValueUSD(1000000),
            shouldBe: BigInt(003)
        )
        divide(
            x: moneyValueUSD(38500),
            y: moneyValueUSD(385000),
            shouldBe: BigInt(010)
        )
        divide(
            x: moneyValueUSD(100000000),
            y: moneyValueUSD(100000),
            shouldBe: BigInt(100000)
        )
        divide(
            x: moneyValueUSD(100000000000),
            y: moneyValueUSD(001),
            shouldBe: BigInt(10000000000000)
        )
        divide(
            x: moneyValueUSD(100000000000),
            y: moneyValueUSD(002),
            shouldBe: BigInt(5000000000000)
        )
        divide(
            x: moneyValueUSD(100000000000),
            y: moneyValueUSD(100),
            shouldBe: BigInt(100000000000)
        )
    }

    // IQD 3 decimal places division
    func testMoneyValueDivisionIQD() throws {
        divide(
            x: moneyValueIQD(0000),
            y: moneyValueIQD(1000000000000),
            shouldBe: BigInt(0000)
        )
        divide(
            x: moneyValueIQD(0010),
            y: moneyValueIQD(1000000000),
            shouldBe: BigInt(0000)
        )
        divide(
            x: moneyValueIQD(0010),
            y: moneyValueIQD(1000000000000),
            shouldBe: BigInt(0000)
        )
        divide(
            x: moneyValueIQD(1000),
            y: moneyValueIQD(100000),
            shouldBe: BigInt(0010)
        )
        divide(
            x: moneyValueIQD(1000),
            y: moneyValueIQD(1000),
            shouldBe: BigInt(1000)
        )
        divide(
            x: moneyValueIQD(1000),
            y: moneyValueIQD(1000000),
            shouldBe: BigInt(0001)
        )
        divide(
            x: moneyValueIQD(15010),
            y: moneyValueIQD(100002),
            shouldBe: BigInt(0150)
        )
        divide(
            x: moneyValueIQD(38500),
            y: moneyValueIQD(684000),
            shouldBe: BigInt(0056)
        )
        divide(
            x: moneyValueIQD(150010),
            y: moneyValueIQD(100020),
            shouldBe: BigInt(1499)
        )
        divide(
            x: moneyValueIQD(385000),
            y: moneyValueIQD(10000000),
            shouldBe: BigInt(0038)
        )
        divide(
            x: moneyValueIQD(385000),
            y: moneyValueIQD(3850000),
            shouldBe: BigInt(0100)
        )
        divide(
            x: moneyValueIQD(1000000000),
            y: moneyValueIQD(1000000),
            shouldBe: BigInt(1000000)
        )
        divide(
            x: moneyValueIQD(1000000000000),
            y: moneyValueIQD(0010),
            shouldBe: BigInt(100000000000000)
        )
        divide(
            x: moneyValueIQD(1000000000000),
            y: moneyValueIQD(0020),
            shouldBe: BigInt(50000000000000)
        )
        divide(
            x: moneyValueIQD(1000000000000),
            y: moneyValueIQD(1000),
            shouldBe: BigInt(1000000000000)
        )
    }

    func testMoneyValueDivisionByZero() {
        XCTAssertThrowsError(try moneyValueUSD(10) / moneyValueUSD(0))
    }

    func testHasPositiveDisplayableBalance() {
        XCTAssertFalse(MoneyValue.create(major: "0.000000001", currency: .crypto(.ethereum))!.hasPositiveDisplayableBalance)
        XCTAssertTrue(MoneyValue.create(major: "0.00000001", currency: .crypto(.ethereum))!.hasPositiveDisplayableBalance)
    }

    func testCreateOne() {
        let cryptoCurrency: CryptoCurrency = .mockCoin(
            symbol: "P24",
            name: "PRECISION_24",
            precision: 24
        )
        let oneCoinA = MoneyValue.one(currency: .crypto(cryptoCurrency))
        let oneCoinB = MoneyValue.create(minor: BigInt(10).power(24), currency: .crypto(cryptoCurrency))
        XCTAssertEqual(oneCoinA, oneCoinB)
    }
}
