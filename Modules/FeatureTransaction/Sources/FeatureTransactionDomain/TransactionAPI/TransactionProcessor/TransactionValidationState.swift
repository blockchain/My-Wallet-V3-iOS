// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import FeatureProductsDomain
import MoneyKit
import PlatformKit

public enum TransactionValidationState: Equatable {

    public struct LimitsUpgrade: Equatable {
        public let requiresVerified: Bool
    }

    /// The transaction has not been initialized yet
    case uninitialized
    /// The transaction is valid and can be executed
    case canExecute
    /// Any other error
    case unknownError
    /// represents a raw error from backend
    case nabuError(NabuError)
    /// The available balance of the source account is not sufficient to conver the input amount.
    /// Takes the balance of the transaction's source in the input currency, the desired amount, the source currency and the target currency
    case insufficientFunds(MoneyValue, MoneyValue, CurrencyType, CurrencyType)
    /// The available balance of the source account is not sufficient to conver fees required to pay for the transaction.
    /// Takes the total fees required for the transaction and the balance for the source account.
    case belowFees(MoneyValue, MoneyValue)
    /// The amount is below the minimum allowed for the transaction type.
    /// Takes the minimum valid amount required to execute the transaction.
    case belowMinimumLimit(MoneyValue)
    /// The amount is above the maximum allowed for this transaction for the specific source.
    /// Takes the maximum limit, the account name, and the desired amount.
    case overMaximumSourceLimit(MoneyValue, String, MoneyValue)
    /// The amount is over the user's maximum limit for the transaction.
    /// Takes the applicable Periodic Limit that has been exceeded, the available limit, and an optional suggested upgrade.
    case overMaximumPersonalLimit(EffectiveLimit, MoneyValue, LimitsUpgrade?)
    /// The account is restricted and cannot transact
    /// Takes the ineligibility reason as a parameter
    case accountIneligible(ProductIneligibility)

    case sourceAccountUsageIsBlocked(UX.Dialog)

    // MARK: - Not checked

    case noSourcesAvailable
    case addressIsContract
    case invalidAddress
    case invoiceExpired
    case incorrectSourceCurrency
    case incorrectDestinationCurrency
    case optionInvalid
    case pendingOrdersLimitReached
    case transactionInFlight
    case insufficientInterestWithdrawalBalance

    var isUninitialized: Bool {
        switch self {
        case .uninitialized:
            return true
        default:
            return false
        }
    }

    var isCanExecute: Bool {
        switch self {
        case .canExecute:
            return true
        default:
            return false
        }
    }
}
