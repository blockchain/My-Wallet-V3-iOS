//
//  BitcoinURLPayloadTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 5/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

import XCTest
@testable import Blockchain

class BitcoinURLPayloadTests: XCTestCase {

    func testInvalidScheme() {
        let url = URL(string: "somescheme")
        let payload = BitcoinURLPayload(url: url!)
        XCTAssertNil(payload)
    }

    func testEmptyURI() {
        let url = URL(string: "\(Constants.Schemes.bitcoin)://")
        let payload = BitcoinURLPayload(url: url!)
        XCTAssertNil(payload)
    }

    func testBitcoinWebFormat() {
        let address = "1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv"
        let url = URL(string: "\(Constants.Schemes.bitcoin):\(address)")
        let payload = BitcoinURLPayload(url: url!)
        XCTAssertNotNil(payload)
        XCTAssertEqual(address, payload!.address)
    }

    func testBitcoinWebFormatWithAmount() {
        let address = "1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv"
        let amount = "1.03"
        let url = URL(string: "\(Constants.Schemes.bitcoin):\(address)?amount=\(amount)")
        let payload = BitcoinURLPayload(url: url!)
        XCTAssertNotNil(payload)
        XCTAssertEqual(address, payload!.address)
        XCTAssertEqual(amount, payload!.amount)
    }

    func testBitcoinAddressInHost() {
        let address = "bitcoinaddress"
        let url = URL(string: "\(Constants.Schemes.bitcoin)://\(address)")
        let payload = BitcoinURLPayload(url: url!)
        XCTAssertNotNil(payload)
        XCTAssertEqual(address, payload!.address)
    }

    func testBitcoinAddressInQueryArg() {
        let address = "bitcoinaddress"
        let url = URL(string: "\(Constants.Schemes.bitcoin)://?address=\(address)")
        let payload = BitcoinURLPayload(url: url!)
        XCTAssertNotNil(payload)
        XCTAssertEqual(address, payload!.address)
    }

    func testBitcoinAddressAndAmount() {
        let address = "bitcoinaddress"
        let amount = "1.03"
        let url = URL(string: "\(Constants.Schemes.bitcoin)://\(address)?amount=\(amount)")
        let payload = BitcoinURLPayload(url: url!)
        XCTAssertNotNil(payload)
        XCTAssertEqual(address, payload!.address)
        XCTAssertEqual(amount, payload!.amount)
    }
}
