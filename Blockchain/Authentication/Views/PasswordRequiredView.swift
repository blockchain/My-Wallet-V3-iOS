//
//  PasswordRequiredView.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol PasswordRequiredViewDelegate: class {
    func didContinue(with password: String)

    func didTapForgetWallet()

    func didTapForgotPassword()
}

/// View displayed when a password is required for the user to access their wallet.
/// This is typically displayed if the user has not yet set a pin.
class PasswordRequiredView: UIView {
    @IBOutlet fileprivate var labelHeader: UILabel!
    @IBOutlet fileprivate var textFieldPassword: UITextField!
    @IBOutlet fileprivate var buttonContinue: UIButton!
    @IBOutlet fileprivate var buttonForgetWallet: UIButton!
    @IBOutlet fileprivate var buttonForgotPassword: UIButton!
    @IBOutlet fileprivate var labelForgetWallet: UILabel!

    weak var delegate: PasswordRequiredViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        labelHeader.font = UIFont(name: Constants.FontNames.gillSans, size: Constants.FontSizes.SmallMedium)

        textFieldPassword.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Small)
        textFieldPassword.text = ""
        textFieldPassword.delegate = self

        buttonContinue.titleLabel?.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Large)

        buttonForgotPassword.titleLabel?.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Large)
        buttonForgotPassword.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonForgotPassword.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        buttonForgotPassword.titleLabel?.textAlignment = .center
        buttonForgotPassword.setTitle(LocalizationConstants.Authentication.forgotPassword, for: .normal)

        labelForgetWallet.font = UIFont(name: Constants.FontNames.gillSans, size: Constants.FontSizes.SmallMedium)

        buttonForgetWallet.titleLabel?.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Large)
        buttonForgetWallet.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonForgetWallet.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        buttonForgetWallet.titleLabel?.textAlignment = .center

        let tapGesture = UITapGestureRecognizer(target: textFieldPassword, action: #selector(resignFirstResponder))
        addGestureRecognizer(tapGesture)
    }

    @IBAction private func onForgotPasswordTapped(_ sender: Any) {
        delegate?.didTapForgotPassword()
    }

    @IBAction private func onForgetWalletTapped(_ sender: Any) {
        delegate?.didTapForgetWallet()
    }

    @IBAction private func onContinueTapped(_ sender: Any) {
        authenticate()
    }

    private func authenticate() {
        guard let cleanedPassword = textFieldPassword.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
            return
        }

        textFieldPassword.resignFirstResponder()
        textFieldPassword.text = nil

        delegate?.didContinue(with: cleanedPassword)
    }
}

extension PasswordRequiredView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textFieldPassword {
            authenticate()
        }
        return true
    }
}

extension PasswordRequiredView {
    static func instanceFromNib() -> PasswordRequiredView {
        let nib = UINib(nibName: "MainWindow", bundle: Bundle.main)
        let contents = nib.instantiate(withOwner: nil, options: nil)
        return contents.first { item -> Bool in
            item is PasswordRequiredView
        } as! PasswordRequiredView
    }
}
