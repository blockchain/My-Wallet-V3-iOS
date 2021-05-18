//
//  StellarWalletBridgeMock.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import StellarKit

class StellarWalletBridgeMock: StellarWalletBridgeAPI {
    var undelyingStellarWallets: [StellarWalletAccount] = []

    func update(accountIndex: Int, label: String) -> Completable {
        .empty()
    }

    func save(keyPair: StellarKeyPair, label: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let account = StellarWalletAccount(index: 0, publicKey: keyPair.accountID, label: label, archived: false)
        undelyingStellarWallets.append(account)
        completion(.success(()))
    }

    func stellarWallets() -> [StellarWalletAccount] {
        undelyingStellarWallets
    }
}
