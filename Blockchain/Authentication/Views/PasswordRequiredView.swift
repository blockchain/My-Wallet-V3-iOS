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
}

class PasswordRequiredView: UIView {
    @IBOutlet weak var labelHeader: UILabel!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet weak var buttonForgetWallet: UIButton!
    @IBOutlet weak var buttonForgotPassword: UIButton!
    @IBOutlet weak var labelForgetWallet: UILabel!

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
        buttonForgotPassword.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10)
        buttonForgotPassword.titleLabel?.textAlignment = .center
        buttonForgotPassword.setTitle(LocalizationConstants.Authentication.forgotPassword, for: .normal)

        labelForgetWallet.font = UIFont(name: Constants.FontNames.gillSans, size: Constants.FontSizes.SmallMedium)

        buttonForgetWallet.titleLabel?.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Large)
        buttonForgetWallet.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonForgetWallet.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10)
        buttonForgetWallet.titleLabel?.textAlignment = .center

        let tapGesture = UITapGestureRecognizer(target: textFieldPassword, action: #selector(resignFirstResponder))
        addGestureRecognizer(tapGesture)
    }
    
    @IBAction func onForgotPasswordTapped(_ sender: Any) {
        // TODO
    }

    @IBAction func onForgetWalletTapped(_ sender: Any) {
        // TODO
    }

    @IBAction func onContinueTapped(_ sender: Any) {
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
        let nib = UINib(nibName: "PasswordRequiredView", bundle: Bundle.main)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! PasswordRequiredView
    }
}
