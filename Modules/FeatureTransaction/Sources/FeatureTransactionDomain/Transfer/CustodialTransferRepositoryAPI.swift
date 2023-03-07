// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit

public protocol CustodialTransferRepositoryAPI {

    // MARK: - Types

    typealias CustodialWithdrawalIdentifier = String

    // MARK: - Methods

    func transfer(
        moneyValue: MoneyValue,
        destination: String,
        fee: MoneyValue,
        memo: String?
    ) -> AnyPublisher<CustodialWithdrawalIdentifier, NabuNetworkError>

    func feesAndLimitsForInterest() -> AnyPublisher<CustodialTransferFee, NabuNetworkError>

    func fees() -> AnyPublisher<CustodialTransferFee, NabuNetworkError>

    /// Newer API for Trading to DeFi transfers
    /// - Parameters:
    ///   - currency: Currency of transaction (the withdrawal currency)
    ///   - fiatCurrency: User’s trading currency (a fiat currency - for display)
    ///   - amount: Amount in the specified currency (minor value) (crypto)
    ///   - max: Suggests whether user is trying to withdraw maximum amount.
    ///   Backend will calculate maximum withdrawable amount with regards to all fees
    /// - Returns: `AnyPublisher<WithdrawalFees, NabuNetworkError>`
    func withdrawalFees(
        currency: CurrencyType,
        fiatCurrency: CurrencyType,
        amount: String,
        max: Bool
    ) -> AnyPublisher<WithdrawalFees, NabuNetworkError>
}
