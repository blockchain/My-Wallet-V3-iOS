//
//  WalletManager.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import JavaScriptCore

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
    weak var pinEntryDelegate: WalletPinEntryDelegate?
    weak var buySellDelegate: WalletBuySellDelegate?

    init(wallet: Wallet = Wallet()!) {
        self.wallet = wallet
        super.init()
        self.wallet.delegate = self
    }

    /// Performs closing operations on the wallet. This should be called on logout and
    /// when the app is backgrounded
    func close() {
        latestMultiAddressResponse = nil
        closeWebSockets(withCloseCode: .loggedOut)

        wallet.resetSyncStatus()
        wallet.loadBlankWallet()
        wallet.hasLoadedAccountInfo = false

        beginBackgroundUpdateTask()
    }

    /// Closes all wallet websockets with the provided WebSocketCloseCode
    ///
    /// - Parameter closeCode: the WebSocketCloseCode
    @objc func closeWebSockets(withCloseCode closeCode: WebSocketCloseCode) {
        [wallet.ethSocket, wallet.bchSocket, wallet.btcSocket].forEach {
            $0?.close(withCode: closeCode.rawValue, reason: closeCode.reason)
        }
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

    private var backgroundUpdateTaskIdentifer: UIBackgroundTaskIdentifier?

    private func beginBackgroundUpdateTask() {
        // We're using a background task to ensure we get enough time to sync. The bg task has to be ended before or when the timer expires,
        // otherwise the app gets killed by the system. Always kill the old handler before starting a new one. In case the system starts a bg
        // task when the app goes into background, comes to foreground and goes to background before the first background task was ended.
        // In that case the first background task is never killed and the system kills the app when the maximum time is up.
        endBackgroundUpdateTask()

        backgroundUpdateTaskIdentifer = UIApplication.shared.beginBackgroundTask { [unowned self] in
            self.endBackgroundUpdateTask()
        }
    }

    private func endBackgroundUpdateTask() {
        guard let backgroundUpdateTaskIdentifer = backgroundUpdateTaskIdentifer else { return }
        UIApplication.shared.endBackgroundTask(backgroundUpdateTaskIdentifer)
    }
}

extension WalletManager: WalletDelegate {

    // MARK: - Auth

    func walletDidLoad() {
        print("walletDidLoad()")
        endBackgroundUpdateTask()
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
        print("walletFailedToDecrypt()")
        authDelegate?.authenticationError(error:
            AuthenticationError(code: AuthenticationError.ErrorCode.errorDecryptingWallet.rawValue)
        )
    }

    func walletFailedToLoad() {
        print("walletFailedToLoad()")
        authDelegate?.authenticationError(error: AuthenticationError(
            code: AuthenticationError.ErrorCode.failedToLoadWallet.rawValue
        ))
    }

    func walletDidRequireEmailAuthorization(_ wallet: Wallet!) {
        authDelegate?.emailAuthorizationRequired()
    }

    func wallet(_ wallet: Wallet!, didRequireTwoFactorAuthentication type: Int) {
        guard let twoFactorType = AuthenticationTwoFactorType(rawValue: type) else {
            authDelegate?.authenticationError(error: AuthenticationError(
                code: AuthenticationError.ErrorCode.invalidTwoFactorType.rawValue,
                description: LocalizationConstants.Authentication.invalidTwoFactorAuthenticationType
            ))
            return
        }
        authDelegate?.didRequireTwoFactorAuth(withType: twoFactorType)
    }

    func walletDidResendTwoFactorSMS(_ wallet: Wallet!) {
        authDelegate?.didResendTwoFactorSMSCode()
    }

    // MARK: - Buy/Sell

    func initializeWebView() {
        buySellDelegate?.initializeWebView()
    }

    // MARK: - Pin Entry

    func didFailGetPinTimeout() {
        pinEntryDelegate?.errorGetPinValueTimeout()
    }

    func didFailGetPinNoResponse() {
        pinEntryDelegate?.errorGetPinEmptyResponse()
    }

    func didFailGetPinInvalidResponse() {
        pinEntryDelegate?.errorGetPinInvalidResponse()
    }

    func didFailPutPin(_ value: String!) {
        pinEntryDelegate?.errorDidFailPutPin(errorMessage: value)
    }

    func didPutPinSuccess(_ dictionary: [AnyHashable : Any]!) {
        let response = PutPinResponse(response: dictionary)
        pinEntryDelegate?.putPinSuccess(response: response)
    }

    func didGetPinResponse(_ dictionary: [AnyHashable : Any]!) {
        let response = GetPinResponse(response: dictionary)
        pinEntryDelegate?.getPinSuccess(response: response)
    }
}
