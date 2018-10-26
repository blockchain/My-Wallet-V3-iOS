//
//  AmountTextFieldDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 10/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class AmountTextFieldDelegate: NSObject, UITextFieldDelegate {

    private let maxDecimalPlaces: Int
    private let decimalSeparators = [".", ",", "٫"]

    init(maxDecimalPlaces: Int) {
        self.maxDecimalPlaces = maxDecimalPlaces
        super.init()
    }

    // TODO: IOS-1521 only allow numbers and decimal separators,
    // but ensure international support (Eastern Arabic, Hindi decimal digit character sets, etc)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let newString = text.replacingCharacters(in: textRange, with: string)

            var decimalSeparator: String?
            for separator in decimalSeparators {
                if newString.contains(separator) {
                    decimalSeparator = separator
                    break
                }
            }

            guard let separator = decimalSeparator else {
                // Only 1 leading zero
                if range.location == 1,
                    textField.text == "0" {
                    return false
                }
                return true
            }

            let components = newString.components(separatedBy: separator)

            // Only one comma or point in input field allowed
            if components.count > 2 {
                return false
            }

            // Enforce maximum decimal places
            if components.count == 2 {
                guard let decimal = components.last else {
                    return true
                }
                return decimal.count <= maxDecimalPlaces
            }
        }

        return true
    }
}
