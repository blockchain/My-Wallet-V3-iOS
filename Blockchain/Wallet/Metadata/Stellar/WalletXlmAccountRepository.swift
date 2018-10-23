//
//  WalletXlmAccountRepository.swfit
//  Blockchain
//
//  Created by Chris Arriola on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for a wallet that contains an XLM account
protocol XlmWallet {
    typealias KeyPairSaveCompletion = (String?) -> Void

    func save(keyPair: StellarKeyPair, label: String, completion: @escaping KeyPairSaveCompletion)
    func xlmAccounts() -> [WalletXlmAccount]?
    func needsSecondPassword() -> Bool
    func getMnemonic(_ secondPassword: String?) -> String?
}

/// Repository for `WalletXlmAccount` instances
class WalletXlmAccountRepository {

    private let wallet: XlmWallet

    init(wallet: XlmWallet = WalletManager.shared.wallet) {
        self.wallet = wallet
    }

    /// The default `WalletXlmAccount`, will be nil if it has not yet been initialized
    var defaultAccount: WalletXlmAccount? {
        return accounts()?.first
    }

    /// Initializes a `WalletXlmAccount` in wallet metadata if no such account exists yet.
    ///
    /// - Parameter secondPassword: the second password for the wallet if it is double encrypted
    func initializeMetadata(secondPassword: String? = nil) {
        // Don't initialize if the wallet already has accounts
        guard accounts() == nil else {
            Logger.shared.info("Not initializing a new WalletXlmAccount in wallet metadata. One already exists.")
            return
        }

        // Derive and save XLM account
        guard let mnemonic = wallet.getMnemonic(secondPassword) else {
            Logger.shared.warning("Mnemonic is nil.")
            return
        }
        let keyPairDeriver = StellarKeyPairDeriver()
        let keyPair = keyPairDeriver.derive(mnemonic: mnemonic)
        save(keyPair: keyPair)
    }

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

// MARK: Extensions

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
