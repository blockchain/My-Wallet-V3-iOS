//
//  AlertViewPresenter+Wallet.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Extension for wallet-related alerts
extension AlertViewPresenter {

    @objc func showEmailAuthorizationRequired() {
        let alert = UIAlertController(
            title: LocalizationConstants.Authentication.manualPairingAuthorizationRequiredTitle,
            message: LocalizationConstants.Authentication.manualPairingAuthorizationRequiredMessage,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.okString, style: .cancel)
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.openMailApp, style: .default) { _ in
                UIApplication.shared.openMailApplication()
            }
        )
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            alert,
            animated: true
        )
    }

    /// Displays an alert to the user if the wallet object contains a value from `Wallet.getMobileMessage`.
    /// Otherwise, if there is no value, no such alert will be presented.
    @objc func showMobileNoticeIfNeeded() {
        guard let message = WalletManager.shared.wallet.getMobileMessage(), message.count > 0 else {
            return
        }

        standardNotify(message: message, title: LocalizationConstants.information)
    }
}
