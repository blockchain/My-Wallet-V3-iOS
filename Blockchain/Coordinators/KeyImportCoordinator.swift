//
//  KeyImportCoordinator.swift
//  Blockchain
//
//  Created by Maurice A. on 5/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// TODO: Refactor class to support other asset types (currently assumed to be Bitcoin)
@objc class KeyImportCoordinator: NSObject, Coordinator {

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

    //: Nil if device input is unavailable
    private var privateKeyReader: PrivateKeyReader?

    /// Observer key for notifications used throughout this class
    private let backupKey = Constants.NotificationKeys.backupSuccess

    private let walletManager: WalletManager

    static let shared = KeyImportCoordinator()

    @objc class func sharedInstance() -> KeyImportCoordinator {
        return KeyImportCoordinator.shared
    }

    // TODO: Refactor class to support other asset types (currently assumed to be Bitcoin)
    private init(walletManager: WalletManager = WalletManager.shared) {
        self.walletManager = walletManager
        super.init()
        initialize()
    }

    @objc func initialize() {
        self.walletManager.keyImportDelegate = self
    }

    func start() { /* Tasks which do not require scanning should call this */ }

    func start(with delegate: PrivateKeyReaderDelegate,
               in viewController: UIViewController,
               assetType: AssetType = .bitcoin,
               acceptPublicKeys: Bool = false,
               loadingText: String = LocalizationConstants.AddressAndKeyImport.loadingImportKey,
               assetAddress: AssetAddress? = nil) {
        privateKeyReader = PrivateKeyReader(assetType: assetType, acceptPublicKeys: acceptPublicKeys, assetAddress: assetAddress)
        guard privateKeyReader != nil else { return }
        privateKeyReader!.delegate = delegate
        privateKeyReader!.startReadingQRCode()
        viewController.present(privateKeyReader!, animated: true, completion: nil)
    }

    @objc func start(with delegate: LegacyPrivateKeyDelegate,
                     in viewController: UIViewController,
                     assetType: LegacyAssetType = .bitcoin,
                     acceptPublicKeys: Bool = false,
                     loadingText: String = LocalizationConstants.AddressAndKeyImport.loadingImportKey,
                     assetAddress: AssetAddress? = nil) {
        privateKeyReader = PrivateKeyReader(assetType: assetType, acceptPublicKeys: acceptPublicKeys, assetAddress: assetAddress)
        guard privateKeyReader != nil else { return }
        privateKeyReader!.legacyDelegate = delegate
        privateKeyReader!.startReadingQRCode()
        viewController.present(privateKeyReader!, animated: true, completion: nil)
    }

    // MARK: - Temporary Objective-C bridging methods for backwards compatibility

    @objc func on_add_private_key_start() {
        walletManager.wallet.isSyncing = true
        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.AddressAndKeyImport.loadingImportKey)
    }

    @objc func on_add_key(address: String) {
        let importedAddress = BitcoinAddress(string: address)
        let validator = AddressValidator(context: WalletManager.shared.wallet.context)
        guard validator.validate(bitcoinAddress: importedAddress) else { return }
        walletManager.wallet.isSyncing = true
        walletManager.wallet.shouldLoadMetadata = true
        importKey(from: importedAddress)
    }

    // TODO: unused parameter - confirm whether address param will be used in the future
    @objc func on_add_incorrect_private_key(address: String) {
        walletManager.wallet.isSyncing = true
        didImportIncorrectPrivateKey()
    }

    @objc func on_add_private_key_to_legacy_address(address: String) {
        walletManager.wallet.isSyncing = true
        walletManager.wallet.shouldLoadMetadata = true
        // TODO: change assetType parameter to `address.assetType` once it is directly called from Swift
        walletManager.wallet.subscribe(toAddress: address, assetType: .bitcoin)
        importedPrivateKeyToLegacyAddress()
    }

    @objc func on_error_adding_private_key(error: String) {
        failedToImportPrivateKey(errorDescription: error)
    }

    @objc func on_error_adding_private_key_watch_only(error: String) {
        failedToImportPrivateKeyForWatchOnlyAddress(errorDescription: error)
    }

    @objc func on_error_import_key_for_sending_from_watch_only(error: String) {
        failedToImportPrivateKeyForSendingFromWatchOnlyAddress(errorDescription: error)
    }
}

// MARK: - WalletKeyImportDelegate

extension KeyImportCoordinator: WalletKeyImportDelegate {
    func alertUserOfInvalidPrivateKey() {
        AlertViewPresenter.shared.standardError(message: LocalizationConstants.AddressAndKeyImport.incorrectPrivateKey)
    }

    @objc func alertUserOfImportedIncorrectPrivateKey() {
        NotificationCenter.default.removeObserver(self, name: backupKey, object: nil)
        let importedKeyButForIncorrectAddress = LocalizationConstants.AddressAndKeyImport.importedKeyButForIncorrectAddress
        let importedKeyDoesNotCorrespondToAddress = LocalizationConstants.AddressAndKeyImport.importedKeyDoesNotCorrespondToAddress
        let message = String(format: "%@\n\n%@", importedKeyButForIncorrectAddress, importedKeyDoesNotCorrespondToAddress)
        AlertViewPresenter.shared.standardNotify(message: message, title: LocalizationConstants.okString, handler: nil)
    }

