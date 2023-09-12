// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct TopMoverInfo: Identifiable, Equatable {
    public var id: String { currency.id }
    public let currency: CryptoCurrency
    public let delta: Decimal?
    public let lastPrice: MoneyValue

    public init(
        currency: CryptoCurrency,
        delta: Decimal? = nil,
        lastPrice: MoneyValue
    ) {
        self.currency = currency
        self.delta = delta
        self.lastPrice = lastPrice
    }
}
