// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import FeatureOpenBankingUI
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import SwiftUI
import ToolKit
import UIComponentsKit

extension TransactionErrorState {

    private typealias Localization = LocalizationConstants.Transaction.Error

    public var recoveryWarningHint: String {
        let text: String = switch self {
        case .none:
            "" // no error
        case .insufficientFunds(_, _, let sourceCurrency, _):
            String.localizedStringWithFormat(
                Localization.insufficientFundsRecoveryHint,
                sourceCurrency.displayCode
            )
        case .belowFees(let fees, _):
            String.localizedStringWithFormat(
                Localization.insufficientFundsRecoveryHint,
                fees.displayCode
            )
        case .belowMinimumLimit(let minimum):
            String.localizedStringWithFormat(
                Localization.belowMinimumLimitRecoveryHint,
                minimum.displayString
            )
        case .overMaximumSourceLimit(let maximum, _, _):
            String.localizedStringWithFormat(
                Localization.overMaximumSourceLimitRecoveryHint,
                maximum.shortDisplayString
            )
        case .overMaximumPersonalLimit:
            Localization.overMaximumPersonalLimitRecoveryHint
        case .ux(let ux):
            ux.title

        // MARK: Unchecked

        case .addressIsContract:
            Localization.addressIsContractShort
        case .invalidAddress:
            Localization.invalidAddressShort
        case .invalidPassword:
            Localization.invalidPasswordShort
        case .optionInvalid:
            Localization.optionInvalidShort
        case .pendingOrdersLimitReached:
            Localization.pendingOrdersLimitReachedShort
        case .transactionInFlight:
            Localization.transactionInFlightShort
        case .unknownError:
            Localization.unknownErrorShort
        case .fatalError:
            Localization.fatalErrorShort
        case .nabuError:
            Localization.nextworkErrorShort
        case .sourceRequiresUpdate:
            ""
        }
        return text
    }

    // swiftlint:disable cyclomatic_complexity
    func recoveryWarningTitle(for action: AssetAction) -> String? {
        switch self {
        case .fatalError(.generic(let genericError)):
            switch genericError {
            case let error as OpenBanking.Error:
                let ui = BankState.UI.errors[error, default: BankState.UI.defaultError]
                return ui.info.title
            case OrderConfirmationServiceError.nabu(let error):
                return transactionErrorTitle(
                    for: error.code,
                    action: action
                ) ?? Localization.nextworkErrorShort
            case let error as NabuNetworkError:
                return transactionErrorTitle(
                    for: error.code,
                    action: action
                ) ?? Localization.nextworkErrorShort
            case let error as TransactionValidationFailure:
                return error.title(action)
            default:
                return nil
            }
        case .fatalError(.message), .fatalError(.rxError):
            return nil
        case .nabuError(let error):
            return transactionErrorTitle(
                for: error.code,
                action: action
            ) ?? Localization.nextworkErrorShort
        case .insufficientFunds(let balance, _, _, _) where action == .swap:
            return String.localizedStringWithFormat(
                Localization.insufficientFundsRecoveryTitle_swap,
                balance.displayString
            )
        case .insufficientFunds(_, _, let sourceCurrency, _):
            return String.localizedStringWithFormat(
                Localization.insufficientFundsRecoveryTitle,
                sourceCurrency.displayCode
            )
        case .belowFees(let fees, let balance):
            return String.localizedStringWithFormat(
                Localization.belowMinimumLimitRecoveryTitle,
                fees.shortDisplayString,
                balance.shortDisplayString
            )
        case .ux(let error):
            return error.title
        case .belowMinimumLimit(let minimum):
            return String.localizedStringWithFormat(
                Localization.belowMinimumLimitRecoveryTitle,
                minimum.displayString
            )
        case .overMaximumSourceLimit(let availableAmount, _, _) where action == .send:
            return String.localizedStringWithFormat(
                Localization.insufficientFundsRecoveryTitle,
                availableAmount.currencyType.displayCode
            )
        case .overMaximumSourceLimit(let maximum, _, _):
            return String.localizedStringWithFormat(
                Localization.overMaximumSourceLimitRecoveryTitle,
                maximum.shortDisplayString
            )
        case .overMaximumPersonalLimit:
            return Localization.overMaximumPersonalLimitRecoveryTitle
        case .none:
            if BuildFlag.isInternal {
                Logger.shared.error("Unsupported API error thrown or an internal error thrown")
            }
            return nil
        case .addressIsContract:
            return Localization.addressIsContract
        case .invalidAddress:
            return Localization.invalidAddress
        case .invalidPassword:
            return Localization.invalidPassword
        case .optionInvalid:
            return Localization.optionInvalid
        case .pendingOrdersLimitReached:
            return Localization.pendingOrderLimitReached
        case .transactionInFlight:
            return Localization.transactionInFlight
        case .unknownError:
            return nil
        case .sourceRequiresUpdate:
            return nil
        }
    }

