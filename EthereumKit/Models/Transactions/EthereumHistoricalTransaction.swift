//
//  EthereumTransaction.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol EthereumTransaction {
    var isConfirmed: Bool { get }
    var confirmations: Int { get }
}

public struct EthereumHistoricalTransaction: EthereumTransaction, HistoricalTransaction, Mineable {
    
    public typealias Address = EthereumAssetAddress
    
    public var fromAddress: EthereumAssetAddress
    public var toAddress: EthereumAssetAddress
    public var identifier: String
    public var direction: Direction
    public var amount: String
    public var transactionHash: String
    public var createdAt: Date
    public var fee: CryptoValue?
    public var memo: String?
    public var confirmations: Int
    public var isConfirmed: Bool {
        return confirmations == 12
    }
    
    public init(
        identifier: String,
        fromAddress: Address,
        toAddress: Address,
        direction: Direction,
        amount: String,
        transactionHash: String,
        createdAt: Date,
        fee: CryptoValue?,
        memo: String?,
        confirmations: Int) {
        self.identifier = identifier
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.direction = direction
        self.amount = amount
        self.transactionHash = transactionHash
        self.createdAt = createdAt
        self.fee = fee
        self.memo = memo
        self.confirmations = confirmations
    }
}
