//
//  BitcoinAddressTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 6/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class BitcoinAddressTests: XCTestCase {

    private var wallet: Wallet!

    override func setUp() {
        super.setUp()
        wallet = WalletManager.shared.wallet
        wallet.loadJS()
    }

    func testBtcToBchTransformationNoBchPrefix() {
        let btcAddress = BitcoinAddress(string: "1W3hBBAnECvpmpFXcBrWoBXXihJAEkTmA")
        let bchAddress = btcAddress.toBitcoinCashAddress(wallet: wallet)
        XCTAssertNotNil(bchAddress)
        XCTAssertFalse(bchAddress!.address.contains(":"))
    }
}
