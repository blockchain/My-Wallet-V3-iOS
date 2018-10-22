//
//  WalletXlmAccountRepositoryTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

private class MockXlmWallet: XlmWallet {
    var didCallSave: XCTestExpectation?
    var accounts: [WalletXlmAccount]? = nil
    var needsSecondPasswordVal: Bool = false
    var mnenomic: String = "one two three four"

    func needsSecondPassword() -> Bool {
        return needsSecondPasswordVal
    }

    func getMnemonic(_ secondPassword: String?) -> String? {
        return mnenomic
    }

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

class WalletXlmAccountRepositoryTests: XCTestCase {

    private var mockXlmWallet: MockXlmWallet!
    private var accountRepository: WalletXlmAccountRepository!

    override func setUp() {
        super.setUp()
        mockXlmWallet = MockXlmWallet()
        accountRepository = WalletXlmAccountRepository(wallet: mockXlmWallet)
    }

    /// Tests that XLM initialization works when the wallet has a second password set
    func testIntializeWallet_needsSecondPassword() {
        mockXlmWallet.needsSecondPasswordVal = true

        let fetcherCalledExpectation = expectation(description: "Second password should be fetched.")
        accountRepository.initializeMetadata(fetcher: { completion in
            completion("second password")
            fetcherCalledExpectation.fulfill()
        })
        XCTAssertEqual(1, mockXlmWallet.accounts?.count ?? 0)
        wait(for: [fetcherCalledExpectation], timeout: 0.1)
    }

    /// Tests that XLM initialization works when the wallet has no accounts
    func testInitializeWallet_noAccounts() {
        accountRepository.initializeMetadata(fetcher: { _ in })
        XCTAssertEqual(1, mockXlmWallet.accounts?.count ?? 0)
    }

    /// Tests that XLM initialization is skipped if the wallet has accounts
    func testInitializeWallet_hasAccounts() {
        mockXlmWallet.accounts = [
            WalletXlmAccount(publicKey: "key", label: "label")
        ]
        accountRepository.initializeMetadata(fetcher: { _ in })
        XCTAssertEqual(1, mockXlmWallet.accounts?.count ?? 0)
    }
}
