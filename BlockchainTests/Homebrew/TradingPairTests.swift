//
//  TradingPairTests.swift
//  BlockchainTests
//
//  Created by kevinwu on 8/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class TradingPairTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitializerError() {
        let pair = TradingPair(from: .bitcoin, to: .bitcoin)
        XCTAssert(pair == nil, "Initializer should allow different asset types")
    }

    func testInitializerSuccess() {
        let pair = TradingPair(from: .bitcoin, to: .ethereum)
        XCTAssert(pair != nil, "Initializer should allow different asset types")
    }

    func testSetFrom() {
        var pair = TradingPair(from: .bitcoin, to: .ethereum)!
        pair.from = .bitcoinCash
        XCTAssert(pair.from == .bitcoinCash && pair.to == .ethereum, "From should be settable to a different asset type")
    }

    func testSetTo() {
        var pair = TradingPair(from: .ethereum, to: .bitcoinCash)!
        pair.to = .bitcoin
        XCTAssert(pair.from == .ethereum && pair.to == .bitcoin, "To should be settable to a different asset type")
    }

    func testSetSameFrom() {
        var pair = TradingPair(from: .bitcoinCash, to: .bitcoin)!
        pair.from = .bitcoin
        XCTAssert(pair.from == .bitcoinCash && pair.to == .bitcoin, "From should not be set to the same asset type as To")
    }

    func testSetSameTo() {
        var pair = TradingPair(from: .ethereum, to: .bitcoin)!
        pair.to = .ethereum
        XCTAssert(pair.from == .ethereum && pair.to == .bitcoin, "To should not be set to the same asset type as From")
    }
}
