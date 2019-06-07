//
//  ERC20BridgeMock.swift
//  ERC20KitTests
//
//  Created by Jack on 04/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import BigInt
import PlatformKit
import EthereumKit
@testable import ERC20Kit

class ERC20BridgeMock: ERC20BridgeAPI {
    
    var isWaitingOnEtherTransactionValue: Single<Bool> = Single.just(false)
    var isWaitingOnEtherTransaction: Single<Bool> {
        return isWaitingOnEtherTransactionValue
    }
    
    func tokenAccount(for key: String) -> Single<ERC20TokenAccount?> {
        return Single.just(nil)
    }
    
    var erc20TokenAccountsValue: Single<[String: ERC20TokenAccount]> = Single.just([:])
    var erc20TokenAccounts: Single<[String: ERC20TokenAccount]> {
        return erc20TokenAccountsValue
    }
    
    var saveERC20TokenAccountsValue: Completable = Completable.empty()
    func save(erc20TokenAccounts: [String: ERC20TokenAccount]) -> Completable {
        return saveERC20TokenAccountsValue
    }
    
    var lastTransactionHashFetched: String?
    var lastTokenKeyFetched: String?
    var memoForTransactionHashValue: Single<String?> = Single.just("memo")
    func memo(for transactionHash: String, tokenKey: String) -> Single<String?> {
        lastTransactionHashFetched = transactionHash
        lastTokenKeyFetched = tokenKey
        return memoForTransactionHashValue
    }
    
    var lastTransactionMemoSaved: String?
    var lastTransactionHashSaved: String?
    var lastTokenKeySaved: String?
    var saveTransactionMemoForTransactionHashValue: Completable = Completable.empty()
    func save(transactionMemo: String, for transactionHash: String, tokenKey: String) -> Completable {
        lastTransactionMemoSaved = transactionMemo
        lastTransactionHashSaved = transactionHash
        lastTokenKeySaved = tokenKey
        return saveTransactionMemoForTransactionHashValue
    }
}
