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

    @IBInspectable var baselineFillColor: UIColor = UIColor.gray3 {
        didSet {
            baselineView.backgroundColor = baselineFillColor
        }
    }

    @IBInspectable var supportsAutoCorrect: Bool = false {
        didSet {
            textField.autocorrectionType = supportsAutoCorrect == false ? .no : .yes
        }
    }

    /// Fill color for placeholder text.
    @IBInspectable var placeholderFillColor: UIColor = UIColor.gray3

    /// If the field is optional than this should be `true`.
    /// This prevents you from having to check the field for
    /// any input in the `validationBlock`. The `validationBlock`
    /// should only be used for custom validation logic.
    @IBInspectable var optionalField: Bool = true

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

    @IBInspectable var textColor: UIColor = UIColor.darkGray {
        didSet {
            textField.textColor = textColor
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

    var contentType: UITextContentType? {
        didSet {
            textField.textContentType = contentType
        }
    }

    var text: String? = "" {
        didSet {
            textField.text = text
        }
    }

    var textFieldInputView: UIView? = nil {
        didSet {
            textField.inputView = textFieldInputView
        }
    }

    /// This closure is called when the user taps `next`
    /// or `done` etc. and the `textField` resigns.
    var returnTappedBlock: (() -> Void)?

    /// This closure is called when a field is in
    /// focus. You can use it to handle scrolling to
    /// the particular textField.
    var becomeFirstResponderBlock: ((ValidationTextField) -> Void)?

    /// This closure is responsible for validation.
    /// If the return value is invalid, the error state
    /// is shown.
    var validationBlock: ValidationBlock?

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var textField: UITextField!
    @IBOutlet fileprivate var baselineView: UIView!
    @IBOutlet fileprivate var textFieldTrailingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var errorImageView: UIImageView!

    // MARK: Public Functions

    func isFocused() -> Bool {
        return textField.isFirstResponder
    }

    func becomeFocused() {
        textField.becomeFirstResponder()
    }

    func resignFocus() {
        textField.resignFirstResponder()
    }

    func validate() -> ValidationResult {
        if let block = validationBlock {
            validity = block(textField.text)
        } else {
            if textField.text?.count == 0 || textField.text == nil {
                validity = optionalField ? .valid : .invalid(nil)
            } else {
                validity = .valid
            }
        }

        applyValidity(animated: true)
        return validity
    }

    // MARK: Private Functions

    fileprivate func applyValidity(animated: Bool) {
        switch validity {
        case .valid:
            guard textFieldTrailingConstraint.constant != 0 else { return }
            textFieldTrailingConstraint.constant = 0

        case .invalid:
            guard textFieldTrailingConstraint.constant != errorImageView.bounds.width else { return }
            textFieldTrailingConstraint.constant = errorImageView.bounds.width
        }

        setNeedsLayout()
        guard animated == true else {
            layoutIfNeeded()
            return
        }

        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: [.beginFromCurrentState, .curveEaseOut], animations: {
                self.layoutIfNeeded()
        }, completion: nil)
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
            applyValidity(animated: true)
            return
        }

        if (textField.text?.count == 0 || textField.text == nil) {
            validity = optionalField ? .valid : .invalid(nil)
        } else {
            validity = .valid
        }

        applyValidity(animated: true)
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
