// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct DexQuoteInput {
    public var amount: CryptoValue
    public var destination: CryptoCurrency
    public var skipValidation: Bool
    public var slippage: Double
    public var takerAddress: String

    public init(
        amount: CryptoValue,
        destination: CryptoCurrency,
        skipValidation: Bool,
        slippage: Double,
        takerAddress: String
    ) {
        self.takerAddress = takerAddress
        self.amount = amount
        self.destination = destination
        self.slippage = slippage
        self.skipValidation = skipValidation
    }
}
