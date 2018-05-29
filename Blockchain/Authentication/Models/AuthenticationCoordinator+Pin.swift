//
//  AuthenticationCoordinator+Pin.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension AuthenticationCoordinator: PEPinEntryControllerDelegate {

    /// Coordinates the change pin flow.
    @objc func changePin() {
        let pinChangeController = PEPinEntryController.pinChange()!
        pinChangeController.pinDelegate = self
        pinChangeController.isNavigationBarHidden = true

        let peViewController = pinChangeController.viewControllers[0] as! PEViewController
        peViewController.cancelButton.isHidden = false
        peViewController.cancelButton.addTarget(self, action: #selector(onPinCloseButtonTapped), for: .touchUpInside)
        peViewController.modalTransitionStyle = .coverVertical

        self.pinEntryViewController = pinChangeController

        AppCoordinator.shared.tabControllerManager.tabViewController.dismiss(animated: true)

        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(pinChangeController.view)
        UIApplication.shared.statusBarStyle = .default
    }

    /// Coordinates the pin validation flow. Primarily used to validate the user's PIN code
    /// when enabling touch ID.
    @objc func validatePin() {
        let pinController = PEPinEntryController.pinVerifyControllerClosable()!
        pinController.pinDelegate = self
        pinController.isNavigationBarHidden = true

        let peViewController = pinController.viewControllers[0] as! PEViewController
        peViewController.cancelButton.isHidden = false
        peViewController.cancelButton.addTarget(self, action: #selector(onPinCloseButtonTapped), for: .touchUpInside)
        peViewController.modalTransitionStyle = .coverVertical

        self.pinEntryViewController = pinController

        AppCoordinator.shared.tabControllerManager.tabViewController.dismiss(animated: true)

        if WalletManager.shared.wallet.isSyncing {
            LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.syncingWallet)
        }

        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(pinController.view)
        UIApplication.shared.statusBarStyle = .default
    }

    @objc func onPinCloseButtonTapped() {
        AppCoordinator.shared.showSettingsView()
    }

    // MARK: - PEPinEntryControllerDelegate

    func pinEntryController(
        _ pinEntryController: PEPinEntryController!,
        shouldAcceptPin pinInt: UInt,
        callback: ((Bool) -> Void)!
        ) {
        let pin = Pin(code: pinInt)
        self.lastEnteredPIN = pin

        // Check if we have an internet connection
        // This only checks if a network interface is up. All other errors (including timeouts)
        // are handled by JavaScript callbacks in Wallet.m
        guard Reachability.hasInternetConnection() else {
            AlertViewPresenter.shared.showNoInternetConnectionAlert()
            return
        }

        showVerifyingBusyView(withTimeout: 30)

        if let config = AppFeatureConfigurator.shared.configuration(for: .touchId),
            config.isEnabled,
            pinEntryController.verifyOptional {
            pin.saveToKeychain()
        }

        guard let pinKey = BlockchainSettings.App.shared.pinKey else {
            return
        }

        let payload = PinPayload(pinCode: pin.toString, pinKey: pinKey)
        AuthenticationManager.shared.authenticate(using: payload, andReply: authHandler)

        self.pinViewControllerCallback = callback
    }

    func pinEntryController(_ pinEntryController: PEPinEntryController!, changedPin pinInt: UInt) {
        let pin = Pin(code: pinInt)
        self.lastEnteredPIN = pin

        guard WalletManager.shared.wallet.isInitialized() || WalletManager.shared.wallet.password != nil else {
            errorDidFailPutPin(errorMessage: LocalizationConstants.Pin.cannotSaveInvalidWalletState)
            return
        }

        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.verifying)

        try? pin.save()
    }

    func pinEntryController(_ pinEntryController: PEPinEntryController!, willChangeToNewPin pinInt: UInt) {
        let pin = Pin(code: pinInt)

        // Check that the selected pin passes checks

        guard pin.isValid else {
            AlertViewPresenter.shared.standardNotify(
                message: LocalizationConstants.Authentication.chooseAnotherPin,
                title: LocalizationConstants.Errors.error
            ) { [unowned self] _ in
                self.reopenChangePin()
            }
            return
        }

        guard pin != self.lastEnteredPIN else {
            AlertViewPresenter.shared.standardNotify(
                message: LocalizationConstants.Authentication.newPinMustBeDifferent,
                title: LocalizationConstants.Errors.error
            ) { [unowned self] _ in
                self.reopenChangePin()
            }
            return
        }

        guard !pin.isCommon else {
            let alert = UIAlertController(
                title: LocalizationConstants.Errors.warning,
                message: LocalizationConstants.Authentication.pinCodeCommonMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: LocalizationConstants.continueString, style: .default))
            alert.addAction(
                UIAlertAction(title: LocalizationConstants.tryAgain, style: .cancel) {  [unowned self] _ in
                    self.reopenChangePin()
                }
            )
            pinEntryController.present(alert, animated: true)
            return
        }
    }

    func pinEntryControllerDidCancel(_ pinEntryController: PEPinEntryController!) {
        print("Pin change cancelled!")
        closePinEntryView(animated: true)
    }

    // MARK: - Internal

    internal func showVerifyingBusyView(withTimeout seconds: Int) {
        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.verifying)

        // TODO: this timeout approach should be deprecated in favor of checking actual success/error responses
        if #available(iOS 10.0, *) {
            loginTimeout = Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds), repeats: false) { [weak self] _ in
                self?.showLoginError()
            }
        } else {
            loginTimeout = Timer.scheduledTimer(
                timeInterval: TimeInterval(seconds),
                target: self,
                selector: #selector(showLoginError),
                userInfo: nil,
                repeats: false
            )
        }
    }

    // MARK: - Private

    private func reopenChangePin() {
        closePinEntryView(animated: false)

        guard let pinViewController = PEPinEntryController.pinCreate() else {
            return
        }

        pinViewController.isNavigationBarHidden = true
        pinViewController.pinDelegate = self

        if BlockchainSettings.App.shared.isPinSet {
            pinViewController.inSettings = true
        }

        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(pinViewController.view)

        pinEntryViewController = pinViewController
    }
}

