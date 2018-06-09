//
//  AssetAddressFactoryTests.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

import XCTest
@testable import Blockchain

class AssetAddressFactoryTests: XCTestCase {

    func testBitcoinAddressCorrectlyConstructed() {
        let address = AssetAddressFactory.create(fromAddressString: "test", assetType: .bitcoin)
        XCTAssertTrue(address is BitcoinAddress)
    }

    func testEtherAddressCorrectlyConstructed() {
        let address = AssetAddressFactory.create(fromAddressString: "test", assetType: .ethereum)
        XCTAssertTrue(address is EthereumAddress)
    }

    func testBitcoinCashAddressCorrectlyConstructed() {
        let address = AssetAddressFactory.create(fromAddressString: "test", assetType: .bitcoinCash)
        XCTAssertTrue(address is BitcoinCashAddress)
    }
}
