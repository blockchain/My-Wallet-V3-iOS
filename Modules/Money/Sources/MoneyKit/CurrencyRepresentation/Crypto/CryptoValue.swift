// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

/// A crypto money value.
public struct CryptoValue: CryptoMoney, Hashable {

    public let storeAmount: BigInt

    public let currency: CryptoCurrency

    /// Creates a crypto value.
    ///
    /// - Parameters:
    ///   - amount:   An amount in minor units.
    ///   - currency: A crypto currency.
    public init(storeAmount: BigInt, currency: CryptoCurrency) {
        self.storeAmount = storeAmount
        self.currency = currency
    }
}

extension CryptoValue: MoneyOperating {}
