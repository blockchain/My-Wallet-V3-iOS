// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import RxSwift

public enum TransactionResult {
    case signed(rawTx: String)
    case hashed(txHash: String, amount: MoneyValue?)
    case unHashed(amount: MoneyValue, order: OrderDetails? = nil)
}

public protocol TransactionTarget: Account {

    typealias TxCompleted = (TransactionResult) -> Completable

    /// A target may require an action to be taken after its transaction is completed.
    /// onTxCompleted must be called by the engine after the transaction is executed.
    var onTxCompleted: TxCompleted { get }
}

extension TransactionTarget {
    public var onTxCompleted: TxCompleted {
        { _ in .empty() }
    }
}

public protocol CryptoTarget: TransactionTarget {
    var asset: CryptoCurrency { get }
}

extension CryptoTarget {

    public var currencyType: CurrencyType {
        asset.currencyType
    }
}

/// A TransactionTarget that disallows changing its details (e.g. amount, target)
///
/// Currently used when dealing with BitPay, or WalletConnect transactions.
public protocol StaticTransactionTarget: TransactionTarget {}

/// A TransactionTarget that wraps an opaque transaction object.
/// This means we can't read each individual detail (e.g. amount, target).
///
/// Currently used when dealing with one WalletConnect method but it may be used elsewhere when the wallet receives a
/// transaction already signed/encoded and must just push it to the network.
public protocol RawStaticTransactionTarget: StaticTransactionTarget {}

/// A Wallet Connect Transaction Target.
public protocol WalletConnectTarget: StaticTransactionTarget {

    /// A Wallet Connect target may require an action to be taken after its transaction is rejected.
    /// onTransactionRejected must be called by the engine if the transaction flow ends before the transactions is executed.
    var onTransactionRejected: () -> AnyPublisher<Void, Never> { get }
}

extension WalletConnectTarget {
    public var onTransactionRejected: (TransactionResult) -> AnyPublisher<Void, Never> {
        { _ in
            AnyPublisher<Void, Never>.just(())
        }
    }
}
