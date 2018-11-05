//
//  MockXlmWallet.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class MockXlmWallet: XlmWallet {
    var didCallSave: XCTestExpectation?
    var accounts: [WalletXlmAccount]?

    func save(keyPair: StellarKeyPair, label: String, completion: @escaping KeyPairSaveCompletion) {
        let account = WalletXlmAccount(publicKey: keyPair.accountId, label: label)
        if accounts == nil {
            accounts = []
        }
        accounts?.append(account)
    }

    func xlmAccounts() -> [WalletXlmAccount]? {
        return accounts
    }
}
