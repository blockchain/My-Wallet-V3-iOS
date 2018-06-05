//
//  AssetURLPayloadFactoryTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 6/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import Foundation

import XCTest
@testable import Blockchain

class AssetURLPayloadFactoryTests: XCTestCase {

    func testBitcoinURLPayloadCreated() {
        let url = URL(string: "\(BitcoinURLPayload.scheme):address")!
        let payload = AssetURLPayloadFactory.create(from: url)
        XCTAssertNotNil(payload)
        XCTAssertTrue(payload is BitcoinURLPayload)
    }

    func testBitcoinCashURLPayloadCreated() {
        let url = URL(string: "\(BitcoinCashURLPayload.scheme):address")!
        let payload = AssetURLPayloadFactory.create(from: url)
        XCTAssertNotNil(payload)
        XCTAssertTrue(payload is BitcoinCashURLPayload)
    }
}
