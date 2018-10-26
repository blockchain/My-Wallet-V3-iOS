//
//  WalletXlmAccountRepositoryTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxBlocking
import RxSwift
import XCTest
@testable import Blockchain

private class MockXlmWallet: XlmWallet {
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

private class MockMnemonicAccess: MnemonicAccess {
    var _mnemonic: Mnemonic?
    var _mnemonicForcePrompt: Mnemonic?

    var mnemonic: Maybe<Mnemonic> {
        guard let val = _mnemonic else {
            return Maybe.empty()
        }
        return Maybe.just(val)
    }

    var mnemonicForcePrompt: Maybe<Mnemonic> {
        guard let val = _mnemonicForcePrompt else {
            return Maybe.empty()
        }
        return Maybe.just(val)
    }
}

class WalletXlmAccountRepositoryTests: XCTestCase {

    private var mockXlmWallet: MockXlmWallet!
    private var mockMnemonicAccess: MockMnemonicAccess!
    private var accountRepository: WalletXlmAccountRepository!

    override func setUp() {
        super.setUp()
        mockXlmWallet = MockXlmWallet()
        mockMnemonicAccess = MockMnemonicAccess()
        accountRepository = WalletXlmAccountRepository(wallet: mockXlmWallet, mnemonicAccess: mockMnemonicAccess)
    }

    /// Tests that XLM initialization works when the wallet has a second password set
    func testIntializeWallet_needsSecondPassword() {
        mockMnemonicAccess._mnemonicForcePrompt = "mnemonic phrase double encrypted"
        let account = try? accountRepository.initializeMetadataMaybe()
            .asObservable()
            .toBlocking()
            .first()
        XCTAssertNotNil(account)
    }

    /// Tests that XLM initialization works when the wallet has no accounts
    func testInitializeWallet_noAccounts() {
        mockMnemonicAccess._mnemonic = "mnemonic phrase"
        let account = try? accountRepository.initializeMetadataMaybe()
            .asObservable()
            .toBlocking()
            .first()
        XCTAssertNotNil(account)
    }

    /// Tests that XLM initialization is skipped if the wallet has accounts
    func testInitializeWallet_hasAccounts() {
        mockXlmWallet.accounts = [
            WalletXlmAccount(publicKey: "key", label: "label")
        ]
        let account = try? accountRepository.initializeMetadataMaybe()
            .asObservable()
            .toBlocking()
            .first()
        XCTAssertNotNil(account)
    }
}
