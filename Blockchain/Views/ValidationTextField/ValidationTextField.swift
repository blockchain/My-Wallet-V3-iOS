//
//  ValidationTextField.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

enum ValidationResult {
    case valid
    case invalid(Error?)
}

@IBDesignable
class ValidationTextField: NibBasedView {

    fileprivate static let primaryFont: UIFont = UIFont(
        name: Constants.FontNames.montserratRegular,
        size: Constants.FontSizes.Small
    ) ?? UIFont.systemFont(ofSize: 16)

    @IBInspectable var baselineFillColor: UIColor = UIColor.gray2 {
        didSet {
            baselineView.backgroundColor = baselineFillColor
        }
    }

    @IBInspectable var supportsAutoCorrect: Bool = false {
        didSet {
            textField.autocorrectionType = supportsAutoCorrect == false ? .no : .yes
        }
    }

    @IBInspectable var placeholderFillColor: UIColor = UIColor.gray3

    @IBInspectable var placeholder: String = "" {
        didSet {
            let font = UIFont(
                name: Constants.FontNames.montserratRegular,
                size: Constants.FontSizes.Small
                ) ?? UIFont.systemFont(ofSize: 16)
            let value = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedStringKey.font: font,
                             NSAttributedStringKey.foregroundColor: placeholderFillColor
                ])
            textField.attributedPlaceholder = value
        }
    }

    var font: UIFont = ValidationTextField.primaryFont {
        didSet {
            textField.font = font
        }
    }

    var returnKeyType: UIReturnKeyType = .default {
        didSet {
            textField.returnKeyType = returnKeyType
        }
    }

    var keyboardType: UIKeyboardType = .default {
        didSet {
            textField.keyboardType = keyboardType
        }
    }

    var returnTappedBlock: (() -> Void)? = nil
    var becomeFirstResponderBlock: ((ValidationTextField) -> Void)? = nil

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var textField: UITextField!
    @IBOutlet fileprivate var baselineView: UIView!

    // MARK: Public Functions

    func becomeFocused() {
        textField.becomeFirstResponder()
    }

    func resignFocus() {
        textField.resignFirstResponder()
    }
}

extension ValidationTextField: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let responderBlock = becomeFirstResponderBlock {
            responderBlock(self)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // TODO: Validation
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let block = returnTappedBlock {
            block()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
