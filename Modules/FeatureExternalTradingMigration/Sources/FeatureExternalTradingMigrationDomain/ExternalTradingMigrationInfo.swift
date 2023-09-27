// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MigrationState: String, Encodable, Decodable {
    case available = "AVAILABLE"
    case notAvailable = "NOT_AVAILABLE"
    case pending = "PENDING"
    case complete = "COMPLETE"
}

public struct Balance: Equatable, Decodable {
    public let currency: String
    public let amount: String

    public init(currency: String, amount: String) {
        self.currency = currency
        self.amount = amount
    }
}

public struct ConsolidatedBalances: Equatable, Decodable {
    public let beforeMigration: [Balance]
    public let afterMigration: Balance
}

public struct ExternalTradingMigrationInfo: Equatable, Decodable {
    public let state: MigrationState
    public let consolidationCurrencies: [String]
    public let consolidatedBalances: ConsolidatedBalances
    public let availableBalances: [Balance]
    public let pendingBalances: [Balance]
}
