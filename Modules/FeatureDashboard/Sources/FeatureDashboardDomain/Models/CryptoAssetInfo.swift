// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit
import PlatformKit

public struct AssetBalanceInfo: Equatable, Identifiable, Hashable, Codable {
    public var balance: MoneyValue
    public var fiatBalance: MoneyValuePair?
    public let currency: CurrencyType
    public let delta: Decimal?
    public var actions: AvailableActions?

    public var id: String {
        currency.code
    }

    public var hasBalance: Bool {
        fiatBalance?.quote.hasOver1UnitBalance ?? false
    }

    public var sortedActions: [AssetAction] {
        guard let actions else {
            return []
        }
        return actions.sorted(like: [.deposit, .withdraw])
    }

    public init(
        cryptoBalance: MoneyValue,
        fiatBalance: MoneyValuePair?,
        currency: CurrencyType,
        delta: Decimal?,
        actions: AvailableActions? = nil
    ) {
        self.balance = cryptoBalance
        self.fiatBalance = fiatBalance
        self.currency = currency
        self.delta = delta
        self.actions = actions
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct FiatBalancesInfo: Equatable, Hashable {
    public let balances: [AssetBalanceInfo]
    public let tradingCurrency: FiatCurrency

    public init(balances: [AssetBalanceInfo], tradingCurrency: FiatCurrency) {
        self.balances = balances
        self.tradingCurrency = tradingCurrency
    }
}

extension MoneyOperating {
    public var hasOver1UnitBalance: Bool {
        (try? self >= Self.one(currency: currency)) == true
    }
}

extension AssetAction: Comparable {
    public static func < (lhs: PlatformKit.AssetAction, rhs: PlatformKit.AssetAction) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
