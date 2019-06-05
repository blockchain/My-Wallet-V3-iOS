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
    
    var erc20TokenAccountsValue: Single<[ERC20TokenAccount]> = Single.just([])
    var erc20TokenAccounts: Single<[ERC20TokenAccount]> {
        return erc20TokenAccountsValue
    }
    
    var saveERC20TokenAccountsValue: Completable = Completable.empty()
    func save(erc20TokenAccounts: [ERC20TokenAccount]) -> Completable {
        return saveERC20TokenAccountsValue
    }
    
    var lastTransactionHashFetched: String?
    var lastTokenContractAddressFetched: String?
    var memoForTransactionHashValue: Single<String?> = Single.just("memo")
    func memo(for transactionHash: String, tokenContractAddress: String) -> Single<String?> {
        lastTransactionHashFetched = transactionHash
        lastTokenContractAddressFetched = tokenContractAddress
        return memoForTransactionHashValue
    }
    
    var lastTransactionMemoSaved: String?
    var lastTransactionHashSaved: String?
    var lastTokenContractAddressSaved: String?
    var saveTransactionMemoForTransactionHashValue: Completable = Completable.empty()
    func save(transactionMemo: String, for transactionHash: String, tokenContractAddress: String) -> Completable {
        lastTransactionMemoSaved = transactionMemo
        lastTransactionHashSaved = transactionHash
        lastTokenContractAddressSaved = tokenContractAddress
        return saveTransactionMemoForTransactionHashValue
    }
}