    @objc func alertUserOfImportedKey() {
        NotificationCenter.default.removeObserver(self, name: backupKey, object: nil)
        let isWatchOnly = walletManager.wallet.isWatchOnlyLegacyAddress(walletManager.wallet.lastImportedAddress)
        let importedAddressArgument = LocalizationConstants.AddressAndKeyImport.importedWatchOnlyAddressArgument
        let importedPrivateKeyArgument = LocalizationConstants.AddressAndKeyImport.importedPrivateKeyArgument
        let format = isWatchOnly ? importedAddressArgument : importedPrivateKeyArgument
        let message = String(format: format, walletManager.wallet.lastImportedAddress)
        AlertViewPresenter.shared.standardNotify(message: message, title: LocalizationConstants.success, handler: nil)
    }

    @objc func alertUserOfImportedPrivateKeyIntoLegacyAddress() {
        NotificationCenter.default.removeObserver(self, name: backupKey, object: nil)
        let importedKeySuccess = LocalizationConstants.AddressAndKeyImport.importedKeySuccess
        AlertViewPresenter.shared.standardNotify(message: importedKeySuccess, title: LocalizationConstants.success, handler: nil)
    }

    func askUserToAddWatchOnlyAddress(_ address: AssetAddress, then: @escaping () -> Void) {
        let firstLine = LocalizationConstants.AddressAndKeyImport.addWatchOnlyAddressWarning
        let secondLine = LocalizationConstants.AddressAndKeyImport.addWatchOnlyAddressWarningPrompt
        let message = String(format: "%@\n\n%@", firstLine, secondLine)
        let title = LocalizationConstants.Errors.warning
        let continueAction = UIAlertAction(title: LocalizationConstants.continueString, style: .default) { _ in
            then()
        }
        let cancelAction = UIAlertAction(title: LocalizationConstants.cancel, style: .cancel, handler: nil)
        AlertViewPresenter.shared.standardNotify(message: message, title: title, actions: [continueAction, cancelAction])
    }

    func didImportIncorrectPrivateKey() {
        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.syncingWallet)
        NotificationCenter.default.addObserver(self, selector: #selector(alertUserOfImportedIncorrectPrivateKey), name: backupKey, object: nil)
    }

    func failedToImportPrivateKey(errorDescription: String) {
        NotificationCenter.default.removeObserver(self, name: backupKey, object: nil)
        LoadingViewPresenter.shared.hideBusyView()
        walletManager.wallet.isSyncing = false

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

    func failedToImportPrivateKeyForSendingFromWatchOnlyAddress(errorDescription: String) {
        walletManager.wallet.loading_stop()
        if errorDescription == Constants.JSErrors.AddressAndKeyImport.wrongPrivateKey {
            alertUserOfInvalidPrivateKey()
        } else if errorDescription == Constants.JSErrors.AddressAndKeyImport.wrongBipPass {
            AlertViewPresenter.shared.standardError(message: LocalizationConstants.AddressAndKeyImport.incorrectBip38Password)
        } else {
            // TODO: improve copy for all other errors
            AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.error)
        }
    }

    func failedToImportPrivateKeyForWatchOnlyAddress(errorDescription: String) {
        LoadingViewPresenter.shared.hideBusyView()
        walletManager.wallet.isSyncing = false

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
            let address = BitcoinAddress(string: self.walletManager.wallet.lastScannedWatchOnlyAddress)
            let validator = AddressValidator(context: WalletManager.shared.wallet.context)
            guard validator.validate(bitcoinAddress: address) else { return }
            self.scanPrivateKeyForWatchOnlyAddress(address)
        }

        let title = LocalizationConstants.Errors.error
        AlertViewPresenter.shared.standardNotify(message: error, title: title, actions: [cancelAction, tryAgainAction])
    }

    func importKey(from address: AssetAddress) {
        if walletManager.wallet.isWatchOnlyLegacyAddress(address.description) {
            // TODO: change assetType parameter to `address.assetType` once it is directly called from Swift
            walletManager.wallet.subscribe(toAddress: address.description, assetType: .bitcoin)
        }

        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.syncingWallet)
        walletManager.wallet.lastImportedAddress = address.description

        NotificationCenter.default.addObserver(self, selector: #selector(alertUserOfImportedKey), name: backupKey, object: nil)
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

        guard let topVC = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController else {
            fatalError("topMostViewController is nil")
        }
        start(with: self, in: topVC, assetAddress: address)

        // TODO: `lastScannedWatchOnlyAddress` needs to be of type AssetAddress, not String
        walletManager.wallet.lastScannedWatchOnlyAddress = address.address
    }
}

// MARK: - PrivateKeyReaderDelegate

extension KeyImportCoordinator: PrivateKeyReaderDelegate {
    func didFinishScanning(_ privateKey: String, for address: AssetAddress?) {
        walletManager.wallet.addKey(privateKey, toWatchOnlyAddress: address?.address)
    }

    func didFinishScanningWithError(_ error: PrivateKeyReaderError) {
        switch error {
        case .badMetadataObject:
            AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.error)
        case .unknownKeyFormat:
            AlertViewPresenter.shared.standardError(message: LocalizationConstants.AddressAndKeyImport.unknownKeyFormat)
        case .unsupportedPrivateKey:
            AlertViewPresenter.shared.standardError(message: LocalizationConstants.AddressAndKeyImport.unsupportedPrivateKey)
        }
    }
}
