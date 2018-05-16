//
//  WalletManager+KeyImporter.swift
//  Blockchain
//
//  Created by Maurice A. on 5/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension WalletManager {

    enum KeyImportError: String {
        case presentInWallet
        case needsBip38
        case wrongBipPass
    }

    enum AddressImportError: String {
        case addressNotPresentInWallet
        case addressNotWatchOnly
        case privateKeyOfAnotherNonWatchOnlyAddress
    }

    // TODO: Refactor class to support other asset types (currently assumed to be Bitcoin)
    @objc class KeyImporter: NSObject & PrivateKeyReaderDelegate {

        // MARK: - Properties

        /// The instance variable used to access functions of the `KeyImporter` class.
        static let shared = KeyImporter()

        /// Observer key for notifications used throughout this class
        private let backupKey = Constants.NotificationKeys.backupSuccess

        /// Weak reference to wallet object
        weak var wallet: Wallet!

        //: Prevent outside objects from creating their own instances of this class.
        private override init() {
            super.init()
            wallet = WalletManager.shared.wallet
        }

        // MARK: - Temporary Objective-C bridging methods for backwards compatibility

        @objc class func sharedInstance() -> KeyImporter {
            return KeyImporter.shared
        }

        @objc func on_add_private_key_start() {
            wallet.isSyncing = true
            LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.AddressAndKeyImport.loadingImportKey)
        }

        @objc func on_add_key(address: String) {
            guard let importedAddress = BitcoinAddress(string: address) else { return }
            wallet.isSyncing = true
            wallet.shouldLoadMetadata = true
            importKey(from: importedAddress)
        }

        // TODO: unused parameter - confirm whether address param will be used in the future
        @objc func on_add_incorrect_private_key(address: String) {
            wallet.isSyncing = true
            didImportIncorrectPrivateKey()
        }

        @objc func on_add_private_key_to_legacy_address(address: String) {
            wallet.isSyncing = true
            wallet.shouldLoadMetadata = true
            // TODO: change assetType parameter to `address.assetType` once it is directly called from Swift
            wallet.subscribe(toAddress: address, assetType: .bitcoin)
            importedPrivateKeyToLegacyAddress()
        }

        @objc func on_error_adding_private_key(error: String) {
            failedToImportPrivateKey(errorDescription: error)
        }

        @objc func on_error_adding_private_key_watch_only(error: String) {
            failedToImportPrivateKeyForWatchOnlyAddress(errorDescription: error)
        }

        @objc func wrongBip38Password() -> String {
            return KeyImportError.wrongBipPass.rawValue
        }

        // MARK: - Key Importing

        func importKey(from address: AssetAddress) {
            if wallet.isWatchOnlyLegacyAddress(address.description) {
                // TODO: change assetType parameter to `address.assetType` once it is directly called from Swift
                wallet.subscribe(toAddress: address.description, assetType: .bitcoin)
            }

            LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.syncingWallet)
            wallet.lastImportedAddress = address.description

            NotificationCenter.default.addObserver(self, selector: #selector(alertUserOfImportedKey), name: backupKey, object: nil)
        }

        @objc func didImportIncorrectPrivateKey() {
            LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.syncingWallet)
            NotificationCenter.default.addObserver(self, selector: #selector(alertUserOfImportedIncorrectPrivateKey), name: backupKey, object: nil)
        }

        func failedToImportPrivateKey(errorDescription: String) {
            NotificationCenter.default.removeObserver(self, name: backupKey, object: nil)
            LoadingViewPresenter.shared.hideBusyView()
            wallet.isSyncing = false

            // TODO: improve JS error handling to avoid string comparison
            var error = LocalizationConstants.AddressAndKeyImport.unknownErrorPrivateKey
            if errorDescription.contains(KeyImportError.presentInWallet.rawValue) {
                error = LocalizationConstants.AddressAndKeyImport.keyAlreadyImported
            } else if errorDescription.contains(KeyImportError.needsBip38.rawValue) {
                error = LocalizationConstants.AddressAndKeyImport.keyNeedsBip38Password
            } else if errorDescription.contains(KeyImportError.wrongBipPass.rawValue) {
                error = LocalizationConstants.AddressAndKeyImport.incorrectBip38Password
            }

            AlertViewPresenter.shared.standardNotify(message: error, title: LocalizationConstants.Errors.error, handler: nil)
        }

        func failedToImportPrivateKeyForWatchOnlyAddress(errorDescription: String) {
            LoadingViewPresenter.shared.hideBusyView()
            wallet.isSyncing = false

            // TODO: improve JS error handling to avoid string comparisons
            var error = LocalizationConstants.AddressAndKeyImport.unknownErrorPrivateKey
            if errorDescription.contains(AddressImportError.addressNotPresentInWallet.rawValue) {
                error = LocalizationConstants.AddressAndKeyImport.addressNotPresentInWallet
            } else if errorDescription.contains(AddressImportError.addressNotWatchOnly.rawValue) {
                error = LocalizationConstants.AddressAndKeyImport.addressNotWatchOnly
            } else if errorDescription.contains(AddressImportError.privateKeyOfAnotherNonWatchOnlyAddress.rawValue) {
                error = LocalizationConstants.AddressAndKeyImport.keyBelongsToOtherAddressNotWatchOnly
            }

            let cancelAction = UIAlertAction(title: LocalizationConstants.cancel, style: .cancel, handler: nil)
            let tryAgainAction = UIAlertAction(title: LocalizationConstants.tryAgain, style: .default) { [unowned self] _ in
                guard let address = BitcoinAddress(string: self.wallet.lastScannedWatchOnlyAddress) else { return }
                self.scanPrivateKeyForWatchOnlyAddress(address)
            }

            let title = LocalizationConstants.Errors.error
            AlertViewPresenter.shared.standardNotify(message: error, title: title, actions: [cancelAction, tryAgainAction])
        }

        func importedPrivateKeyToLegacyAddress() {
            LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.syncingWallet)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(alertUserOfImportedPrivateKeyIntoLegacyAddress),
                                                   name: backupKey,
                                                   object: nil)
        }

        func scanPrivateKeyForWatchOnlyAddress(_ address: AssetAddress) {
            if !Reachability.hasInternetConnection() {
                AlertViewPresenter.shared.showNoInternetConnectionAlert()
                return
            }

            do {
                _ = try AVCaptureDeviceInput.deviceInputForQRScanner()
            } catch {
                AlertViewPresenter.shared.standardError(message: error.localizedDescription)
                return
            }

            let reader = PrivateKeyReader()
            reader.delegate = self
            reader.startReadingQRCode(for: address)

            // TODO: `lastScannedWatchOnlyAddress` needs to be of type AssetAddress, not String
            wallet.lastScannedWatchOnlyAddress = address.description
        }

        func askUserToAddWatchOnlyAddress(_ address: AssetAddress, continueHandler: @escaping () -> Void) {
            let firstLine = LocalizationConstants.AddressAndKeyImport.addWatchOnlyAddressWarning
            let secondLine = LocalizationConstants.AddressAndKeyImport.addWatchOnlyAddressWarningPrompt
            let message = String(format: "%@\n\n%@", firstLine, secondLine)
            let title = LocalizationConstants.Errors.warning
            let continueAction = UIAlertAction(title: LocalizationConstants.continueString, style: .default) { _ in
                continueHandler()
            }
            let cancelAction = UIAlertAction(title: LocalizationConstants.cancel, style: .cancel, handler: nil)
            AlertViewPresenter.shared.standardNotify(message: message, title: title, actions: [continueAction, cancelAction])
        }

        // MARK: - Private Methods

        @objc private func alertUserOfImportedKey() {
            NotificationCenter.default.removeObserver(self, name: backupKey, object: nil)
            let isWatchOnly = wallet.isWatchOnlyLegacyAddress(wallet.lastImportedAddress)
            let importedAddressArgument = LocalizationConstants.AddressAndKeyImport.importedWatchOnlyAddressArgument
            let importedPrivateKeyArgument = LocalizationConstants.AddressAndKeyImport.importedPrivateKeyArgument
            let format = isWatchOnly ? importedAddressArgument : importedPrivateKeyArgument
            let message = String(format: format, wallet.lastImportedAddress)
            AlertViewPresenter.shared.standardNotify(message: message, title: LocalizationConstants.okString, handler: nil)
        }

        @objc private func alertUserOfImportedIncorrectPrivateKey() {
            NotificationCenter.default.removeObserver(self, name: backupKey, object: nil)
            let importedKeyButForIncorrectAddress = LocalizationConstants.AddressAndKeyImport.importedKeyButForIncorrectAddress
            let importedKeyDoesNotCorrespondToAddress = LocalizationConstants.AddressAndKeyImport.importedKeyDoesNotCorrespondToAddress
            let message = String(format: "%@\n\n%@", importedKeyButForIncorrectAddress, importedKeyDoesNotCorrespondToAddress)
            AlertViewPresenter.shared.standardNotify(message: message, title: LocalizationConstants.okString, handler: nil)
        }

        @objc private func alertUserOfImportedPrivateKeyIntoLegacyAddress() {
            NotificationCenter.default.removeObserver(self, name: backupKey, object: nil)
            let importedKeySuccess = LocalizationConstants.AddressAndKeyImport.importedKeySuccess
            AlertViewPresenter.shared.standardNotify(message: importedKeySuccess, title: LocalizationConstants.success, handler: nil)
        }

        // MARK: - PrivateKeyReader Delegate

        func didFinishScanningWithError(_ error: AVCaptureDeviceError) {
            // TODO: implement error handling
        }

        func didFinishScanning(_ privateKey: String, for address: AssetAddress) {
            wallet.addKey(privateKey, toWatchOnlyAddress: address.description)
        }
    }
}
