// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

/// A historical price series in fiat, for one crypto currency, in a specific time range.
public struct HistoricalPriceSeries: Equatable {

    // MARK: - Public Properties

    /// The associated crypto currency.
    public let currency: CryptoCurrency

    /// The array of quoted prices.
    public let prices: [PriceQuoteAtTime]

    /// The numeric difference, in minor units, between the last price and the first price in the series.
    public let fiatChange: BigInt

    /// The relative difference between the last price and the first price in the series.
    public let delta: Decimal

    /// The percentage difference between the last price and the first price in the series.
    public let deltaPercentage: Decimal

    // MARK: - Setup

    /// Creates a historical price series.
    ///
    /// - Parameters:
    ///   - currency: The crypto currency associated with `prices`.
    ///   - prices:   An array of quoted prices.
    public init(currency: CryptoCurrency, prices: [PriceQuoteAtTime]) {
        if let first = prices.first, let last = prices.last {
            let firstMinorAmount = first.moneyValue.minorAmount
            let fiatChange = last.moneyValue.minorAmount - firstMinorAmount
            let delta: Decimal
            if firstMinorAmount.isZero {
                delta = .zero
            } else {
                delta = fiatChange.decimalDivision(by: firstMinorAmount)
            }
            self.init(
                currency: currency,
                prices: prices,
                fiatChange: fiatChange,
                delta: delta,
                deltaPercentage: delta * 100
            )
        } else {
            self.init(currency: currency, prices: [], fiatChange: 0, delta: 0, deltaPercentage: 0)
        }
    }

    private init(
        currency: CryptoCurrency,
        prices: [PriceQuoteAtTime],
        fiatChange: BigInt,
        delta: Decimal,
        deltaPercentage: Decimal
    ) {
        self.currency = currency
        self.delta = delta
        self.deltaPercentage = deltaPercentage
        self.prices = prices
        self.fiatChange = fiatChange
    }
}
