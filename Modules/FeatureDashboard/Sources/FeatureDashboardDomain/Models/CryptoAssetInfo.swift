// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Coincore
import Foundation
import MoneyKit

public struct AssetBalanceInfo: Equatable, Identifiable, Hashable, Codable {
    public var balance: MoneyValue?
    public var fiatBalance: MoneyValuePair?
    public let currency: CurrencyType
    public let delta: Decimal?
    public var actions: AvailableActions?
    public var fastRising: Bool?
    public var network: AssetBalanceInfoNetwork?

    public let balanceFailingForNetwork: Bool?

    public var rawQuote: MoneyValue?
    public let yesterdayRawQuote: MoneyValue?

    public var yesterdayFiatBalance: MoneyValuePair? {
        guard let balance, let quote = yesterdayRawQuote else { return nil }
        return MoneyValuePair(
            base: balance,
            exchangeRate: quote
        )
    }

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
        cryptoBalance: MoneyValue?,
        fiatBalance: MoneyValuePair?,
        currency: CurrencyType,
        delta: Decimal?,
        actions: AvailableActions? = nil,
        fastRising: Bool? = nil,
        network: AssetBalanceInfoNetwork? = nil,
        balanceFailingForNetwork: Bool = false,
        rawQuote: MoneyValue?,
        yesterdayRawQuote: MoneyValue? = nil
    ) {
        self.balance = cryptoBalance
        self.fiatBalance = fiatBalance
        self.currency = currency
        self.delta = delta
        self.actions = actions
        self.fastRising = fastRising
        self.network = network
        self.balanceFailingForNetwork = balanceFailingForNetwork
        self.rawQuote = rawQuote
        self.yesterdayRawQuote = yesterdayRawQuote
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct FiatBalancesInfo: Codable, Equatable, Hashable {
    public let balances: [AssetBalanceInfo]
    public let tradingCurrency: FiatCurrency

    public init(balances: [AssetBalanceInfo], tradingCurrency: FiatCurrency) {
        self.balances = balances
        self.tradingCurrency = tradingCurrency
    }
}

public struct AssetBalanceInfoNetwork: Equatable, Codable, Hashable {
    public let currency: CryptoCurrency
    public let evmNetwork: EVMNetwork?

    public init(currency: CryptoCurrency, evmNetwork: EVMNetwork?) {
        self.currency = currency
        self.evmNetwork = evmNetwork
    }

    public var networkOrAssetName: String {
        guard let evmNetwork else {
            return currency.name
        }
        return evmNetwork.networkConfig.shortName
    }
}
