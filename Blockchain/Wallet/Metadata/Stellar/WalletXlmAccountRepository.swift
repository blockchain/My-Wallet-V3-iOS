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

    typealias SecondPasswordFetcher = (SecondPasswordFetchCompletion) -> Void
    typealias SecondPasswordFetchCompletion = (String) -> Void

    private let wallet: XlmWallet

    init(wallet: XlmWallet = WalletManager.shared.wallet) {
        self.wallet = wallet
    }

    /// Initializes a `WalletXlmAccount` in wallet metadata if no such account exists yet.
    ///
    /// - Parameter fetcher: closure for fetching the wallet second password if one is set
    func initializeMetadata(fetcher: SecondPasswordFetcher) {
        // Don't initialize if the wallet already has accounts
        guard accounts() == nil else {
            Logger.shared.info("Not initializing a new WalletXlmAccount in wallet metadata. One already exists.")
            return
        }

        let keyPairDeriver = StellarKeyPairDeriver()

        // Get second password if needed
        guard !wallet.needsSecondPassword() else {
            fetcher { [weak self] secondPassword in
                guard let mnemonic = wallet.getMnemonic(secondPassword) else {
                    Logger.shared.warning("Mnemonic is nil.")
                    return
                }
                let keyPair = keyPairDeriver.derive(mnemonic: mnemonic, passphrase: secondPassword)
                self?.save(keyPair: keyPair)
            }
            return
        }

        // If no second password, derive and save XLM account
        guard let mnemonic = wallet.getMnemonic(nil) else {
            Logger.shared.warning("Mnemonic is nil.")
            return
        }
        let keyPair = keyPairDeriver.derive(mnemonic: mnemonic)
        save(keyPair: keyPair)
    }

    func accounts() -> [WalletXlmAccount]? {
        return wallet.xlmAccounts()
    }

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
