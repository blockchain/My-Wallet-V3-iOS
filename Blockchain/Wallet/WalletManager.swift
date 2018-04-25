//
//  WalletManager.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

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

    private override init() {
        wallet = Wallet()!
        super.init()
        wallet.delegate = self
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

        if BlockchainSettings.App.shared.isPinSet {
            AppCoordinator.shared.showHdUpgradeViewIfNeeded()
        }

        didChangePassword = false

        // Verify valid GUID and sharedKey
        guard let guid = wallet.guid, guid.count == 36 else {
            AlertViewPresenter.shared.standardNotify(
                message: LocalizationConstants.Authentication.errorDecryptingWallet,
                title: LocalizationConstants.Errors.error) { _ in
                    UIApplication.shared.suspend()
            }
            return
        }

        guard let sharedKey = wallet.sharedKey, sharedKey.count == 36 else {
            AlertViewPresenter.shared.standardNotify(
                message: LocalizationConstants.Authentication.invalidSharedKey,
                title: LocalizationConstants.Errors.error
            )
            return
        }

        BlockchainSettings.App.shared.guid = guid
        BlockchainSettings.App.shared.sharedKey = sharedKey

        //Becuase we are not storing the password on the device. We record the first few letters of the hashed password.
        //With the hash prefix we can then figure out if the password changed
        guard let password = wallet.password,
            let passwordSha256 = NSString(string: password).sha256(),
            let passwordPartHash = BlockchainSettings.App.shared.passwordPartHash else {
            return
        }

        let endIndex = passwordSha256.index(passwordSha256.startIndex, offsetBy: min(password.count, 5))
        if passwordSha256[..<endIndex] != passwordPartHash {
            BlockchainSettings.App.shared.clearPin()
        }
    }

    func walletDidFinishLoad() {
        print("walletDidFinishLoad()")

        wallet.btcSwipeAddressToSubscribe = nil
        wallet.bchSwipeAddressToSubscribe = nil

        wallet.twoFactorInput = nil

        // TODO move this
        // [manualPairView clearTextFields];

        ModalPresenter.shared.closeAllModals()

        AuthenticationCoordinator.shared.start()

        // TODO move other methods from RootService to here
    }
}
