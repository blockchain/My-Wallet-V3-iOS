//
//  EthereumWalletBridgeMock.swift
//  EthereumKitTests
//
//  Created by Jack on 28/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import BigInt
import PlatformKit
@testable import EthereumKit

enum EthereumWalletBridgeMockError: Error {
    case mockError
}

class EthereumWalletBridgeMock: EthereumWalletBridgeAPI, EthereumWalletAccountBridgeAPI, MnemonicAccessAPI, PasswordAccessAPI {
    
    var fetchHistoryValue = Single.just(())
    var fetchHistory: Single<Void> {
        return fetchHistoryValue
    }
    
    var fetchHistoryIfNeededValue = Single.just(())
    var fetchHistoryIfNeeded: Single<Void> {
        return fetchHistoryIfNeededValue
    }
    
    var fetchBalanceValue: Single<CryptoValue> = Single.just(CryptoValue.etherFromMajor(decimal: Decimal(2.0)))
    var fetchBalance: Single<CryptoValue> {
        return fetchBalanceValue
    }
    
    var balanceValue: Single<CryptoValue> = Single.just(CryptoValue.etherFromMajor(decimal: Decimal(2.0)))
    var balance: Single<CryptoValue> {
        return balanceValue
    }
    
    var nameValue: Single<String> = Single.just("My Ether Wallet")
    var name: Single<String> {
        return nameValue
    }
    
    var addressValue: Single<String> = Single.just(MockEthereumWalletTestData.account)
    var address: Single<String> {
        return addressValue
    }
    
    var transactionsValue: Single<[EthereumHistoricalTransaction]> = Single.just([])
    var transactions: Single<[EthereumHistoricalTransaction]> {
        return transactionsValue
    }
    
    var accountValue: Single<EthereumAssetAccount> = Single.just(
        EthereumAssetAccount(
            walletIndex: 0,
            accountAddress: MockEthereumWalletTestData.account,
            name: "My Ether Wallet"
        )
    )
    var account: Single<EthereumAssetAccount> {
        return accountValue
    }
    
    var nonceValue = Single.just(BigUInt(9))
    var nonce: Single<BigUInt> {
        return nonceValue
    }
    
    var isWaitingOnEtherTransactionValue = Single.just(false)
    var isWaitingOnEtherTransaction: Single<Bool> {
        return isWaitingOnEtherTransactionValue
    }
    
    var recordLastTransactionValue: Single<EthereumTransactionPublished> = Single<EthereumTransactionPublished>.error(EthereumKitError.unknown)
    var lastRecordedTransaction: EthereumTransactionPublished?
    func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        lastRecordedTransaction = transaction
        return recordLastTransactionValue
    }
    
    // MARK: - EthereumWalletAccountBridgeAPI
    
    var ethereumWallets: Single<[EthereumWalletAccount]> {
        return Single.just([])
    }
    
    func save(keyPair: EthereumKeyPair, label: String) -> Completable {
        return Completable.empty()
    }
    
    // MARK: - MnemonicAccessAPI
    
    var mnemonic: Maybe<String> {
        return Maybe.just("")
    }
    
    var mnemonicForcePrompt: Maybe<String> {
        return Maybe.just("")
    }
    
    var mnemonicPromptingIfNeeded: Maybe<String> {
        return Maybe.just("")
    }
    
    // MARK: - PasswordAccessAPI
    
    var passwordMaybe = Maybe.just("password")
    var password: Maybe<String> {
        return passwordMaybe
    }
}
