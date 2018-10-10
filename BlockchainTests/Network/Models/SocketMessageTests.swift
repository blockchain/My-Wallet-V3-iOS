//
//  SocketMessageTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 9/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class SocketMessageTests: XCTestCase {

    func testDecodingExchangeRates() {
        let json = """
        {
         "seqnum":12,
         "channel":"exchange_rate",
         "event":"exchangeRate",
         "rates": [
            {"pair":"USD-BTC","price":"0.00015351"},
            {"pair":"USD-ETH","price":"0.00455498"},
            {"pair":"USD-BCH","price":"0.00193979"}
         ]
        }
        """.data(using: .utf8)!

        let exchangeRates = try? JSONDecoder().decode(ExchangeRates.self, from: json)
        XCTAssertNotNil(exchangeRates, "ExchangeRates could not be decoded")

        let usdBtcPair = exchangeRates!.rates.first(where: { $0.pair == "USD-BTC" })
        XCTAssertNotNil(usdBtcPair, "USD-BTC pair not found")
        XCTAssertEqual(Decimal(string: "0.00015351")!, usdBtcPair!.price)
    }
}
