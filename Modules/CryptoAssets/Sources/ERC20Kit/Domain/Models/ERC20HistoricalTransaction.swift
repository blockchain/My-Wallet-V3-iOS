// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import EthereumKit
import MoneyKit
import PlatformKit

public struct ERC20HistoricalTransaction: Hashable {

    /**
     The transaction identifier, used for equality checking and backend calls.

     - Note: For ERC20 assets, this is identical to `transactionHash`.
     */
    public var identifier: String {
        transactionHash
    }

    public var fromAddress: EthereumAddress
    public var toAddress: EthereumAddress
    public var direction: Direction
    public var amount: CryptoValue
    public var transactionHash: String
    public var createdAt: Date
    public var fee: CryptoValue?
    public var historicalFiatValue: FiatValue?
    public var note: String?

    public init(
        fromAddress: EthereumAddress,
        toAddress: EthereumAddress,
        direction: Direction,
        amount: CryptoValue,
        transactionHash: String,
        createdAt: Date,
        fee: CryptoValue?,
        note: String?
    ) {
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.direction = direction
        self.amount = amount
        self.transactionHash = transactionHash
        self.createdAt = createdAt
        self.fee = fee
        self.note = note
    }
}
