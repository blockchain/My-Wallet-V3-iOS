//
//  PasswordConfirmView.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/4/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// View presented when the user's password must be provided
class PasswordConfirmView: BCModalContentView {

    typealias OnPasswordConfirmHandler = ((_ password: String) -> Void)

    @IBOutlet private weak var labelDescription: UILabel!
    @IBOutlet private weak var textFieldPassword: BCTextField!
    @IBOutlet private weak var buttonContinue: UIButton!

    var validateSecondPassword = false

    var confirmHandler: OnPasswordConfirmHandler?

    override func awakeFromNib() {
        super.awakeFromNib()
        labelDescription.font = UIFont(name: Constants.FontNames.gillSans, size: Constants.FontSizes.SmallMedium)

        textFieldPassword.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Small)
        textFieldPassword.placeholder = LocalizationConstants.Authentication.password

        buttonContinue.titleLabel?.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Large)
        buttonContinue.setTitle(LocalizationConstants.continueString, for: .normal)

        textFieldPassword.delegate = self
    }

    @IBAction func didTapContinue(_ sender: Any) {
        confirmPassword()
    }

    private func confirmPassword() {
        guard let passwordText = textFieldPassword.text else {
            return
        }
        self.confirmHandler?(passwordText)
        self.textFieldPassword.text = nil
    }

    func updateLabelDescription(text: String) {
        labelDescription.text = text.count > 0 ? text : LocalizationConstants.Authentication.secondPasswordDefaultDescription
    }

    override func modalWasDismissed() {
        ModalPresenter.shared.closeAllModals()
    }
}

extension PasswordConfirmView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textFieldPassword == textFieldPassword {
            confirmPassword()
        }
        return true
    }
}

extension PasswordConfirmView {
    static func instanceFromNib() -> PasswordConfirmView {
        let nib = UINib(nibName: "PasswordConfirmView", bundle: Bundle.main)
        let contents = nib.instantiate(withOwner: nil, options: nil)
        return contents.first { $0 is PasswordConfirmView } as! PasswordConfirmView
    }
}
