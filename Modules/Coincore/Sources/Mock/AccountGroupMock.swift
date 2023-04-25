// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Coincore
import MoneyKit

class AccountGroupMock: AccountGroup {

    let accounts: [SingleAccount]
    let currencyType: CurrencyType
    let identifier: AnyHashable
    let label: String
    let assetName: String

    init(
        accounts: [SingleAccount] = [],
        currencyType: CurrencyType,
        identifier: AnyHashable = "AccountGroupMock",
        label: String = "AccountGroupMock"
    ) {
        self.accounts = accounts
        self.currencyType = currencyType
        self.identifier = identifier
        self.label = label
        self.assetName = ""
    }
}
