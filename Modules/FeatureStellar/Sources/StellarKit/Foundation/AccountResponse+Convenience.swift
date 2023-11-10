// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import Foundation
import stellarsdk

// MARK: StellarSDK Convenience

extension AccountResponse {
    var totalBalance: CryptoValue {
        let value = balances
            .lazy
            .filter { $0.whichAssetType == .native }
            .map(\.balance)
            .compactMap { Decimal(string: $0) }
            .reduce(0, +)

        return CryptoValue.create(major: value, currency: .stellar)
    }

    func toAssetAccountDetails(minimumBalance: CryptoValue) -> StellarAccountDetails {
        let account = StellarAssetAccount(
            accountAddress: accountId,
            name: CryptoCurrency.stellar.defaultWalletName,
            description: CryptoCurrency.stellar.defaultWalletName,
            sequence: Int(sequenceNumber),
            subentryCount: subentryCount
        )
        var actionableBalance: CryptoValue = .zero(currency: .stellar)
        if let balanceMinusReserve = try? totalBalance - minimumBalance, balanceMinusReserve.isPositive {
            actionableBalance = balanceMinusReserve
        }
        return StellarAccountDetails(
            account: account,
            balance: totalBalance,
            actionableBalance: actionableBalance
        )
    }
}

extension AccountBalanceResponse {

    fileprivate enum WhichAssetType: String, Codable {
        case native
        case credit_alphanum4
        case credit_alphanum12
    }

    fileprivate var whichAssetType: WhichAssetType? {
        WhichAssetType(rawValue: assetType)
    }
}
