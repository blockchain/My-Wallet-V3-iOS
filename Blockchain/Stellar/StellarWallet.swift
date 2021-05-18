//
//  StellarWallet.swift
//  Blockchain
//
//  Created by Paulo on 29/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import StellarKit

/// `StellarWalletBridgeAPI` is part of the `bridge` that is used when injecting the `wallet` into
/// a `WalletAccountRepository`. This is how we save the users `StellarKeyPair`
final class StellarWallet: StellarWalletBridgeAPI {

    private let wallet: Wallet
    
    init(walletManager: WalletManager = resolve()) {
        self.wallet = walletManager.wallet
    }

    func update(accountIndex: Int, label: String) -> Completable {
        wallet.updateAccountLabel(.stellar, index: accountIndex, label: label)
    }

    func save(keyPair: StellarKit.StellarKeyPair, label: String, completion: @escaping (Result<Void, Error>) -> Void) {
        wallet.saveXlmAccount(
            keyPair.accountID,
            label: label,
            success: {
                completion(.success(()))
            },
            error: { _ in
                completion(.failure(StellarAccountError.unableToSaveNewAccount))
            }
        )
    }

    func stellarWallets() -> [StellarKit.StellarWalletAccount] {
        guard let xlmAccountsRaw = wallet.getXlmAccounts() else {
            return []
        }
        guard !xlmAccountsRaw.isEmpty else {
            return []
        }
        return xlmAccountsRaw.castJsonObjects(type: StellarWalletAccount.self)
    }
}
