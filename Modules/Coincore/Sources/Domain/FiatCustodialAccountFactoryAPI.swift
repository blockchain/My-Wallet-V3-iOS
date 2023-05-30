// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public protocol FiatCustodialAccountFactoryAPI {
    func fiatCustodialAccount(fiatCurrency: FiatCurrency) -> FiatAccount
}
