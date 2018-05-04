//
//  AuthenticationCoordinator+TouchID.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension AuthenticationCoordinator {
    @objc internal func authenticateWithBiometrics() {
        pinEntryViewController?.view.isUserInteractionEnabled = false
        isPromptingForBiometricAuthentication = true
        AuthenticationManager.shared.authenticateUsingBiometrics { authenticated, authenticationError in
            self.isPromptingForBiometricAuthentication = false
            if let error = authenticationError {
                self.handleBiometricAuthenticationError(with: error)
            }
            DispatchQueue.main.async { [weak self] in
                self?.pinEntryViewController?.view.isUserInteractionEnabled = true
            }
            if authenticated {
                DispatchQueue.main.async { [weak self] in
                    self?.showVerifyingBusyView(withTimeout: 30)
                }
                guard let pinKey = BlockchainSettings.App.shared.pinKey,
                    let pin = KeychainItemWrapper.pinFromKeychain() else {
                        AlertViewPresenter.shared.showKeychainReadError()
                        return
                }
                WalletManager.shared.wallet.apiGetPINValue(pinKey, pin: pin)
            }
        }
    }

    // TODO: migrate to the responsible controller that prompts for authentication
    func handleBiometricAuthenticationError(with error: AuthenticationError) {
        if let description = error.description {
            DispatchQueue.main.async {
                AlertViewPresenter.shared.standardNotify(message: description, title: LocalizationConstants.Errors.error, handler: nil)
            }
        }
    }

    // TODO: migrate to the responsible controller that prompts for authentication
    func handlePasscodeAuthenticationError(with error: AuthenticationError) {
        // TODO: implement handlePasscodeAuthenticationError
    }
}
