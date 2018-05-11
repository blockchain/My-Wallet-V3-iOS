//
//  AuthenticationCoordinator+Biometrics.swift
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
        AuthenticationManager.shared.authenticateUsingBiometrics { [weak self] authenticated, authenticationError in
            guard let strongSelf = self else { return }

            strongSelf.isPromptingForBiometricAuthentication = false

            if let error = authenticationError {
                strongSelf.handleBiometricAuthenticationError(with: error)
            }

            strongSelf.pinEntryViewController?.view.isUserInteractionEnabled = true

            guard authenticated else { return }

            strongSelf.showVerifyingBusyView(withTimeout: 30)

            guard let pinKey = BlockchainSettings.App.shared.pinKey,
                let pin = KeychainItemWrapper.pinFromKeychain() else {
                    AlertViewPresenter.shared.showKeychainReadError()
                    return
            }

            let payload = PinPayload(pinCode: pin, pinKey: pinKey)
            AuthenticationManager.shared.authenticate(using: payload, andReply: strongSelf.authHandler)
        }
    }

    private func handleBiometricAuthenticationError(with error: AuthenticationError) {
        if let description = error.description {
            AlertViewPresenter.shared.standardNotify(message: description, title: LocalizationConstants.Errors.error, handler: nil)
        }
    }
}