extension AuthenticationCoordinator: WalletPinEntryDelegate {

    func errorGetPinValueTimeout() {
        showPinError(withMessage: LocalizationConstants.Errors.timedOut)
    }

    func errorGetPinEmptyResponse() {
        showPinError(withMessage: LocalizationConstants.Pin.incorrect)
    }

    func errorGetPinInvalidResponse() {
        showPinError(withMessage: LocalizationConstants.Errors.invalidServerResponse)
    }

    func errorDidFailPutPin(errorMessage: String) {
        LoadingViewPresenter.shared.hideBusyView()

        AlertViewPresenter.shared.standardError(message: errorMessage)

        reopenChangePin()
    }

    func putPinSuccess(response: PutPinResponse) {
        LoadingViewPresenter.shared.hideBusyView()

        guard let password = walletManager.wallet.password else {
            errorDidFailPutPin(errorMessage: LocalizationConstants.Pin.cannotSaveInvalidWalletState)
            return
        }

        walletManager.wallet.isNew = false

        guard response.error == nil else {
            errorDidFailPutPin(errorMessage: response.error!)
            return
        }

        guard response.isStatusCodeOk else {
            let message = String(
                format: LocalizationConstants.Errors.invalidStatusCodeReturned,
                response.code ?? -1
            )
            errorDidFailPutPin(errorMessage: message)
            return
        }

        guard response.key.count != 0 && response.value.count != 0 else {
            errorDidFailPutPin(errorMessage: LocalizationConstants.Pin.responseKeyOrValueLengthZero)
            return
        }

        let inSettings = pinEntryViewController?.inSettings ?? false
        if inSettings {
            AppCoordinator.shared.showSettingsView()
        }

        // Encrypt the wallet password with the random value
        guard let encryptedPinPassword = walletManager.wallet.encrypt(
            password,
            password: response.value,
            pbkdf2_iterations: Int32(Constants.Security.pinPBKDF2Iterations)
        ) else {
            errorDidFailPutPin(errorMessage: LocalizationConstants.Pin.encryptedStringIsNil)
            return
        }

        let appSettings = BlockchainSettings.App.shared
        appSettings.encryptedPinPassword = encryptedPinPassword
        appSettings.pinKey = response.key
        appSettings.passwordPartHash = password.passwordPartHash

        // Update your info to new pin code
        closePinEntryView(animated: true)

        if walletManager.wallet.isInitialized() && !inSettings {
            AlertViewPresenter.shared.showMobileNoticeIfNeeded()
        }

        AppCoordinator.shared.showHdUpgradeViewIfNeeded()
    }

