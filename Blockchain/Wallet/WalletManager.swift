//
//  WalletManager.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import JavaScriptCore


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
    func authenticationError()

    /// Callback invoked when the user has successfully authenticated
    func authenticationCompleted()
}

/**
 Manager object for operations to the Blockchain Wallet.
 */
@objc
class WalletManager: NSObject {
    static let shared = WalletManager()

    @objc class func sharedInstance() -> WalletManager {
        return shared
    }

    // TODO: Replace this with asset-specific wallet architecture
    @objc let wallet: Wallet

    // TODO: make this private(set) once other methods in RootService have been migrated in here
    @objc var latestMultiAddressResponse: MultiAddressResponse?

    @objc var didChangePassword: Bool = false

    weak var authDelegate: WalletAuthDelegate?

    init(wallet: Wallet = Wallet()!) {
        self.wallet = wallet
        super.init()
        self.wallet.delegate = self
    }

    @objc func forgetWallet() {
        BlockchainSettings.App.shared.clearPin()

        // Clear all cookies (important one is the server session id SID)
        HTTPCookieStorage.shared.deleteAllCookies()

        wallet.sessionToken = nil

        KeychainItemWrapper.removeAllSwipeAddresses()
        BlockchainSettings.App.shared.guid = nil
        BlockchainSettings.App.shared.sharedKey = nil

        wallet.loadBlankWallet()

        latestMultiAddressResponse = nil

        AppCoordinator.shared.tabControllerManager.forgetWallet()

        AppCoordinator.shared.reload()

        BlockchainSettings.App.shared.touchIDEnabled = false

        AppCoordinator.shared.tabControllerManager.transition(to: 1)

        wallet.setupBuySellWebview()
    }
}

extension WalletManager: WalletDelegate {
    func walletDidLoad() {
        print("walletDidLoad()")
    }

    func walletDidDecrypt() {
        print("walletDidDecrypt()")

        authDelegate?.didDecryptWallet(guid: wallet.guid, sharedKey: wallet.sharedKey, password: wallet.password)

        didChangePassword = false
    }

    func walletDidFinishLoad() {
        print("walletDidFinishLoad()")

        wallet.btcSwipeAddressToSubscribe = nil
        wallet.bchSwipeAddressToSubscribe = nil
        wallet.twoFactorInput = nil

        authDelegate?.authenticationCompleted()
    }

    func walletFailedToDecrypt() {
        // TODO: handle this once manual pairing is ported away from RootService
    }

    func walletFailedToLoad() {
        // TODO: handle this once manual pairing is ported away from RootService
    }
}