    func recoveryWarningMessage(for action: AssetAction) -> String {
        let text: String = switch self {
        case .belowFees(let fee, let balance):
            String.localizedStringWithFormat(
                Localization.insuffientFundsToPayForFeesMessage,
                balance.currencyType.displayCode,
                fee.shortDisplayString,
                NonLocalizedConstants.defiWalletTitle,
                balance.currencyType.name
            )
        case .insufficientFunds:
            localizedInsufficientFundsMessage(action: action)
        case .belowMinimumLimit:
            localizedBelowMinimumLimitMessage(action: action)
        case .overMaximumSourceLimit:
            localizedOverMaxSourceLimitMessage(action: action)
        case .overMaximumPersonalLimit:
            localizedOverMaxPersonalLimitMessage(action: action)
        case .nabuError(let error):
            transactionErrorDescription(for: error.code, action: action)
                ?? error.description
                ?? Localization.unknownErrorDescription
        case .fatalError(let fatalTransactionError):
            transactionErrorDescription(for: fatalTransactionError, action: action)
        case .unknownError:
            Localization.unknownErrorDescription
        default:
            String(describing: self)
        }
        return text
    }

    func recoveryWarningCallouts(for action: AssetAction) -> [ErrorRecoveryState.Callout] {
        switch self {
        case .belowFees(let fees, let balance) where action == .send:
            let currency = fees.currency
            guard currency.cryptoCurrency?.supports(product: .custodialWalletBalance) == true else {
                return []
            }
            return [
                ErrorRecoveryState.Callout(
                    id: ErrorRecoveryCalloutIdentifier.buy.rawValue,
                    image: currency.logoResource,
                    title: String.localizedStringWithFormat(
                        Localization.belowFeesRecoveryCalloutTitle_send,
                        currency.displayCode
                    ),
                    message: String.localizedStringWithFormat(
                        Localization.belowFeesRecoveryCalloutMessage_send,
                        balance.displayString
                    ),
                    callToAction: Localization.belowFeesRecoveryCalloutCTA_send
                )
            ]
        case .insufficientFunds(_, let desiredAmount, let sourceCurrency, let targetCurrency) where action == .send:
            guard sourceCurrency.cryptoCurrency?.supports(product: .custodialWalletBalance) == true else {
                return []
            }
            let displayCode = sourceCurrency.displayCode
            let displayString = desiredAmount.displayString
            return [
                ErrorRecoveryState.Callout(
                    id: ErrorRecoveryCalloutIdentifier.buy.rawValue,
                    image: targetCurrency.logoResource,
                    title: Localization.overMaximumSourceLimitRecoveryCalloutTitle_send
                        .interpolating(displayCode),
                    message: Localization.overMaximumSourceLimitRecoveryCalloutMessage_send
                        .interpolating(displayString),
                    callToAction: Localization.overMaximumSourceLimitRecoveryCalloutCTA_send
                )
            ]
        case .overMaximumSourceLimit(let availableAmount, _, let desiredAmount) where action == .send:
            let currency = availableAmount.currency
            guard currency.cryptoCurrency?.supports(product: .custodialWalletBalance) == true else {
                return []
            }
            let displayCode = currency.displayCode
            let desiredString = desiredAmount.displayString
            return [
                ErrorRecoveryState.Callout(
                    id: ErrorRecoveryCalloutIdentifier.buy.rawValue,
                    image: availableAmount.currency.logoResource,
                    title: Localization.overMaximumSourceLimitRecoveryCalloutTitle_send
                        .interpolating(displayCode),
                    message: Localization.overMaximumSourceLimitRecoveryCalloutMessage_send
                        .interpolating(desiredString),
                    callToAction: Localization.overMaximumSourceLimitRecoveryCalloutCTA_send
                )
            ]
        case .overMaximumPersonalLimit(_, _, let suggestedUpgrade):
            let calloutTitle: String = switch action {
            case .buy:
                Localization.overMaximumPersonalLimitRecoveryCalloutTitle_buy
            case .swap:
                Localization.overMaximumPersonalLimitRecoveryCalloutTitle_swap
            case .send:
                Localization.overMaximumPersonalLimitRecoveryCalloutTitle_send
            default:
                Localization.overMaximumPersonalLimitRecoveryCalloutTitle_other
            }
            return suggestedUpgrade == nil ? [] : [
                ErrorRecoveryState.Callout(
                    id: ErrorRecoveryCalloutIdentifier.upgradeKYCTier.rawValue,
                    image: .local(name: "kyc-gold", bundle: .main),
                    title: calloutTitle,
                    message: Localization.overMaximumPersonalLimitRecoveryCalloutMessage,
                    callToAction: Localization.overMaximumPersonalLimitRecoveryCalloutCTA
                )
            ]
        default:
            return []
        }
    }
}

