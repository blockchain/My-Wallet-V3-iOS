// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureTransactionUI
import MoneyKit
import PlatformKit
import RxBlocking
import XCTest

class MoneyValueInputScannerTests: XCTestCase {

    func test_CanResetValuesCorrectly_InFiat() throws {
        // Given
        let currency = FiatCurrency.GBP
        let decimalAccurancy = 10
        let scanner = MoneyValueInputScanner(maxDigits: .init(integral: decimalAccurancy, fractional: currency.precision))

        // When
        let inputs = [0, 100, 12321, 112301, 1164212, 1164207, 10012302, 1000000023]
        let ouputs = ["0", "1", "123.21", "1123.01", "11642.12", "11642.07", "100123.02", "10000000.23"]
        for (index, input) in inputs.enumerated() {
            let moneyValue = MoneyValue.create(minor: input, currency: currency.currencyType)
            scanner.reset(to: moneyValue)
            // Then
            do {
                let result = try scanner.input.toBlocking().first()
                let expectedResult = ouputs[index]
                XCTAssertEqual(result!.amount, expectedResult)
            } catch {
                XCTFail("reseting to a certain amount failed")
            }
        }
    }

    func test_CanResetValuesCorrectly_InBTC() throws {
        // Given
        let currency = CryptoCurrency.bitcoin
        let decimalAccurancy = 10
        let scanner = MoneyValueInputScanner(maxDigits: .init(integral: decimalAccurancy, fractional: currency.precision))

        // When
        let inputs = [0, 100, 12321, 112301, 1164212, 1164207, 10012302, 1000000023, 100000000231232]
        let ouputs = ["0", "0.000001", "0.00012321", "0.00112301", "0.01164212", "0.01164207", "0.10012302", "10.00000023", "1000000.00231232"]
        for (index, input) in inputs.enumerated() {
            let moneyValue = MoneyValue.create(minor: input, currency: currency.currencyType)
            scanner.reset(to: moneyValue)
            // Then
            do {
                let result = try scanner.input.toBlocking().first()
                let expectedResult = ouputs[index]
                XCTAssertEqual(result!.amount, expectedResult)
            } catch {
                XCTFail("reseting to a certain amount failed")
            }
        }
    }

    func test_CanParseStringAmountValueCorrectly() throws {
        // Given
        let currency = CryptoCurrency.bitcoin
        let decimalAccurancy = 10
        let scanner = MoneyValueInputScanner(maxDigits: .init(integral: decimalAccurancy, fractional: currency.precision))

        // When empty value
        var input = scanner.parse(amount: "")

        // Then
        XCTAssertEqual(input.string, "0")
        XCTAssertTrue(input.isPlaceholderZero)

        // When zero value
        input = scanner.parse(amount: "0")

        // Then
        XCTAssertEqual(input.string, "0")
        XCTAssertFalse(input.isPlaceholderZero)

        // When specific values
        input = scanner.parse(amount: "0.01")
        XCTAssertEqual(input.string, "0.01")

        input = scanner.parse(amount: "100")
        XCTAssertEqual(input.string, "100")

        input = scanner.parse(amount: "100.01")
        XCTAssertEqual(input.string, "100.01")

        input = scanner.parse(amount: "1,123.01")
        XCTAssertEqual(input.string, "1123.01")

        input = scanner.parse(amount: "32,123.122")
        XCTAssertEqual(input.string, "32123.122")
    }
}
