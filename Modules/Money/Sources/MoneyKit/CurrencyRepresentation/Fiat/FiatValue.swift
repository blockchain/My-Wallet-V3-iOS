// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

/// A fiat money value.
public struct FiatValue: Fiat, Hashable {

    public let storeAmount: BigInt

    public let currency: FiatCurrency

    /// Creates a fiat value.
    ///
    /// - Parameters:
    ///   - amount:   An amount in minor units.
    ///   - currency: A fiat currency.
    public init(storeAmount: BigInt, currency: FiatCurrency) {
        self.storeAmount = storeAmount
        self.currency = currency
    }
}

extension FiatValue: MoneyOperating {}
