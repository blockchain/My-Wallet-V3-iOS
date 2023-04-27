// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
@testable import MoneyKitMock
import XCTest

final class MoneyValueConvertTests: XCTestCase {

    var mockCoin6Precision: CryptoCurrency {
        .mockCoin(symbol: "A", displaySymbol: "A", name: "MOCK", precision: 6, sortIndex: 0)
    }

    func testConvertingALGOIntoBTCUsingBTCExchangeRate() {
        let exchangeRate = CryptoValue.create(
            minor: 400,
            currency: .bitcoin
        )
        let value = CryptoValue.create(
            minor: 10000,
            currency: mockCoin6Precision
        )

        let expected = CryptoValue.create(
            minor: 4,
            currency: .bitcoin
        )
        let result = value.convert(using: exchangeRate)
        XCTAssertEqual(result, expected)
    }
}
