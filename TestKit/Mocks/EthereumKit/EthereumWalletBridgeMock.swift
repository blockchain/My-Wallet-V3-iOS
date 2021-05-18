//
//  EthereumWalletBridgeMock.swift
//  EthereumKitTests
//
//  Created by Jack on 28/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
@testable import EthereumKit
import PlatformKit
import RxRelay
import RxSwift

enum EthereumWalletBridgeMockError: Error {
    case mockError
}

class EthereumWalletBridgeMock: EthereumWalletBridgeAPI, EthereumWalletAccountBridgeAPI, MnemonicAccessAPI, PasswordAccessAPI {
    func update(accountIndex: Int, label: String) -> Completable {
        .empty()
    }

    var balance: Single<CryptoValue> {
        balanceValue
    }
    
    var balanceMoney: Single<MoneyValue> {
        Single.just(.init(cryptoValue: CryptoValue.ether(major: "2.0")!))
    }
    
    var pendingBalanceMoney: Single<MoneyValue> {
        Single.just(.init(cryptoValue: CryptoValue.ether(major: "2.0")!))
    }
    
    var pendingBalanceMoneyObservable: Observable<MoneyValue> {
        pendingBalanceMoney
            .asObservable()
    }
    
    func updateMemo(for transactionHash: String, memo: String?) -> Completable {
        .empty()
    }

    func memo(for transactionHash: String) -> Single<String?> {
        .just(nil)
    }

    public var accountType: SingleAccountType {
        .nonCustodial
    }

    var isWaitingOnTransactionValue = Single.just(false)
    var isWaitingOnTransaction: Single<Bool> {
        isWaitingOnTransactionValue
    }

    var historyValue = Single.just(())
    var history: Single<Void> {
        historyValue
    }

    func fetchHistory() -> Single<Void> {
        history
    }

    var fetchBalanceValue: Single<CryptoValue> = Single.just(CryptoValue.ether(major: "2.0")!)
    var fetchBalance: Single<CryptoValue> {
        fetchBalanceValue
    }

    var balanceValue: Single<CryptoValue> = Single.just(CryptoValue.ether(major: "2.0")!)

    var balanceObservable: Observable<CryptoValue> {
        balance.asObservable()
    }
    
    var balanceMoneyObservable: Observable<MoneyValue> {
        balanceObservable.map { MoneyValue(cryptoValue: $0) }
    }

    let balanceFetchTriggerRelay = PublishRelay<Void>()

    var nameValue: Single<String> = Single.just(CryptoCurrency.ethereum.defaultWalletName)
    var name: Single<String> {
        nameValue
    }

    var addressValue: Single<EthereumAddress> = .just(EthereumAddress(stringLiteral: MockEthereumWalletTestData.account))
    var address: Single<EthereumAddress> {
        addressValue
    }

    var transactionsValue: Single<[EthereumHistoricalTransaction]> = Single.just([])
    var transactions: Single<[EthereumHistoricalTransaction]> {
        transactionsValue
    }

    var accountValue: Single<EthereumAssetAccount> = Single.just(
        EthereumAssetAccount(
            walletIndex: 0,
            accountAddress: MockEthereumWalletTestData.account,
            name: CryptoCurrency.ethereum.defaultWalletName
        )
    )
    var account: Single<EthereumAssetAccount> {
        accountValue
    }

    var nonceValue = Single.just(BigUInt(9))
    var nonce: Single<BigUInt> {
        nonceValue
    }

    var recordLastTransactionValue: Single<EthereumTransactionPublished> = Single<EthereumTransactionPublished>.error(EthereumKitError.unknown)
    var lastRecordedTransaction: EthereumTransactionPublished?
    func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        lastRecordedTransaction = transaction
        return recordLastTransactionValue
    }

    // MARK: - EthereumWalletAccountBridgeAPI

    var wallets: Single<[EthereumWalletAccount]> {
        Single.just([])
    }

    func save(keyPair: EthereumKeyPair, label: String) -> Completable {
        Completable.empty()
    }

    // MARK: - MnemonicAccessAPI

    var mnemonic: Maybe<String> {
        Maybe.just("")
    }

    var mnemonicForcePrompt: Maybe<String> {
        Maybe.just("")
    }

    var mnemonicPromptingIfNeeded: Maybe<String> {
        Maybe.just("")
    }

    func mnemonic(with secondPassword: String?) -> Single<Mnemonic> {
        .just("")
    }

    // MARK: - PasswordAccessAPI

    var passwordMaybe = Maybe.just("password")
    var password: Maybe<String> {
        passwordMaybe
    }
}
