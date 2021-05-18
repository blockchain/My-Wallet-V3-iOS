//
//  EthereumWalletBridgeAPI.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import PlatformKit
import RxSwift

/// `Wallet.m` needs to be injected into much of the `WalletRepository` type classes.
/// The reason is we still heavily rely on `My-Wallet-V3`. We don't want to bring this into
/// `PlatformKit` as a dependency. So, we have `Wallet.m` conform to protocols that we need
/// and inject it in as a dependency. Frequently we'll use the term `bridge` as a way of
/// describing this.
public protocol EthereumWalletAccountBridgeAPI: class {
    var wallets: Single<[EthereumWalletAccount]> { get }
}

public protocol EthereumWalletBridgeAPI {
    var name: Single<String> { get }
    var address: Single<EthereumAddress> { get }
    var account: Single<EthereumAssetAccount> { get }
    var nonce: Single<BigUInt> { get }
    
    /// Streams a boolean value indicating whether if there is transaction that should complete
    var isWaitingOnTransaction: Single<Bool> { get }

    /// Fetches the previously cached history
    var history: Single<Void> { get }
    
    /// Fetches the history (expected to make a network call to do so).
    /// Always returns the updated history
    func fetchHistory() -> Single<Void>

    func memo(for transactionHash: String) -> Single<String?>
    func updateMemo(for transactionHash: String, memo: String?) -> Completable
    
    func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished>

    /// Updates the Ethereum account label at the given index.
    func update(accountIndex: Int, label: String) -> Completable
}

public typealias CompleteEthereumWalletBridgeAPI =
      EthereumWalletBridgeAPI
    & EthereumWalletAccountBridgeAPI
    & MnemonicAccessAPI
    & PasswordAccessAPI
