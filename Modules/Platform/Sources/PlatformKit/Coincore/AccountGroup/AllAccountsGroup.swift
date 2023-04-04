// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Localization
import MoneyKit
import ToolKit

/// An `AccountGroup` containing all accounts.
public final class AllAccountsGroup: AccountGroup {
    private typealias LocalizedString = LocalizationConstants.AccountGroup

    public let accounts: [SingleAccount]
    public let identifier: AnyHashable = "AllAccountsGroup"
    public lazy var label: String = {
        if accounts.contains(where: { $0.accountType == .nonCustodial }) {
            return LocalizedString.allWallets
        }
        return LocalizedString.allAccounts
    }()

    public lazy var assetName: String = ""

    /// Optional initializer that returns nil if accounts array is empty.
    public init?(accounts: [SingleAccount]) {
        if accounts.isEmpty {
            return nil
        } else {
            self.accounts = accounts
        }
    }
}
