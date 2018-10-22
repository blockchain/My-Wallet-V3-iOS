//
//  ArraysTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

import XCTest

class ArraysTests: XCTestCase {

    private struct TestCodableClass: Codable {
        let prop1: String
        let prop2: Int
    }

    func testSuccessfulCast() {
        let array: [Any] = [
            [
                "prop1": "something",
                "prop2": 123
            ]
        ]
        let value = array.castJsonObjects(type: TestCodableClass.self)
        XCTAssertEqual(1, value.count)
    }

    func testFailedCast_invalidProperties() {
        let array: [Any] = [
            [
                "_prop1": "something",
                "_prop2": 123
            ]
        ]
        let value = array.castJsonObjects(type: TestCodableClass.self)
        XCTAssertEqual(0, value.count)
    }

    func testFailedCast_invalidJson() {
        let array: [Any] = [
        "{\"prop1\": \"something\", \"prop2\": 123"
        ]
        let value = array.castJsonObjects(type: TestCodableClass.self)
        XCTAssertEqual(0, value.count)
    }
}
