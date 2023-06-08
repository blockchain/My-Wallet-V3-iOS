// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Errors
import FeatureOpenBankingDomain
import FeatureOpenBankingUI
import FeatureProductsDomain
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import SwiftUI
import ToolKit

enum TransactionErrorState: Equatable, Error {
    /// The tansaction is valid
    case none
    /// Any other error
    case unknownError
    /// A network error
    case nabuError(NabuError)
    /// The balance of the source account is not sufficient to execute the transaction.
    /// Takes the balance of the transaction's source in the input currency, the desired amount, the source currency and the target currency.
    case insufficientFunds(MoneyValue, MoneyValue, CurrencyType, CurrencyType)
    /// The available balance of the source account is not sufficient to conver fees required to pay for the transaction.
    /// Takes the total fees required for the transaction and the balance for the source account.
    case belowFees(MoneyValue, MoneyValue)
    /// The amount is below the user's minimum limit for the transaction.
    /// Takes the minimum valid amount required to execute the transaction.
    case belowMinimumLimit(MoneyValue)
    /// The amount is over the maximum allowed for this transaction for the specific source.
    /// Takes the maximum limit, the account name, and the desired amount.
    case overMaximumSourceLimit(MoneyValue, String, MoneyValue)
    /// The amount is over the user's maximum limit for the transaction.
    /// Takes the applicable Periodic Limit that has been exceeded, the available limit, and an optional suggested upgrade.
    case overMaximumPersonalLimit(EffectiveLimit, MoneyValue, TransactionValidationState.LimitsUpgrade?)

    case ux(UX.Error)

    // MARK: - Not checked

    case addressIsContract
    case invalidAddress
    case invalidPassword
    case optionInvalid
    case pendingOrdersLimitReached
    case transactionInFlight
    case sourceRequiresUpdate(String)
    case fatalError(FatalTransactionError)
}

extension TransactionErrorState {

    var isUX: Bool {
        switch self {
        case .ux:
            return true
        default:
            return false
        }
    }

    var isNone: Bool {
        self == .none
    }

    var label: String {
        Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }

    var fatalError: FatalTransactionError? {
        switch self {
        case .fatalError(let error):
            return error
        default:
            return nil
        }
    }
}

extension TransactionErrorState {

    func ux(action: AssetAction) -> UX.Error {
        if let error = extract(UX.Error.self, from: self) {
            return error
        }

        if let error = extract(Nabu.Error.self, from: self), error.ux.isNotNil {
            return UX.Error(nabu: error)
        }

        if let error = extract(NetworkError.self, from: self).map(Nabu.Error.from), error.ux.isNotNil {
            return UX.Error(nabu: error)
        }

        if let error = extract(OpenBanking.Error.self, from: self) {
            if let ob = BankState.UI.errors[error] {
                return UX.Error(
                    source: error,
                    id: error.code,
                    title: ob.info.title,
                    message: ob.info.subtitle,
                    icon: (ob.info.media.image?.url).map(UX.Icon.init(url:)),
                    metadata: error.code.map { ["code": $0] }.or([:])
                )
            } else {
                return UX.Error(
                    source: error,
                    id: error.code,
                    title: nil,
                    message: nil,
                    metadata: error.code.map { ["code": $0] }.or([:])
                )
            }
        }

        let error = extract(Nabu.Error.self, from: self).map(UX.Error.init(nabu:))
        return UX.Error(
            source: self,
            id: error?.id,
            title: recoveryWarningTitle(for: action),
            message: recoveryWarningMessage(for: action),
            metadata: error?.metadata ?? [:]
        )
    }
}
