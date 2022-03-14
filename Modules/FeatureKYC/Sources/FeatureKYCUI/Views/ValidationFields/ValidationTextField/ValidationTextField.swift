// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import UIKit

enum ValidationError: Error {
    case unknown
    case invalidSelection
    case minimumDateRequirement
}

enum ValidationResult {
    case valid
    case invalid(ValidationError?)
}

extension ValidationResult {

    static func == (lhs: ValidationResult, rhs: ValidationResult) -> Bool {
        switch (lhs, rhs) {
        case (.valid, .valid):
            return true
        case (.valid, .invalid):
            return false
        case (.invalid, .valid):
            return false
        case (.invalid, .invalid):
            return true
        }
    }
}

typealias ValidationBlock = (String?) -> ValidationResult

@IBDesignable
class ValidationTextField: NibBasedView {

    // MARK: Private Class Properties

    fileprivate static let primaryFont = UIFont(
        name: Constants.FontNames.montserratRegular,
        size: Constants.FontSizes.Small
    ) ?? UIFont.systemFont(ofSize: 16)

    // MARK: Private Properties

    fileprivate var validity: ValidationResult = .valid

    override var bundle: Bundle { .module }

    // MARK: IBInspectable Properties

    @IBInspectable var baselineFillColor = UIColor.gray3 {
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
    @IBInspectable var placeholderFillColor = UIColor.gray3

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
                attributes: [
                    NSAttributedString.Key.font: font,
                    NSAttributedString.Key.foregroundColor: placeholderFillColor
                ]
            )
            textField.attributedPlaceholder = value
        }
    }

    @IBInspectable var textColor = UIColor.darkGray {
        didSet {
            textField.textColor = textColor
        }
    }

    // MARK: Public Properties

    var accessoryView: UIView? {
        didSet {
            textField.inputAccessoryView = accessoryView
        }
    }

    var autocapitalizationType: UITextAutocapitalizationType = .words {
        didSet {
            textField.autocapitalizationType = autocapitalizationType
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

    var contentType: UITextContentType? {
        didSet {
            textField.textContentType = contentType
        }
    }

    var text: String? {
        get {
            textField.text
        }
        set {
            textField.text = newValue
        }
    }

    var textFieldInputView: UIView? {
        didSet {
            textField.inputView = textFieldInputView
        }
    }

    var isEnabled: Bool {
        get {
            textField.isEnabled
        }
        set {
            textField.isEnabled = newValue
            updateBackgroundColor()
        }
    }

    override var accessibilityIdentifier: String? {
        didSet {
            textField.accessibilityIdentifier = accessibilityIdentifier
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

    /// This closure is called whenever the text is changed
    /// inside the contained UITextField
    var textChangedBlock: ((String?) -> Void)?

    /// This closure is called before the text in the text field is replaced.
    /// You can use this replacement block if you wish to format the text
    /// before it gets replaced.
    var textReplacementBlock: ((String) -> String)?

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var textField: UITextField!
    @IBOutlet fileprivate var baselineView: UIView!
    @IBOutlet fileprivate var textFieldTrailingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var errorImageView: UIImageView!

    // MARK: Public Functions

    func isFocused() -> Bool {
        textField.isFirstResponder
    }

    func becomeFocused() {
        textField.becomeFirstResponder()
    }

    func resignFocus() {
        textField.resignFirstResponder()
    }

    func validate(withStyling: Bool = false) -> ValidationResult {
        if let block = validationBlock {
            validity = block(textField.text)
        } else {
            if textField.text?.count == 0 || textField.text == nil {
                validity = optionalField ? .valid : .invalid(nil)
            } else {
                validity = .valid
            }
        }
        guard withStyling == true else { return validity }

        applyValidity(animated: true)
        return validity
    }

    // MARK: Private IBActions

    @IBAction fileprivate func onTextFieldChanged(_ sender: Any) {
        textChangedBlock?(textField.text)
    }

    // MARK: Private Functions

    private func updateBackgroundColor() {
        backgroundColor = isEnabled ? .white : .disabled
        textField.backgroundColor = backgroundColor
    }

    fileprivate func applyValidity(animated: Bool) {
        switch validity {
        case .valid:
            guard textFieldTrailingConstraint.constant != 0 else { return }
            textFieldTrailingConstraint.constant = 0
            baselineFillColor = .gray2

        case .invalid:
            guard textFieldTrailingConstraint.constant != errorImageView.bounds.width else { return }
            textFieldTrailingConstraint.constant = errorImageView.bounds.width
            baselineFillColor = .red
        }

        setNeedsLayout()
        guard animated == true else {
            layoutIfNeeded()
            return
        }

        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: [.beginFromCurrentState, .curveEaseOut],
            animations: {
                self.layoutIfNeeded()
            },
            completion: nil
        )
    }
}

extension ValidationTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        guard let textReplacementBlock = textReplacementBlock else {
            return true
        }

        let replacedString = (text as NSString).replacingCharacters(in: range, with: string)
        textField.text = textReplacementBlock(replacedString)
        return false
    }

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

        if textField.text?.count == 0 || textField.text == nil {
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
