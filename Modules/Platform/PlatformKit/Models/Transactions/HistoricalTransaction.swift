// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum Direction: String {
    /// A `credit` is an **increase** in liabilities (decrease in cash)
    /// relative to the account
    case credit

    /// A `debit` is an **increase** in cash relative to the account
    case debit

    /// `ETH` specific
    case transfer
}

public protocol HistoricalTransaction {
    associatedtype Address: AssetAddress

    /// The transaction identifier, used for equality checking and backend calls.
    var identifier: String { get }

    var fromAddress: Address { get }
    var toAddress: Address { get }
    var direction: Direction { get }
    var amount: CryptoValue { get }

    /// The transaction hash, used in Explorer URLs.
    var transactionHash: String { get }

    var createdAt: Date { get }
    var fee: CryptoValue? { get }
    var memo: String? { get }
}
