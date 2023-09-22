//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Errors
import FeatureOpenBankingUI
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import SwiftUI
import ToolKit
import UIComponentsKit

extension TransactionValidationState {
    private typealias Localization = LocalizationConstants.Transaction.Error

    public var recoveryWarningHint: String? {
        let text: String
        switch self {
        case .insufficientFunds(_, _, let sourceCurrency, _):
            text = String.localizedStringWithFormat(
                Localization.insufficientFundsRecoveryHint,
                sourceCurrency.displayCode
            )
        case .belowFees(let fees, _):
            text = String.localizedStringWithFormat(
                Localization.insufficientFundsRecoveryHint,
                fees.displayCode
            )
        case .belowMinimumLimit(let minimum):
            text = String.localizedStringWithFormat(
                Localization.belowMinimumLimitRecoveryHint,
                minimum.shortDisplayString
            )
        case .overMaximumSourceLimit(let maximum, _, _):
            text = String.localizedStringWithFormat(
                Localization.overMaximumSourceLimitRecoveryHint,
                maximum.shortDisplayString
            )
        case .overMaximumPersonalLimit:
            text = Localization.overMaximumPersonalLimitRecoveryHint
        case .ux(let ux):
            text = ux.title

        // MARK: Unchecked

        case .addressIsContract:
            text = Localization.addressIsContractShort
        case .invalidAddress:
            text = Localization.invalidAddressShort
        case .optionInvalid:
            text = Localization.optionInvalidShort
        case .pendingOrdersLimitReached:
            text = Localization.pendingOrdersLimitReachedShort
        case .transactionInFlight:
            text = Localization.transactionInFlightShort
        case .unknownError:
            text = Localization.unknownErrorShort
        case .nabuError:
            text = Localization.nextworkErrorShort
        default:
            return nil
        }
        return text
    }
}
