// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A quoted price in fiat, for one currency, at a specific timestamp.
public struct PriceQuoteAtTime: Equatable {

    /// The timestamp of the quote.
    public let timestamp: Date

    /// The value of the quote.
    public let moneyValue: MoneyValue

    /// The total market cap of the currency.
    public let marketCap: Double?

    /// The total market cap of the currency.
    public let volume24h: Double?

    /// Creates a quoted price.
    ///
    /// - Parameters:
    ///   - response: A timestamp.
    ///   - currency: A value.
    public init(
        timestamp: Date,
        moneyValue: MoneyValue,
        marketCap: Double? = nil,
        volume24h: Double? = nil
    ) {
        self.timestamp = timestamp
        self.moneyValue = moneyValue
        self.marketCap = marketCap
        self.volume24h = volume24h
    }
}
