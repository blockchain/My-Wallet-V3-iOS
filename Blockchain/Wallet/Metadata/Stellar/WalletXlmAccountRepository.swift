//
//  WalletXlmAccountRepository.swfit
//  Blockchain
//
//  Created by Chris Arriola on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Protocol definition for a wallet that contains an XLM account
protocol XlmWallet {
    typealias KeyPairSaveCompletion = (String?) -> Void

    func save(keyPair: StellarKeyPair, label: String, completion: @escaping KeyPairSaveCompletion)
    func xlmAccounts() -> [WalletXlmAccount]?
}

/// Repository for `WalletXlmAccount` instances
class WalletXlmAccountRepository {

    private let wallet: XlmWallet
    private let mnemonicAccess: MnemonicAccess
    private let keyPairDeriver: StellarKeyPairDeriver

    init(
        wallet: XlmWallet = WalletManager.shared.wallet,
        mnemonicAccess: MnemonicAccess = WalletManager.shared.wallet,
        keyPairDeriver: StellarKeyPairDeriver = StellarKeyPairDeriver()
    ) {
        self.wallet = wallet
        self.mnemonicAccess = mnemonicAccess
        self.keyPairDeriver = keyPairDeriver
    }

    /// The default `WalletXlmAccount`, will be nil if it has not yet been initialized
    var defaultAccount: WalletXlmAccount? {
        return accounts()?.first
    }

    /// Retrieves the list of accounts stored in the user's wallet metadata
    ///
    /// - Returns: the list of WalletXlmAccount objects, or nil if no such account/s exist
    func accounts() -> [WalletXlmAccount]? {
        return wallet.xlmAccounts()
    }

    // MARK: - Private

    private func save(keyPair: StellarKeyPair) {
        wallet.save(keyPair: keyPair, label: LocalizationConstants.Stellar.defaultLabelName) { errorMessage in
            if let error = errorMessage {
                Logger.shared.warning("Could not save StellarKeyPair to wallet metadata. Error: \(error)")
            } else {
                Logger.shared.info("StellarKeyPair saved to wallet metadata.")
            }
        }
    }
}

// MARK: Rx

extension WalletXlmAccountRepository {

    /// Initializes the wallet with a WaletXlmAccount if no such account exists in the wallet metadata.
    ///
    /// - Returns: a Maybe emitting a WalletXlmAccount
    func initializeMetadataMaybe() -> Maybe<WalletXlmAccount> {
        return loadDefaultXlmAccount().ifEmpty(
            switchTo: createAndSaveXlmAccount()
        )
    }

    /// Gets the StellarKeyPair that is derived from the wallet's mnemonic phrase prompting the user
    /// for their second password if needed.
    ///
    /// - Returns: a Maybe returning a StellarKeyPair
    func loadStellarKeyPair() -> Maybe<StellarKeyPair> {
        return mnemonicAccess.mnemonicPromptingIfNeeded
            .map { [unowned self] mnemonic -> StellarKeyPair in
                return self.keyPairDeriver.derive(mnemonic: mnemonic)
            }
    }

    // MARK: Private

    private func loadDefaultXlmAccount() -> Maybe<WalletXlmAccount> {
        guard let defaultAccount = defaultAccount else {
            return Maybe.empty()
        }
        return Maybe.just(defaultAccount)
    }

    private func createAndSaveXlmAccount() -> Maybe<WalletXlmAccount> {
        return loadStellarKeyPair().do(onNext: { [unowned self] stellarKeyPair in
            self.save(keyPair: stellarKeyPair)
        })
        .map { keyPair -> WalletXlmAccount in
            return WalletXlmAccount(
                publicKey: keyPair.accountId,
                label: LocalizationConstants.Stellar.defaultLabelName
            )
        }
    }
}

// MARK: Wallet Extensions

extension Wallet: MnemonicAccess {
    var mnemonic: Maybe<Mnemonic> {
        guard !self.needsSecondPassword() else {
            return Maybe.empty()
        }
        guard let mnemonic = self.getMnemonic(nil) else {
            return Maybe.empty()
        }
        return Maybe.just(mnemonic)
    }

    var mnemonicForcePrompt: Maybe<Mnemonic> {
        return Maybe.create(subscribe: { observer -> Disposable in
            AuthenticationCoordinator.shared.showPasswordConfirm(
                withDisplayText: LocalizationConstants.Authentication.secondPasswordDefaultDescription,
                headerText: LocalizationConstants.Authentication.secondPasswordRequired,
                validateSecondPassword: true, confirmHandler: { [weak self] password in
                    guard let mnemonic = self?.getMnemonic(password) else {
                        observer(.completed)
                        return
                    }
                    observer(.success(mnemonic))
                }
            )
            return Disposables.create()
        })
    }
}

extension Wallet: XlmWallet {

    func save(keyPair: StellarKeyPair, label: String, completion: @escaping KeyPairSaveCompletion) {
        self.saveXlmAccount(keyPair.accountId, label: label, sucess: {
            completion(nil)
        }, error: { errorMessage in
            completion(errorMessage)
        })
    }

    func xlmAccounts() -> [WalletXlmAccount]? {
        guard let xlmAccountsRaw = self.getXlmAccounts() else {
            return nil
        }

        guard !xlmAccountsRaw.isEmpty else {
            return nil
        }

        return xlmAccountsRaw.castJsonObjects(type: WalletXlmAccount.self)
    }
}
