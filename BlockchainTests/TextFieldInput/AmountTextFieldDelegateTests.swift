//
//  AmountTextFieldDelegateTests.swift
//  Blockchain
//
//  Created by kevinwu on 10/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

import XCTest
@testable import Blockchain

class AmountTextFieldDelegateTests: XCTestCase {

    // MARK: - Helpers
    // swiftlint:disable line_length
    func simulateTyping(string: String, textField: UITextField) -> String? {
        string.forEach {
            guard let delegate = textField.delegate else { return }
            let shouldChangeText = delegate.textField!(textField, shouldChangeCharactersIn: NSRange(location: textField.text?.count ?? 0, length: 0), replacementString: String($0))
            if shouldChangeText {
                textField.insertText(String($0))
            }
        }
        return textField.text
    }

    func inputTextWithFiatTextFieldDelegate(text: String) -> String? {
        let textField = UITextField()
        let delegate = AmountTextFieldDelegate(maxDecimalPlaces: 2)
        textField.delegate = delegate
        return simulateTyping(string: text, textField: textField)
    }

    // MARK: - Valid input
    func testFiatInputWithNumbers() {
        let input = "123"
        let result = inputTextWithFiatTextFieldDelegate(text: input)
        XCTAssertEqual(result, input)
    }

    func testFiatInputWithLeadingZeroDecimal() {
        let input = "0.12"
        let result = inputTextWithFiatTextFieldDelegate(text: input)
        XCTAssertEqual(result, input)
    }

    func testFiatInputWithTrailingZeroDecimal() {
        let input = "0.10"
        let result = inputTextWithFiatTextFieldDelegate(text: input)
        XCTAssertEqual(result, input)
    }

    func testFiatInputWithNumbersWithPeriodDecimal() {
        let input = "1.23"
        let result = inputTextWithFiatTextFieldDelegate(text: input)
        XCTAssertEqual(result, input)
    }

    func testFiatInputWithNumbersWithCommaDecimal() {
        let input = "1,23"
        let result = inputTextWithFiatTextFieldDelegate(text: input)
        XCTAssertEqual(result, input)
    }

    func testFiatInputWithNumbersWithCurlyCommaDecimal() {
        let input = "1٫23"
        let result = inputTextWithFiatTextFieldDelegate(text: input)
        XCTAssertEqual(result, input)
    }

    // MARK: - Invalid input
    func testFiatInputWithMultipleDecimals() {
        let input = "0.."
        let result = inputTextWithFiatTextFieldDelegate(text: input)
        XCTAssertEqual(result, "0.")
    }

    func testFiatInputWithNonDecimalLeadingZero() {
        let input = "0123"
        let result = inputTextWithFiatTextFieldDelegate(text: input)
        XCTAssertEqual(result, "0")
    }

    func testFiatInputWithDecimalMultipleLeadingZeros() {
        let input = "00.01"
        let result = inputTextWithFiatTextFieldDelegate(text: input)
        XCTAssertEqual(result, "0.01")
    }

    func testFiatInputWithMoreThanTwoDecimalPlaces() {
        let input = "0.123"
        let result = inputTextWithFiatTextFieldDelegate(text: input)
        XCTAssertEqual(result, "0.12")
    }
}
