//
//  WalletAuthDelegate.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for a delegate for authentication-related wallet callbacks
protocol WalletAuthDelegate: class {
    /// Callback invoked when the wallet successfully decrypts
    func didDecryptWallet(guid: String?, sharedKey: String?, password: String?)

    /// Callback invoked when 2 factor authorization is required
    func requiresTwoFactorCode()

    /// Callback invoked when the provided two factor code is incorrect
    func incorrectTwoFactorCode()

    /// Callback invoked when an email authorization is required (only for manual pairing)
    func emailAuthorizationRequired()

    /// Callback invoked when an error occurred with authenticating
    func authenticationError(error: AuthenticationError?)

    /// Callback invoked when the user has successfully authenticated
    func authenticationCompleted()
}
