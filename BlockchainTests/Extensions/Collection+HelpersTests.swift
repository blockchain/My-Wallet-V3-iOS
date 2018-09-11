//
//  Collection+HelpersTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 9/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

import XCTest

class CollectionHelpersTests: XCTestCase {

    func testSafeIndexInBounds() {
        let array = [1, 2, 3, 4, 5]
        XCTAssertNotNil(array[safe: 0])
    }

    func testSafeIndexOutOfBounds() {
        let array = [1, 2, 3, 4, 5]
        XCTAssertNil(array[safe: 100])
    }
}
