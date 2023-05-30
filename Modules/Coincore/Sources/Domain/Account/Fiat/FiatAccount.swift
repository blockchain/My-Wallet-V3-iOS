// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public protocol FiatAccount: SingleAccount {
    var fiatCurrency: FiatCurrency { get }
}

extension FiatAccount {

    public var currencyType: CurrencyType {
        fiatCurrency.currencyType
    }
}
