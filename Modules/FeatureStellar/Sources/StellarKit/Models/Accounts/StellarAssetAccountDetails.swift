// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import stellarsdk

struct StellarAccountDetails: Equatable {
    let account: StellarAssetAccount
    let balance: CryptoValue
    let actionableBalance: CryptoValue
}

extension StellarAccountDetails {
    static func unfunded(accountID: String) -> StellarAccountDetails {
        let account = StellarAssetAccount(
            accountAddress: accountID,
            name: CryptoCurrency.stellar.defaultWalletName,
            description: CryptoCurrency.stellar.defaultWalletName,
            sequence: 0,
            subentryCount: 0
        )

        return StellarAccountDetails(
            account: account,
            balance: .zero(currency: .stellar),
            actionableBalance: .zero(currency: .stellar)
        )
    }
}
