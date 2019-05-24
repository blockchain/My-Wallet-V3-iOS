//
//  EthereumWalletBridgeAPI.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import BigInt

///// `Wallet.m` needs to be injected into much of the `WalletRepository` type classes.
///// The reason is we still heavily rely on `My-Wallet-V3`. We don't want to bring this into
///// `PlatformKit` as a dependency. So, we have `Wallet.m` conform to protocols that we need
///// and inject it in as a dependency. Frequently we'll use the term `bridge` as a way of
///// describing this.
public protocol EthereumWalletAccountBridgeAPI: class {
    var ethereumWallets: Single<[EthereumWalletAccount]> { get }
    
    func save(keyPair: EthereumKeyPair, label: String) -> Single<String>
}

public protocol EthereumWalletBridgeAPI: class {
    var fetchBalance: Single<CryptoValue> { get }
    var balance: Single<CryptoValue> { get }
    var name: Single<String> { get }
    var address: Single<String> { get }
    var account: Single<EthereumAssetAccount> { get }
    var nonce: Single<BigUInt> { get }
    var isWaitingOnEtherTransaction: Single<Bool> { get }
    
    func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished>
}

public protocol EthereumWalletTransctionsBridgeAPI: class {
    var transactions: Single<[EthereumHistoricalTransaction]> { get }
}
