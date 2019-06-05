//
//  EthereumWalletTests.swift
//  BlockchainTests
//
//  Created by Jack on 22/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import PlatformKit
@testable import EthereumKit
@testable import ERC20Kit
@testable import PlatformUIKit
@testable import Blockchain

class EthereumWalletTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var subject: EthereumWallet!
    var legacyWalletMock: MockLegacyEthereumWallet!

    override func setUp() {
        super.setUp()
        
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        
        legacyWalletMock = MockLegacyEthereumWallet()
        subject = EthereumWallet(wallet: legacyWalletMock)
        _ = subject.walletLoaded().subscribeOn(scheduler)
    }

    override func tearDown() {
        legacyWalletMock = nil
        subject = nil
        super.tearDown()
    }
    
    func test_wallet_balance() {
        // Arrange
        let expectedBalance: CryptoValue = CryptoValue.etherFromMajor(decimal: Decimal(1337.0))
        let balanceObservable: Observable<CryptoValue> = subject
            .balance
            .asObservable()
        
        // Act
        let result: TestableObserver<CryptoValue> = scheduler
            .start { balanceObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<CryptoValue>>] = Recorded.events(
            .next(
                200,
                expectedBalance
            ),
            .completed(200)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_wallet_name() {
        // Arrange
        let expectedName = "My ETH Wallet"
        let nameObservable: Observable<String> = subject
            .name
            .asObservable()
        
        // Act
        let result: TestableObserver<String> = scheduler
            .start { nameObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<String>>] = Recorded.events(
            .next(
                200,
                expectedName
            ),
            .completed(200)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }

    func test_wallet_address() {
        // Arrange
        let expectedAddress = "address"
        let addressObservable: Observable<String> = subject
            .address
            .asObservable()
        
        // Act
        let result: TestableObserver<String> = scheduler
            .start { addressObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<String>>] = Recorded.events(
            .next(
                200,
                expectedAddress
            ),
            .completed(200)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_wallet_transactions() {
        // Arrange
        let expectedTransactions: [EthereumHistoricalTransaction] = [
            EthereumHistoricalTransaction(
                identifier: "transactionHash",
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
        
        let legacyTransactions = expectedTransactions.compactMap { $0.legacyTransaction }
        legacyWalletMock.getEthereumTransactionsCompletion = .success(legacyTransactions)
        
        let transactionsObservable: Observable<[EthereumHistoricalTransaction]> = subject
            .transactions
            .asObservable()
        
        // Act
        let result: TestableObserver<[EthereumHistoricalTransaction]> = scheduler
            .start { transactionsObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<[EthereumHistoricalTransaction]>>] = Recorded.events(
            .next(
                200,
                expectedTransactions
            ),
            .completed(200)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_wallet_account() {
        // Arrange
        let expectedAccount = EthereumAssetAccount(
            walletIndex: 0,
            accountAddress: MockEthereumWalletTestData.account,
            name: "My ETH Wallet"
        )
        
        let accountObservable: Observable<EthereumAssetAccount> = subject
            .account
            .asObservable()
        
        // Act
        let result: TestableObserver<EthereumAssetAccount> = scheduler
            .start { accountObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumAssetAccount>>] = Recorded.events(
            .next(
                200,
                expectedAccount
            ),
            .completed(200)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_wallet_not_initialised() {
        // Arrange
        legacyWalletMock.ethereumAccountsCompletion = .failure(
            MockLegacyEthereumWallet.MockLegacyEthereumWalletError.notInitialized
        )
        
        let expectedAccount = EthereumAssetAccount(
            walletIndex: 0,
            accountAddress: MockEthereumWalletTestData.account,
            name: "My ETH Wallet"
        )
        
        let walletObservable: Observable<EthereumAssetAccount> = subject
            .account
            .asObservable()
        
        // Act
        let result: TestableObserver<EthereumAssetAccount> = scheduler
            .start { walletObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumAssetAccount>>] = Recorded.events(
            .error(200, Blockchain.WalletError.unknown)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_get_token_accounts() {
        // Arrange
        let paxTokenAccount = ERC20TokenAccount(
            label: "My PAX Wallet",
            contractAddress: PaxToken.contractAddress.rawValue,
            hasSeen: "false",
            transactionNotes: [
                "transaction_hash": "memo"
            ]
        )
        let expectedTokenAccounts: [ERC20TokenAccount] = [ paxTokenAccount ]

        let tokenAccountsObservable: Observable<[ERC20TokenAccount]> = self.subject
            .erc20TokenAccounts
            .asObservable()

        // Act
        let result: TestableObserver<[ERC20TokenAccount]> = self.scheduler
            .start { tokenAccountsObservable }

        // Assert
        let expectedEvents: [Recorded<Event<[ERC20TokenAccount]>>] = Recorded.events(
            .next(
                200,
                expectedTokenAccounts
            ),
            .completed(200)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_save_token_accounts() {
        // Arrange
        let paxTokenAccount = ERC20TokenAccount(
            label: "My PAX Wallet",
            contractAddress: PaxToken.contractAddress.rawValue,
            hasSeen: "false",
            transactionNotes: [
                "transaction_hash": "memo"
            ]
        )
        let tokenAccounts: [ERC20TokenAccount] = [ paxTokenAccount ]
        
        let saveTokenAccountsObservable: Observable<Never> = subject
            .save(erc20TokenAccounts: tokenAccounts)
            .asObservable()
        
        // Act
        let result: TestableObserver<Never> = scheduler
            .start { saveTokenAccountsObservable }
        
        // Assert
        guard result.events.count == 1, let value = result.events.first?.value, value.isCompleted else {
            XCTFail("Saving should complete successfully")
            return
        }
        
        XCTAssertEqual(legacyWalletMock.lastSavedTokensJSONString, "{\"0x8E870D67F660D95d5be530380D0eC0bd388289E1\":{\"label\":\"My PAX Wallet\",\"contract\":\"0x8E870D67F660D95d5be530380D0eC0bd388289E1\",\"has_seen\":\"false\",\"tx_notes\":{\"transaction_hash\":\"memo\"}}}")
    }
    
    func test_get_transaction_memo_for_token_transaction_hash() {
        // Arrange
        let expectedMemo = "memo"
        
        let transactionHash = "transaction_hash"
        let tokenContractAddress = "0x8E870D67F660D95d5be530380D0eC0bd388289E1"
        
        let memoObservable: Observable<String?> = subject
            .memo(for: transactionHash, tokenContractAddress: tokenContractAddress)
            .asObservable()
        
        // Act
        let result: TestableObserver<String?> = scheduler
            .start { memoObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<String?>>] = Recorded.events(
            .next(
                200,
                expectedMemo
            ),
            .completed(200)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_save_transaction_memo_for_token_transaction_hash() {
        // Arrange
        let memo = "memo"
        
        let transactionHash = "transactionHash"
        let tokenContractAddress = "0x8E870D67F660D95d5be530380D0eC0bd388289E1"
        
        let saveTokenAccountsObservable: Observable<Never> = subject
            .save(
                transactionMemo: memo,
                for: transactionHash,
                tokenContractAddress: tokenContractAddress
            )
            .asObservable()
        
        // Act
        let result: TestableObserver<Never> = scheduler
            .start { saveTokenAccountsObservable }
        
        // Assert
        guard result.events.count == 1, let value = result.events.first?.value, value.isCompleted else {
            XCTFail("Saving should complete successfully")
            return
        }
        
        XCTAssertEqual(legacyWalletMock.lastSavedTokensJSONString, "{\"0x8E870D67F660D95d5be530380D0eC0bd388289E1\":{\"label\":\"My PAX Wallet\",\"contract\":\"0x8E870D67F660D95d5be530380D0eC0bd388289E1\",\"has_seen\":\"false\",\"tx_notes\":{\"transactionHash\":\"memo\",\"transaction_hash\":\"memo\"}}}")
    }
}

extension ERC20TokenAccount: Equatable {
    public static func == (lhs: ERC20TokenAccount, rhs: ERC20TokenAccount) -> Bool {
        return lhs.label == rhs.label
            && lhs.contractAddress == rhs.contractAddress
            && lhs.hasSeen == rhs.hasSeen
            && lhs.transactionNotes == rhs.transactionNotes
    }
}

extension EthereumHistoricalTransaction: Equatable {
    public static func == (lhs: EthereumHistoricalTransaction, rhs: EthereumHistoricalTransaction) -> Bool {
        return lhs.amount == rhs.amount
            && lhs.confirmations == rhs.confirmations
            && Calendar(identifier: .gregorian).compare(lhs.createdAt, to: rhs.createdAt, toGranularity: Calendar.Component.nanosecond) == .orderedSame
            && lhs.direction == rhs.direction
            && lhs.fee == rhs.fee
            && lhs.fromAddress == rhs.fromAddress
            && lhs.memo == rhs.memo
            && lhs.toAddress == rhs.toAddress
            && lhs.transactionHash == rhs.transactionHash
    }
}
