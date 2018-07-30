//
//  PinInteractor.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/4/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// Interactor for the pin. This component interacts with the Blockchain API and the local
/// pin data store. When the pin is updated, the pin is also stored on the keychain.
@objc class PinInteractor: NSObject {

    static let shared = PinInteractor()

    @objc class func sharedInstance() -> PinInteractor { return shared }

    private let walletService: WalletService
    private let wallet: Wallet

    init(
        walletService: WalletService = WalletService.shared,
        wallet: Wallet = WalletManager.shared.wallet
    ) {
        self.walletService = walletService
        self.wallet = wallet
    }

    /// Creates a pin in the remote pin store.
    ///
    /// - Parameter pinPayload: the PinPayload
    /// - Returns: a Single returning the response
    func createPin(_ pinPayload: PinPayload) -> Single<PinStoreResponse> {
        return self.walletService.createPin(pinPayload)
            .do(onSuccess: { [weak self] response in
                try self?.handleCreatePinResponse(response: response, pinPayload: pinPayload)
            })
    }

    private func handleCreatePinResponse(response: PinStoreResponse, pinPayload: PinPayload) throws {
        guard let password = wallet.password else {
            throw PinError(localizedDescription: LocalizationConstants.Pin.cannotSaveInvalidWalletState)
        }
        wallet.isNew = false

        guard response.error == nil else {
            throw PinError(localizedDescription: response.error!)
        }

        guard let responseCode = response.statusCode, responseCode == .success else {
            let message = String(
                format: LocalizationConstants.Errors.invalidStatusCodeReturned,
                response.code ?? -1
            )
            throw PinError(localizedDescription: message)
        }

        guard let pinValue = pinPayload.pinValue,
            pinPayload.pinKey.count != 0,
            pinValue.count != 0 else {
            throw PinError(localizedDescription: LocalizationConstants.Pin.responseKeyOrValueLengthZero)
        }

        // Encrypt the wallet password with the random value
        let encryptedPinPassword = wallet.encrypt(password, password: pinValue)

        // Update the cache
        let appSettings = BlockchainSettings.App.shared
        appSettings.encryptedPinPassword = encryptedPinPassword
        appSettings.pinKey = pinPayload.pinKey
        appSettings.passwordPartHash = password.passwordPartHash

        updateCacheIfNeeded(response: response, pinPayload: pinPayload)
    }

    /// Validates if the provided pin payload (i.e. pin code and pin key combination) is correct.
    /// Calling this method will also handle updating the local pin store (i.e. the keychain),
    /// depending on the response for the remote pin store.
    ///
    /// - Parameter pinPayload: the PinPayload
    /// - Returns: an Single returning the response
    func validatePin(_ pinPayload: PinPayload) -> Single<PinStoreResponse> {
        return self.walletService.validatePin(pinPayload)
            .do(onSuccess: { [weak self] response in
                self?.updateCacheIfNeeded(response: response, pinPayload: pinPayload)
            })
    }

    private func updateCacheIfNeeded(response: PinStoreResponse, pinPayload: PinPayload) {
        guard let responseCode = response.statusCode else { return }

        switch responseCode {
        case .success:
            // Optionally save the pin to the keychain
            if pinPayload.persistLocally {
                pinPayload.pin?.saveToKeychain()
            }
            return
        case .deleted:
            // Clear pin from keychain if the user exceeded the number of retries when entering the pin.
            BlockchainSettings.App.shared.pin = nil
            return
        default:
            return
        }
    }
}

extension Wallet {
    @objc func encrypt(_ data: String, password: String) -> String {
        return self.encrypt(
            data,
            password: password,
            pbkdf2_iterations: Int32(Constants.Security.pinPBKDF2Iterations)
        )
    }
}
