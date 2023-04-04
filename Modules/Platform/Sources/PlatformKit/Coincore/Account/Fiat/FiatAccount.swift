// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

public protocol FiatAccount: SingleAccount {
    var fiatCurrency: FiatCurrency { get }
    var capabilities: Capabilities? { get }
}

extension FiatAccount {

    public var currencyType: CurrencyType {
        fiatCurrency.currencyType
    }
}
