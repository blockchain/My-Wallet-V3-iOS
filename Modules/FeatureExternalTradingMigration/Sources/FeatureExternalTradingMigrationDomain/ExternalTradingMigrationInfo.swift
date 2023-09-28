// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public enum MigrationState: String, Encodable, Decodable {
    case available = "AVAILABLE"
    case notAvailable = "NOT_AVAILABLE"
    case pending = "PENDING"
    case complete = "COMPLETE"
}

public struct Balance: Equatable, Decodable {
    public let currency: CurrencyType
    public let amount: MoneyValue

    enum CodingKeys: String, CodingKey {
        case amount
        case currency
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let amountString = try values.decode(String.self, forKey: .amount)
        let currency = try values.decode(String.self, forKey: .currency)
        self.currency = try CurrencyType(code: currency)
        self.amount = MoneyValue.create(minor: amountString, currency: self.currency) ?? .zero(currency: self.currency)
    }

    public init(currency: CurrencyType, amount: MoneyValue) {
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
