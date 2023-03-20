// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MoneyKit

public enum ActivityState: String, Equatable, Codable, Hashable {
    case failed = "FAILED"
    case pending = "PENDING"
    case completed = "COMPLETED"
    case confirming = "CONFIRMING"
    case unknown
}

public enum ActivityProductType: String, Equatable, Codable, Hashable {
    case defi // we need to expand this perhaps
    case buy
    case sell
    case swap
    case staking
    case activeRewards
    case saving
    case fiatOrder
    case cryptoOrder
}

public enum TransactionType: String, Equatable, Codable, Hashable {
    case deposit = "DEPOSIT"
    case withdraw = "WITHDRAWAL"
    case interestEarned = "INTEREST_OUTGOING"
    case debit = "DEBIT"
    case refund = "REFUND"
    case charge = "CHARGE"
}

public struct ActivityEntry: Equatable, Codable, Hashable {
    public let type: ActivityProductType
    public let id: String
    public let network: String
    public let pubKey: String
    public let externalUrl: String
    public let item: ActivityItem.CompositionView
    public let state: ActivityState
    public let timestamp: TimeInterval
    public let transactionType: TransactionType?

    public var asset: CurrencyType? {
        try? .init(code: network)
    }

    public init(
        id: String,
        type: ActivityProductType,
        network: String,
        pubKey: String,
        externalUrl: String,
        item: ActivityItem.CompositionView,
        state: ActivityState,
        timestamp: TimeInterval,
        transactionType: TransactionType?
    ) {
        self.id = id
        self.type = type
        self.network = network
        self.pubKey = pubKey
        self.externalUrl = externalUrl
        self.item = item
        self.state = state
        self.timestamp = timestamp
        self.transactionType = transactionType
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(state)
        hasher.combine(network)
        hasher.combine(type)
        if let txType = transactionType {
            hasher.combine(txType)
        }
    }
}

extension ActivityEntry {
    public var date: Date {
        Date(timeIntervalSince1970: timestamp)
    }
}
