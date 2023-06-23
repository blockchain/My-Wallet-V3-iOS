// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct DexBalance: Equatable, Identifiable, Hashable {

    public var network: EVMNetwork? { currency.network() }
    public var currency: CryptoCurrency { value.currency }
    public var id: String { currency.code }
    public let value: CryptoValue

    public init(value: CryptoValue) {
        self.value = value
    }
}
