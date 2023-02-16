// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public final class BankAccountReceiveAddress: ReceiveAddress {
    public let address: String
    public let label: String
    public let assetName: String
    public let currencyType: CurrencyType
    public var accountType: AccountType

    public init(address: String, label: String, assetName: String, currencyType: CurrencyType) {
        self.address = address
        self.label = label
        self.assetName = assetName
        self.currencyType = currencyType
        self.accountType = .external
    }
}