    func getPinSuccess(response: GetPinResponse) {

        var pinSuccess = false

        // Incorrect pin
        if response.code == nil {
            showPinError(withMessage: LocalizationConstants.Pin.incorrect)
        } else if response.code == GetPinResponse.StatusCode.deleted.rawValue {
            // Pin retry limit exceeded
            BlockchainSettings.App.shared.clearPin()
            logout(showPasswordView: false)
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.showPasswordModal()
                strongSelf.closePinEntryView(animated: true)
                strongSelf.showPinError(withMessage: LocalizationConstants.Pin.validationCannotBeCompleted)
            }
        } else if response.code == GetPinResponse.StatusCode.incorrect.rawValue {
            let error = response.error ?? LocalizationConstants.Pin.incorrectUnknownError
            showPinError(withMessage: error)
        } else if response.code == GetPinResponse.StatusCode.success.rawValue {

            // Handle touch ID
            if let config = AppFeatureConfigurator.shared.configuration(for: .touchId), config.isEnabled,
                pinEntryViewController?.verifyOptional ?? false {
                LoadingViewPresenter.shared.hideBusyView()
                BlockchainSettings.App.shared.touchIDEnabled = true
                closePinEntryView(animated: true)
                AppCoordinator.shared.showSettingsView()
                return
            }

            // This is for change PIN - verify the password first, then show the enter screens
            if !(pinEntryViewController?.verifyOnly ?? false) {
                pinViewControllerCallback?(true)
                pinViewControllerCallback = nil
                return
            }

            // Initial PIN setup ?
            if response.pinDecryptionValue?.count == 0 {
                showPinError(withMessage: LocalizationConstants.Pin.responseSuccessLengthZero)
                return
            }

            let encryptedPinPassword = BlockchainSettings.App.shared.encryptedPinPassword!
            let decryptedPassword = walletManager.wallet.decrypt(
                encryptedPinPassword,
                password: response.pinDecryptionValue,
                pbkdf2_iterations: Int32(Constants.Security.pinPBKDF2Iterations)
            )

            if let decryptedPassword = decryptedPassword, decryptedPassword.count > 0 {
                tryToLoadWallet(password: decryptedPassword)
            } else {
                showPinError(withMessage: LocalizationConstants.Pin.decryptedPasswordLengthZero)
                askIfUserWantsToResetPIN()
                return
            }

            closePinEntryView(animated: true)
            pinSuccess = true
        } else {
            LoadingViewPresenter.shared.hideBusyView()
            askIfUserWantsToResetPIN()
        }

        pinViewControllerCallback?(pinSuccess)
        pinViewControllerCallback = nil

        // Remove pin from keychain if needed
        if !pinSuccess && pinEntryViewController?.verifyOptional ?? false {
            KeychainItemWrapper.removePinFromKeychain()
        }
    }

    private func tryToLoadWallet(password: String) {
        let appSettings = BlockchainSettings.App.shared
        if let guid = appSettings.guid,
            let sharedKey = appSettings.sharedKey {
            walletManager.wallet.load(withGuid: guid, sharedKey: sharedKey, password: password)
        } else {
            if appSettings.guid == nil {
                print("failed to retrieve GUID from Keychain")
            }
            if appSettings.sharedKey == nil {
                print("failed to retrieve sharedKey from Keychain")
            }
            if appSettings.guid != nil && appSettings.sharedKey == nil {
                print("!!! Failed to retrieve sharedKey from Keychain but was able to retreive GUID ???")
            }
            AlertViewPresenter.shared.showKeychainReadError()
        }
    }

    private func askIfUserWantsToResetPIN() {
        let alert = UIAlertController(
            title: LocalizationConstants.Pin.validationError,
            message: LocalizationConstants.Pin.validationErrorMessage,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.Authentication.enterPassword, style: .cancel) { [unowned self] _ in
                self.closePinEntryView(animated: true)
                self.showPasswordModal()
            }
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.Authentication.retryValidation, style: .default) { [unowned self] _ in
                self.pinEntryController(
                    self.pinEntryViewController!,
                    shouldAcceptPin: self.lastEnteredPIN!.pinCode,
                    callback: self.pinViewControllerCallback
                )
            }
        )
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(alert, animated: true)
    }

    private func showPinError(withMessage message: String) {
        LoadingViewPresenter.shared.hideBusyView()
        AlertViewPresenter.shared.standardNotify(message: message, title: LocalizationConstants.Errors.error) { [unowned self] _ in
            self.pinEntryViewController?.reset()
        }
    }
}
