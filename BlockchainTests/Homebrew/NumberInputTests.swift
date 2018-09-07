//
//  NumberInputTests.swift
//  BlockchainTests
//
//  Created by kevinwu on 8/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class NumberInputTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAddingNonZeroNumbers() {
        let model = NumberInputViewModel()
        model.add(character: "4")
        model.add(character: "2")
        XCTAssert(model.input == "42", "Nonzero numbers should be added")
    }

    func testAddingZeroNumbers() {
        let model = NumberInputViewModel()
        (0..<5).forEach { _ in
            model.add(character: "0")
        }
        XCTAssert(model.input == "0", "Zeroes should not be added to a zero input")
    }

    func testAddingZeroAndNonZeroNumbers() {
        let model = NumberInputViewModel()
        model.add(character: "0")
        model.add(character: "4")
        model.add(character: "0")
        model.add(character: "2")
        model.add(character: "0")
        XCTAssert(model.input == "4020", "Leading zeroes should not be added to an input without a decimal")
    }

    func testAddingDecimals() {
        let model = NumberInputViewModel()
        (0..<5).forEach { _ in
            model.add(character: ".")
        }
        XCTAssert(model.input == "0.", "Only one decimal is allowed")
    }

    func testAddingDecimalWithLeadingZero() {
        let model = NumberInputViewModel()
        model.add(character: "0")
        model.add(character: ".")
        model.add(character: "4")
        model.add(character: "0")
        model.add(character: "2")
        XCTAssert(model.input == "0.402", "Leading zeroes should be added to an input with a decimal")
    }

    func testBackspaceWithExistingInput() {
        let model = NumberInputViewModel(newInput: "0.0234")
        model.backspace()
        XCTAssert(model.input == "0.023", "Backspace should remove last character")
    }

    func testBackspaceWithInputLengthOne() {
        let assertMessage = "Backspace on an input of length zero should return zero"

        let zero = NumberInputViewModel(newInput: "0")
        zero.backspace()
        XCTAssert(zero.input == "0", assertMessage)

        let one = NumberInputViewModel(newInput: "1")
        one.backspace()
        XCTAssert(one.input == "0", assertMessage)
    }
}
