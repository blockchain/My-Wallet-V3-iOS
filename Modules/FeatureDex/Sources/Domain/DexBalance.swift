// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct DexBalance: Equatable, Identifiable, Hashable {

    // TODO: @audrea OPTION 1 add network here
    public var currency: CryptoCurrency { value.currency }
    public var id: String { currency.code }
    public let value: CryptoValue

    public init(value: CryptoValue) {
        self.value = value
    }
}
