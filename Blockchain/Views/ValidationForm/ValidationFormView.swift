//
//  ValidationForm.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// `ValidationFormView` is for views that include multiple
/// `ValidationTextFields` (or subclasses) that are nested
/// within a `UIScrollView`.
protocol ValidationFormView {
    var validationFields: [ValidationTextField] { get }
    var scrollView: UIScrollView! { get }
    var keyboard: KeyboardPayload? { get set }

    /// This should be called on `viewDidLoad`. It sets the
    /// `becomeFirstResponder` block and handles offseting
    /// the `UIScrollView` so the currently in focus `ValidationTextField`
    /// is within the correct field of view.
    func handleKeyboardOffset()

    /// This validates all the `ValidationTextFields`.
    /// Should a field not pass validation, that field
    /// will become the first responder.
    func checkFieldsValidity() -> Bool
}

extension ValidationFormView where Self: UIViewController {
    func handleKeyboardOffset() {
        /// This is for handling when the `VerificationTextField`
        /// is covered by the keyboard. Depending on how many
        /// forms we have in the app this could be a candidate for abstraction.
        validationFields.forEach { (field) in
            field.becomeFirstResponderBlock = { [weak self] (validationField) in
                guard let this = self else { return }
                var offsetHeight = this.keyboard?.endingFrame.height
                if let field = validationField as? ValidationDateField {
                    offsetHeight = field.pickerView.frame.height
                }
                guard let height = offsetHeight else { return }
                let insets = UIEdgeInsets(
                    top: 0.0,
                    left: 0.0,
                    bottom: height,
                    right: 0.0
                )
                this.scrollView.contentInset = insets

                let viewSize = CGSize(
                    width: this.scrollView.frame.width,
                    height: this.scrollView.frame.height - height
                )
                let viewableFrame = CGRect(
                    origin: this.scrollView.frame.origin,
                    size: viewSize
                )

                if !viewableFrame.contains(validationField.frame.origin) {
                    this.scrollView.scrollRectToVisible(
                        validationField.frame,
                        animated: true
                    )
                }
            }
        }
    }

    func checkFieldsValidity() -> Bool {
        var valid: Bool = true
        validationFields.forEach({$0.resignFocus()})
        for field in validationFields {
            guard case .valid = field.validate(withStyling: true) else {
                valid = false
                guard !validationFields.contains(where: {$0.isFocused() == true}) else { continue }
                field.becomeFocused()
                continue
            }
        }
        return valid
    }
}
