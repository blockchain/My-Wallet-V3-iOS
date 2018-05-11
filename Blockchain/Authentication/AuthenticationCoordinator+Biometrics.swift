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
        AuthenticationManager.shared.authenticateUsingBiometrics { authenticated, _, authenticationError in
            self.isPromptingForBiometricAuthentication = false

            if let error = authenticationError {
                self.handleBiometricAuthenticationError(with: error)
            }

            self.pinEntryViewController?.view.isUserInteractionEnabled = true

            guard authenticated else { return }

            self.showVerifyingBusyView(withTimeout: 30)

            guard let pinKey = BlockchainSettings.App.shared.pinKey,
                let pin = KeychainItemWrapper.pinFromKeychain() else {
                    AlertViewPresenter.shared.showKeychainReadError()
                    return
            }

            // Check for maintenance before allowing authentication.
            NetworkManager.shared.checkForMaintenance(withCompletion: { response in
                LoadingViewPresenter.shared.hideBusyView()
                guard response == nil else {
                    print("Error checking for maintenance in wallet options: %@", response!)
                    AlertViewPresenter.shared.standardNotify(message: response!, title: LocalizationConstants.Errors.error, handler: nil)
                    return
                }
                WalletManager.shared.wallet.apiGetPINValue(pinKey, pin: pin)
            })
        }
    }

    private func handleBiometricAuthenticationError(with error: AuthenticationError) {
        if let description = error.description {
            AlertViewPresenter.shared.standardNotify(message: description, title: LocalizationConstants.Errors.error, handler: nil)
        }
    }
}
