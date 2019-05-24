//
//  EthereumWalletTests.swift
//  BlockchainTests
//
//  Created by Jack on 22/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
@testable import PlatformKit
@testable import EthereumKit
@testable import PlatformUIKit
@testable import Blockchain

class EthereumWalletTests: XCTestCase {
    
    var subject: EthereumWallet!
    var legacyWalletMock: MockLegacyEthereumWallet!

    override func setUp() {
        super.setUp()
        legacyWalletMock = MockLegacyEthereumWallet()
        subject = EthereumWallet(wallet: legacyWalletMock)
    }

    override func tearDown() {
        legacyWalletMock = nil
        subject = nil
        super.tearDown()
    }
    
    func test_wallet_balance() {
        let expectation = self.expectation(description: "the wallet should return the correct balance")

        _ = subject.balance
            .subscribe(onSuccess: { balance in
                XCTAssertEqual(balance, CryptoValue.etherFromMajor(decimal: 1337))
                expectation.fulfill()
            }, onError: nil)

        waitForExpectations(timeout: 5)
    }
    
    func test_wallet_name() {
        let expectation = self.expectation(description: "the wallet should return the correct name")

        _ = subject.name
            .subscribe(onSuccess: { name in
                XCTAssertEqual(name, "account: 0, assetType: 1")
                expectation.fulfill()
            }, onError: nil)

        waitForExpectations(timeout: 5)
    }

    func test_wallet_address() {
        let expectation = self.expectation(description: "the wallet should return the correct address")
        
        _ = subject.address
            .subscribe(onSuccess: { addressString in
                XCTAssertEqual(addressString, "address")
                expectation.fulfill()
            }, onError: nil)
        
        waitForExpectations(timeout: 5)
    }
    
    func test_wallet_transactions() {
        let expectation = self.expectation(description: "the wallet should return the correct transactions")

        _ = subject.transactions
            .subscribe(onSuccess: { transactions in
                let expectedTransactions: [EthereumHistoricalTransaction] = [
                    EthereumHistoricalTransaction(
                        identifier: "identifier",
                        fromAddress: EthereumHistoricalTransaction.Address(publicKey: "fromAddress.publicKey"),
                        toAddress: EthereumHistoricalTransaction.Address(publicKey: "toAddress.publicKey"),
                        direction: .credit,
                        amount: "amount",
                        transactionHash: "transactionHash",
                        createdAt: Date(),
                        fee: CryptoValue.etherFromGwei(string: "231000"),
                        memo: "memo",
                        confirmations: 12
                    )
                ].compactMap { $0 }
                XCTAssertEqual(transactions.count, expectedTransactions.count)
                
                expectation.fulfill()
            }, onError: nil)

        waitForExpectations(timeout: 5)
    }
    
    func test_wallet_account() {
        let expectation = self.expectation(description: "the wallet should return the correct account details")

        _ = subject.account
            .subscribe(onSuccess: { account in
                let expectedAccount = EthereumAssetAccount(
                    walletIndex: 0,
                    accountAddress: "address",
                    name: "account: 0, assetType: 1"
                )
                XCTAssertEqual(account.walletIndex, expectedAccount.walletIndex)
                XCTAssertEqual(account.accountAddress, expectedAccount.accountAddress)
                XCTAssertEqual(account.name, expectedAccount.name)
                expectation.fulfill()
            }, onError: nil)

        waitForExpectations(timeout: 5)
    }
    
    func test_wallet_not_initialised() {
        let expectation = self.expectation(description: "the wallet should return a not initialised error")
        
        legacyWalletMock.getEtherAddressCompletion = .failure(.notInitialized)
        legacyWalletMock.labelForAccount = nil
        legacyWalletMock.getEthBalanceTruncatedNumberValue = nil
        legacyWalletMock.ethTransactions = nil
        
        _ = Single.zip(
                subject.balance,
                subject.name,
                subject.address,
                subject.transactions,
                subject.account
            )
            .subscribe(onSuccess: { _ in
                XCTFail("The wallet should return an error")
            }, onError: { e in
                if let error = e as? Blockchain.WalletError, error == .notInitialized {
                    expectation.fulfill()
                    return
                }
                XCTFail("expected a not initialised error")
            })
        
        waitForExpectations(timeout: 5)
    }
}
