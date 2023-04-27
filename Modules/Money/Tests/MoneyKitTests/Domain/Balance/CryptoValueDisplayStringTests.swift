// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import XCTest

class CryptoValueDisplayStringTests: XCTestCase {
    func test_displayString() {
        let minor = CryptoValue.create(minor: BigInt("1"), currency: .bitcoin)
        let cases: [(locale: Locale, string: String)] = [
            (.US, "0.00000001 BTC"),
            (.Canada, "0.00000001 BTC"),
            (.France, "0,00000001 BTC"),
            (.Japan, "0.00000001 BTC"),
            (.GreatBritain, "0.00000001 BTC"),
            (.Lithuania, "0,00000001 BTC")
        ]
        for this in cases {
            let result = minor.toDisplayString(includeSymbol: true, locale: this.locale)
            XCTAssertEqual(
                result,
                this.string,
                "\(this.locale), \(this.string): got \(result) instead"
            )
        }
    }

    func test_simpleString() {
        let btc = MoneyValue(cryptoValue: CryptoValue.create(minor: BigInt("91234791789241"), currency: .bitcoin))
        let eth = MoneyValue(cryptoValue: CryptoValue.create(minor: BigInt("791789241"), currency: .ethereum))
        let usd = MoneyValue(fiatValue: FiatValue.create(minor: BigInt("89241"), currency: .USD))

        XCTAssertEqual(btc.toSimpleString(includeSymbol: false), "912347.91789241")
        XCTAssertEqual(btc.toSimpleString(includeSymbol: true), "912347.91789241 BTC")
        XCTAssertEqual(eth.toSimpleString(includeSymbol: false), "0.000000000791789241")
        XCTAssertEqual(eth.toSimpleString(includeSymbol: true), "0.000000000791789241 ETH")
        XCTAssertEqual(usd.toSimpleString(includeSymbol: false), "892.41")
        XCTAssertEqual(usd.toSimpleString(includeSymbol: true), "892.41 USD")
    }
}