// MARK: - Helpers

extension TransactionErrorState {

    private func transactionErrorDescription(for networkError: NabuNetworkError, action: AssetAction) -> String {
        transactionErrorDescription(for: networkError.code, action: action)
            ?? networkError.description
            ?? Localization.unknownErrorDescription
    }

    private func transactionErrorDescription(for fatalError: FatalTransactionError, action: AssetAction) -> String {
        let errorDescription: String
        switch fatalError {
        case .generic(let error):
            if let error = error as? OpenBanking.Error {
                let ui = BankState.UI.errors[error, default: BankState.UI.defaultError]
                errorDescription = ui.info.subtitle
            } else if let error = error as? OrderConfirmationServiceError, case .nabu(let nabu) = error {
                errorDescription = transactionErrorDescription(for: nabu, action: action)
            } else if let networkError = error as? NabuNetworkError {
                errorDescription = transactionErrorDescription(for: networkError, action: action)
            } else if let validationError = error as? TransactionValidationFailure {
                errorDescription = validationError.message(action)
            } else {
                errorDescription = Localization.unknownErrorDescription
            }

        default:
            errorDescription = fatalError.localizedDescription
        }
        return errorDescription
    }

    private func transactionErrorTitle(for code: NabuErrorCode, action: AssetAction) -> String? {
        switch code {
        case .cardInsufficientFunds:
            Localization.cardInsufficientFundsTitle
        case .cardBankDecline:
            Localization.cardBankDeclineTitle
        case .cardCreateBankDeclined:
            Localization.cardCreateBankDeclinedTitle
        case .cardDuplicate:
            Localization.cardDuplicateTitle
        case .cardBlockchainDecline:
            Localization.cardBlockchainDeclineTitle
        case .cardAcquirerDecline:
            Localization.cardAcquirerDeclineTitle
        case .cardPaymentNotSupported:
            Localization.cardUnsupportedPaymentMethodTitle
        case .cardCreateFailed:
            Localization.cardCreateFailedTitle
        case .cardPaymentFailed:
            Localization.cardPaymentFailedTitle
        case .cardCreateAbandoned:
            Localization.cardCreateAbandonedTitle
        case .cardCreateExpired:
            Localization.cardCreateExpiredTitle
        case .cardCreateDebitOnly:
            Localization.cardCreateDebitOnlyTitle
        case .cardPaymentDebitOnly:
            Localization.cardPaymentDebitOnlyTitle
        case .cardCreateNoToken:
            Localization.cardCreateNoTokenTitle
        default:
            nil
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func transactionErrorDescription(for code: NabuErrorCode, action: AssetAction) -> String? {
        switch code {
        case .notFound:
            Localization.notFound
        case .orderBelowMinLimit:
            String(format: Localization.tradingBelowMin, action.name)
        case .orderAboveMaxLimit:
            String(format: Localization.tradingAboveMax, action.name)
        case .dailyLimitExceeded:
            String(format: Localization.tradingDailyExceeded, action.name)
        case .weeklyLimitExceeded:
            String(format: Localization.tradingWeeklyExceeded, action.name)
        case .annualLimitExceeded:
            String(format: Localization.tradingYearlyExceeded, action.name)
        case .tradingDisabled:
            Localization.tradingServiceDisabled
        case .pendingOrdersLimitReached:
            Localization.pendingOrderLimitReached
        case .invalidCryptoAddress:
            Localization.tradingInvalidAddress
        case .invalidCryptoCurrency:
            Localization.tradingInvalidCurrency
        case .invalidFiatCurrency:
            Localization.tradingInvalidFiat
        case .orderDirectionDisabled:
            Localization.tradingDirectionDisabled
        case .userNotEligibleForSwap:
            Localization.tradingIneligibleForSwap
        case .invalidDestinationAddress:
            Localization.tradingInvalidAddress
        case .notFoundCustodialQuote:
            Localization.tradingQuoteInvalidOrExpired
        case .orderAmountNegative:
            Localization.tradingInvalidDestinationAmount
        case .withdrawalForbidden:
            Localization.pendingWithdraw
        case .withdrawalLocked:
            Localization.withdrawBalanceLocked
        case .insufficientBalance:
            String(format: Localization.tradingInsufficientBalance, action.name)
        case .albertExecutionError:
            Localization.tradingAlbertError
        case .orderInProgress:
            String(format: Localization.tooManyTransaction, action.name)
        case .cardInsufficientFunds:
            Localization.cardInsufficientFunds
        case .cardBankDecline:
            Localization.cardBankDecline
        case .cardCreateBankDeclined:
            Localization.cardCreateBankDeclined
        case .cardDuplicate:
            Localization.cardDuplicate
        case .cardBlockchainDecline:
            Localization.cardBlockchainDecline
        case .cardAcquirerDecline:
            Localization.cardAcquirerDecline
        case .cardPaymentNotSupported:
            Localization.cardUnsupportedPaymentMethod
        case .cardCreateFailed:
            Localization.cardCreateFailed
        case .cardPaymentFailed:
            Localization.cardPaymentFailed
        case .cardCreateAbandoned:
            Localization.cardCreateAbandoned
        case .cardCreateExpired:
            Localization.cardCreateExpired
        case .cardCreateBankDeclined:
            Localization.cardCreateBankDeclined
        case .cardCreateDebitOnly:
            Localization.cardCreateDebitOnly
        case .cardPaymentDebitOnly:
            Localization.cardPaymentDebitOnly
        case .cardCreateNoToken:
            Localization.cardCreateNoToken
        default:
            nil
        }
    }

    private func localizedInsufficientFundsMessage(action: AssetAction) -> String {
        guard case .insufficientFunds(let balance, _, let sourceCurrency, let targetCurrency) = self else {
            impossible("Developer error")
        }
        let text: String
        switch action {
        case .buy:
            text = String.localizedStringWithFormat(
                Localization.insufficientFundsRecoveryMessage_buy,
                targetCurrency.displayCode,
                sourceCurrency.displayCode,
                balance.displayString
            )
        case .sell:
            text = String.localizedStringWithFormat(
                Localization.insufficientFundsRecoveryMessage_sell,
                sourceCurrency.displayCode,
                balance.displayString
            )
        case .swap:
            text = String.localizedStringWithFormat(
                Localization.insufficientFundsRecoveryMessage_swap,
                sourceCurrency.displayCode,
                targetCurrency.displayCode,
                balance.displayString
            )
        case .send,
             .interestTransfer,
             .stakingDeposit,
             .activeRewardsDeposit:
            text = String.localizedStringWithFormat(
                Localization.insufficientFundsRecoveryMessage_send,
                sourceCurrency.displayCode,
                balance.displayString
            )
        case .withdraw,
             .interestWithdraw,
             .stakingWithdraw,
             .activeRewardsWithdraw:
            text = String.localizedStringWithFormat(
                Localization.insufficientFundsRecoveryMessage_withdraw,
                sourceCurrency.displayCode,
                balance.displayString
            )
        case .receive,
             .deposit,
             .sign,
             .viewActivity:
            impossible("This message should not be needed for \(action)")
        }
        return text
    }

    private func localizedBelowMinimumLimitMessage(action: AssetAction) -> String {
        guard case .belowMinimumLimit(let minimum) = self else {
            impossible("Developer error")
        }
        let text: String
        switch action {
        case .buy:
            text = String.localizedStringWithFormat(
                Localization.belowMinimumLimitRecoveryMessage_buy,
                minimum.displayString
            )
        case .sell:
            text = String.localizedStringWithFormat(
                Localization.belowMinimumLimitRecoveryMessage_sell,
                minimum.displayString
            )
        case .swap:
            text = String.localizedStringWithFormat(
                Localization.belowMinimumLimitRecoveryMessage_swap,
                minimum.displayString
            )
        case .send,
                .interestTransfer,
                .stakingDeposit,
                .activeRewardsDeposit:
            text = String.localizedStringWithFormat(
                Localization.belowMinimumLimitRecoveryMessage_send,
                minimum.displayString
            )
        case .deposit:
            text = String.localizedStringWithFormat(
                Localization.belowMinimumLimitRecoveryMessage_deposit,
                minimum.displayString
            )
        case .withdraw,
             .interestWithdraw,
             .stakingWithdraw,
             .activeRewardsWithdraw:
            text = String.localizedStringWithFormat(
                Localization.belowMinimumLimitRecoveryMessage_withdraw,
                minimum.displayString
            )
        case .receive,
             .sign,
             .viewActivity:
            impossible("This message should not be needed for \(action)")
        }
        return text
    }

    private func localizedOverMaxSourceLimitMessage(action: AssetAction) -> String {
        guard case .overMaximumSourceLimit(let availableAmount, let accountLabel, let desiredAmount) = self else {
            impossible("Developer error")
        }
        let text: String
        switch action {
        case .buy:
            let format: String = if accountLabel.contains(availableAmount.displayCode) {
                Localization.overMaximumSourceLimitRecoveryMessage_buy_funds
            } else {
                Localization.overMaximumSourceLimitRecoveryMessage_buy
            }
            text = String.localizedStringWithFormat(
                format,
                accountLabel,
                availableAmount.shortDisplayString,
                desiredAmount.shortDisplayString
            )
        case .sell:
            text = String.localizedStringWithFormat(
                Localization.overMaximumSourceLimitRecoveryMessage_sell,
                availableAmount.shortDisplayString,
                desiredAmount.shortDisplayString
            )
        case .swap:
            text = String.localizedStringWithFormat(
                Localization.overMaximumSourceLimitRecoveryMessage_swap,
                availableAmount.shortDisplayString,
                desiredAmount.shortDisplayString
            )
        case .send:
            text = String.localizedStringWithFormat(
                Localization.overMaximumSourceLimitRecoveryMessage_send,
                availableAmount.shortDisplayString,
                desiredAmount.shortDisplayString
            )
        case .deposit:
            text = String.localizedStringWithFormat(
                Localization.overMaximumSourceLimitRecoveryMessage_deposit,
                accountLabel,
                availableAmount.shortDisplayString,
                desiredAmount.shortDisplayString
            )
        case .withdraw:
            text = String.localizedStringWithFormat(
                Localization.overMaximumSourceLimitRecoveryMessage_withdraw,
                availableAmount.shortDisplayString,
                desiredAmount.shortDisplayString
            )
        case .receive,
             .interestTransfer,
             .interestWithdraw,
             .stakingWithdraw,
             .stakingDeposit,
             .sign,
             .viewActivity,
             .activeRewardsDeposit,
             .activeRewardsWithdraw:
            impossible("This message should not be needed for \(action)")
        }
        return text
    }

    private func localizedOverMaxPersonalLimitMessage(action: AssetAction) -> String {
        guard case .overMaximumPersonalLimit(let limit, let available, let suggestedUpgrade) = self else {
            impossible("Developer error")
        }
        let text: String
        switch action {
        case .buy:
            text = localizedOverMaxPersonalLimitMessageForBuy(
                effectiveLimit: limit,
                availableAmount: available,
                suggestedUpgrade: suggestedUpgrade
            )
        case .sell:
            text = localizedOverMaxPersonalLimitMessageForSell(
                effectiveLimit: limit,
                availableAmount: available,
                suggestedUpgrade: suggestedUpgrade
            )
        case .swap:
            text = localizedOverMaxPersonalLimitMessageForSwap(
                effectiveLimit: limit,
                availableAmount: available,
                suggestedUpgrade: suggestedUpgrade
            )
        case .send:
            text = localizedOverMaxPersonalLimitMessageForSend(
                effectiveLimit: limit,
                availableAmount: available,
                suggestedUpgrade: suggestedUpgrade
            )
        case .withdraw:
            text = localizedOverMaxPersonalLimitMessageForWithdraw(
                effectiveLimit: limit,
                availableAmount: available
            )
        case .receive,
             .deposit,
             .interestTransfer,
             .stakingDeposit,
             .stakingWithdraw,
             .interestWithdraw,
             .sign,
             .viewActivity,
             .activeRewardsDeposit,
             .activeRewardsWithdraw:
            impossible("This message should not be needed for \(action)")
        }
        return text
    }

    private func localizedOverMaxPersonalLimitMessageForBuy(
        effectiveLimit: EffectiveLimit,
        availableAmount: MoneyValue,
        suggestedUpgrade: TransactionValidationState.LimitsUpgrade?
    ) -> String {
        let format: String = if effectiveLimit.timeframe == .single {
            Localization.overMaximumPersonalLimitRecoveryMessage_buy_single
        } else if suggestedUpgrade?.requiresVerified == true {
            Localization.overMaximumPersonalLimitRecoveryMessage_buy_gold
        } else {
            Localization.overMaximumPersonalLimitRecoveryMessage_buy_other
        }
        return String.localizedStringWithFormat(
            format,
            localized(effectiveLimit, availableAmount: availableAmount),
            availableAmount.displayString
        )
    }

    private func localizedOverMaxPersonalLimitMessageForSell(
        effectiveLimit: EffectiveLimit,
        availableAmount: MoneyValue,
        suggestedUpgrade: TransactionValidationState.LimitsUpgrade?
    ) -> String {
        let format: String = if effectiveLimit.timeframe == .single {
            Localization.overMaximumPersonalLimitRecoveryMessage_sell_single
        } else if suggestedUpgrade?.requiresVerified == true {
            Localization.overMaximumPersonalLimitRecoveryMessage_sell_gold
        } else {
            Localization.overMaximumPersonalLimitRecoveryMessage_sell_other
        }
        return String.localizedStringWithFormat(
            format,
            localized(effectiveLimit, availableAmount: availableAmount),
            availableAmount.displayString
        )
    }

    private func localizedOverMaxPersonalLimitMessageForSwap(
        effectiveLimit: EffectiveLimit,
        availableAmount: MoneyValue,
        suggestedUpgrade: TransactionValidationState.LimitsUpgrade?
    ) -> String {
        let format: String = if effectiveLimit.timeframe == .single {
            Localization.overMaximumPersonalLimitRecoveryMessage_swap_single
        } else if suggestedUpgrade?.requiresVerified == true {
            Localization.overMaximumPersonalLimitRecoveryMessage_swap_gold
        } else {
            Localization.overMaximumPersonalLimitRecoveryMessage_swap_other
        }
        return String.localizedStringWithFormat(
            format,
            localized(effectiveLimit, availableAmount: availableAmount),
            availableAmount.displayString
        )
    }

    private func localizedOverMaxPersonalLimitMessageForSend(
        effectiveLimit: EffectiveLimit,
        availableAmount: MoneyValue,
        suggestedUpgrade: TransactionValidationState.LimitsUpgrade?
    ) -> String {
        let format: String = if effectiveLimit.timeframe == .single {
            Localization.overMaximumPersonalLimitRecoveryMessage_send_single
        } else if suggestedUpgrade?.requiresVerified == true {
            Localization.overMaximumPersonalLimitRecoveryMessage_send_gold
        } else {
            Localization.overMaximumPersonalLimitRecoveryMessage_send_other
        }
        return String.localizedStringWithFormat(
            format,
            localized(effectiveLimit, availableAmount: availableAmount),
            availableAmount.displayString
        )
    }

    private func localizedOverMaxPersonalLimitMessageForWithdraw(
        effectiveLimit: EffectiveLimit,
        availableAmount: MoneyValue
    ) -> String {
        String.localizedStringWithFormat(
            Localization.overMaximumPersonalLimitRecoveryMessage_withdraw,
            localized(effectiveLimit, availableAmount: availableAmount),
            availableAmount.displayString
        )
    }

    private func localized(_ effectiveLimit: EffectiveLimit, availableAmount: MoneyValue) -> String {
        let localizedEffectiveLimit: String = switch effectiveLimit.timeframe {
        case .daily:
            String.localizedStringWithFormat(
                Localization.overMaximumSourceLimitRecoveryValueTimeFrameDay,
                effectiveLimit.value.shortDisplayString
            )
        case .monthly:
            String.localizedStringWithFormat(
                Localization.overMaximumSourceLimitRecoveryValueTimeFrameMonth,
                effectiveLimit.value.shortDisplayString
            )
        case .yearly:
            String.localizedStringWithFormat(
                Localization.overMaximumSourceLimitRecoveryValueTimeFrameYear,
                effectiveLimit.value.shortDisplayString
            )
        case .single:
            availableAmount.shortDisplayString
        }
        return localizedEffectiveLimit
    }
}

enum ErrorRecoveryCalloutIdentifier: String {
    case buy
    case upgradeKYCTier
}

extension TransactionValidationFailure {

    func title(_ action: AssetAction) -> String? {
        switch state {
        case .noSourcesAvailable:
            LocalizationConstants.Errors.noSourcesAvailable.interpolating(action.localizedName)
        case .insufficientInterestWithdrawalBalance:
            LocalizationConstants.Errors.insufficientInterestWithdrawalBalance
        default:
            state.mapToTransactionErrorState.recoveryWarningTitle(for: action)
        }
    }

    func message(_ action: AssetAction) -> String {
        switch state {
        case .noSourcesAvailable:
            LocalizationConstants.Errors.noSourcesAvailableMessage.interpolating(action.localizedName)
        case .insufficientInterestWithdrawalBalance:
            LocalizationConstants.Errors.insufficientInterestWithdrawalBalanceMessage
        default:
            state.mapToTransactionErrorState.recoveryWarningMessage(for: action)
        }
    }
}

extension AssetAction {

    var localizedName: String {
        switch self {
        case .buy:
            LocalizationConstants.WalletAction.Default.Buy.title
        case .deposit, .stakingDeposit, .activeRewardsDeposit:
            LocalizationConstants.WalletAction.Default.Deposit.title
        case .interestTransfer:
            LocalizationConstants.WalletAction.Default.Interest.title
        case .interestWithdraw:
            LocalizationConstants.WalletAction.Default.Interest.title
        case .receive:
            LocalizationConstants.WalletAction.Default.Receive.title
        case .sell:
            LocalizationConstants.WalletAction.Default.Sell.title
        case .send:
            LocalizationConstants.WalletAction.Default.Send.title
        case .sign:
            LocalizationConstants.WalletAction.Default.Sign.title
        case .swap:
            LocalizationConstants.WalletAction.Default.Swap.title
        case .viewActivity:
            LocalizationConstants.WalletAction.Default.Activity.title
        case .withdraw, .activeRewardsWithdraw, .stakingWithdraw:
            LocalizationConstants.WalletAction.Default.Withdraw.title
        }
    }
}
