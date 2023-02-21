// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct InterestTransactionState: Equatable {
    var account: CryptoInterestAccount
    var target: CryptoTradingAccount
    var action: AssetAction

    public init(
        account: CryptoInterestAccount,
        target: CryptoTradingAccount,
        action: AssetAction
    ) {
        self.account = account
        self.target = target
        self.action = action
    }
}

extension InterestTransactionState {
    public static func == (
        lhs: InterestTransactionState,
        rhs: InterestTransactionState
    ) -> Bool {
        lhs.action == rhs.action &&
            lhs.account.identifier == rhs.account.identifier
    }
}
