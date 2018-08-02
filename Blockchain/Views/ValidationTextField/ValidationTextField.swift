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

typealias ValidationBlock = ((String?) -> ValidationResult)

@IBDesignable
class ValidationTextField: NibBasedView {

    // MARK: Private Class Properties

    fileprivate static let primaryFont: UIFont = UIFont(
        name: Constants.FontNames.montserratRegular,
        size: Constants.FontSizes.Small
    ) ?? UIFont.systemFont(ofSize: 16)

    // MARK: Private Properties

    fileprivate var validity: ValidationResult = .valid {
        didSet {
            // TODO: Show the `x` when it is invalid.
            switch validity {
            case .invalid:
                baselineFillColor = UIColor.red
            case .valid:
                baselineFillColor = UIColor.gray2
            }
        }
    }

    // MARK: IBInspectable Properties

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

    // MARK: Public Properties

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

    var text: String? = "" {
        didSet {
            textField.text = text
        }
    }

    /// This closure is called when the user taps `next`
    /// or `done` etc. and the `textField` resigns.
    var returnTappedBlock: (() -> Void)? = nil

    /// This closure is called when a field is in
    /// focus. You can use it to handle scrolling to
    /// the particular textField.
    var becomeFirstResponderBlock: ((ValidationTextField) -> Void)? = nil

    /// This closure is responsible for validation.
    /// If the return value is invalid, the error state
    /// is shown.
    var validationBlock: ValidationBlock? = nil

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
        if let block = validationBlock {
            validity = block(textField.text)
        }
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
