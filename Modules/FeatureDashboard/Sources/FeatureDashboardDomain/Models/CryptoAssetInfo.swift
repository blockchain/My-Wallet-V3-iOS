// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit
import PlatformKit

public struct AssetBalanceInfo: Equatable, Identifiable, Hashable, Codable {
    public let cryptoBalance: MoneyValue
    public let fiatBalance: MoneyValuePair?
    public let currency: CurrencyType
    public let delta: Decimal?
    public let actions: AvailableActions?

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
        return actions.sorted(like: [.deposit, .withdraw, .viewActivity])
    }

    public init(
        cryptoBalance: MoneyValue,
        fiatBalance: MoneyValuePair?,
        currency: CurrencyType,
        delta: Decimal?,
        actions: AvailableActions? = nil
    ) {
        self.cryptoBalance = cryptoBalance
        self.fiatBalance = fiatBalance
        self.currency = currency
        self.delta = delta
        self.actions = actions
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
