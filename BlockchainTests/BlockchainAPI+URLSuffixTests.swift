//
//  BlockchainAPI+URLSuffixTests.swift
//  BlockchainTests
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class BlockchainAPIURLSuffixTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Bitcoin

    func testSuffixURLWithValidBitcoinAddress() {
        let btcAddress = BitcoinAddress(string: "1W3hBBAnECvpmpFXcBrWoBXXihJAEkTmA")
        let url = BlockchainAPI.suffixURL(btcAddress: btcAddress)
        let expected = "https://blockchain.info/address/\(btcAddress.address!)?format=json"
        XCTAssertNotNil(url, "Expected the url to be \(expected), but got nil.")
    }

    // TODO: enable test when address validation is implemented in BitcoinAddress struct.

//    func testSuffixURLWithInvalidBitcoinAddress() {
//        let invalidBtcAddress = BitcoinAddress(string: "12345")
//        let url = BlockchainAPI.suffixURL(btcAddress: invalidBtcAddress)
//        XCTAssertNil(url, "Expected the url to be nil due to an invalid address.")
//    }

    // MARK: - Bitcoin Cash

    func testSuffixURLWithValidBitcoinCashAddress() {
        let bchAddress = BitcoinCashAddress(string: "qqzhunu9f7p39e8kgchr628z9wsdxq0c5ua3yf4kzr")
        let url = BlockchainAPI.suffixURL(bchAddress: bchAddress)
        let expected = "https://api.blockchain.info/bch/multiaddr?active=\(bchAddress.address!)"
        XCTAssertNotNil(url, "Expected the url to be \(expected), but got nil.")
    }

    // TODO: enable test when address validation is implemented in BitcoinCashAddress struct.

//    func testSuffixURLWithInvalidBitcoinCashAddress() {
//        let invalidBchAddress = BitcoinCashAddress(string: "abc")
//        let url = BlockchainAPI.suffixURL(bchAddress: invalidBchAddress)
//        XCTAssertNil(url, "Expected the url to be nil due to an invalid address.")
//    }
}
