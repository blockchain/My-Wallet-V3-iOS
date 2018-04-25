//
//  PinTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class PinTests: XCTestCase {

    func testInValidPin() {
        let pin = Pin(code: 0000)
        XCTAssertFalse(pin.isValid)
    }

    func testValidPin() {
        let pin = Pin(code: 6309)
        XCTAssertTrue(pin.isValid)
    }

    func testCommonPins() {
        let pin1 = Pin(code: 1111)
        XCTAssertTrue(pin1.isCommon)

        let pin2 = Pin(code: 1234)
        XCTAssertTrue(pin2.isCommon)

        let pin3 = Pin(code: 5923)
        XCTAssertFalse(pin3.isCommon)
    }
}
