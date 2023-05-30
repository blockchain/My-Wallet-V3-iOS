// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public enum AccountType {
    /// Trading custodial account controlled by BCDC
    case trading
    /// Exchange custodial account controlled by BCDC
    case exchange
    /// An account controlled by the user within the BCDC ecosystem
    case nonCustodial
    /// An external account, such as an external crypto address
    case external
    /// An account representing a group of accounts
    case group
}

extension AccountType {
    public var isCustodial: Bool {
        self == .trading || self == .exchange
    }
}

public protocol Account {

    /// A user-facing description for the account.
    var label: String { get }

    /// A user-facing asset name for the account.
    var assetName: String { get }

    /// The `AccountType` of the account.
    var accountType: AccountType { get }

    /// The `CurrencyType` of the account
    var currencyType: CurrencyType { get }
}
