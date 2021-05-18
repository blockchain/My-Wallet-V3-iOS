//
//  EthereumWalletBridgeMock.swift
//  ERC20KitTests
//
//  Created by Jack on 23/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
@testable import ERC20Kit
import EthereumKit
import PlatformKit
import RxRelay
import RxSwift

class ERC20EthereumWalletBridgeMock: EthereumWalletBridgeAPI {
    func update(accountIndex: Int, label: String) -> Completable {
        .empty()
    }

    func updateMemo(for transactionHash: String, memo: String?) -> Completable {
        .empty()
    }

    func memo(for transactionHash: String) -> Single<String?> {
        .just(nil)
    }
    
    var pendingBalanceMoney: Single<MoneyValue> = Single.just(CryptoValue.pax(major: "1.0")!.moneyValue)
    
    var pendingBalanceMoneyObservable: Observable<MoneyValue> {
        pendingBalanceMoney
            .asObservable()
    }
    
    var balanceMoney: Single<MoneyValue> {
        balance
            .moneyValue
    }

    public var accountType: SingleAccountType {
        .nonCustodial
    }

    var isWaitingOnTransactionValue = Single.just(true)
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

    var balanceValue = Single.just(CryptoValue.pax(major: "2.0")!)
    var balance: Single<CryptoValue> {
        balanceValue
    }
    
    var balanceObservable: Observable<CryptoValue> {
        balance.asObservable()
    }
    
    var balanceMoneyObservable: Observable<MoneyValue> {
        balanceObservable.map { MoneyValue(cryptoValue: $0) }
    }
    
    let balanceFetchTriggerRelay = PublishRelay<Void>()
        
    var nameValue: Single<String> = Single.just("")
    var name: Single<String> {
        nameValue
    }

    var addressValue: Single<EthereumAddress> = .just(EthereumAddress(stringLiteral: "0x0000000000000000000000000000000000000000"))
    var address: Single<EthereumAddress> {
        addressValue
    }

    var transactionsValue: Single<[EthereumHistoricalTransaction]> = Single.just([])
    var transactions: Single<[EthereumHistoricalTransaction]> {
        transactionsValue
    }
    
    static let assetAccount = EthereumAssetAccount(walletIndex: 0, accountAddress: "", name: "")
    var accountValue: Single<EthereumAssetAccount> = Single.just(assetAccount)
    var account: Single<EthereumAssetAccount> {
        accountValue
    }
    
    var nonceValue = Single.just(BigUInt(1))
    var nonce: Single<BigUInt> {
        nonceValue
    }
    
    func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        .just(transaction)
    }
}
