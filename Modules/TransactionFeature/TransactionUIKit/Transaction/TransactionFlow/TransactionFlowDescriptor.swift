// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import ToolKit

final class TransactionFlowDescriptor {

    private typealias LocalizedString = LocalizationConstants.Transaction

    enum EnterAmountScreen {
        private static let cryptoFormatterProvider = CryptoFormatterProvider()
        private static func formatForHeader(moneyValue: MoneyValue) -> String {
            if let cryptoValue = moneyValue.cryptoValue {
                let formatter = cryptoFormatterProvider.formatter(
                    locale: .current,
                    cryptoCurrency: cryptoValue.currencyType,
                    minFractionDigits: 2
                )
                return formatter.format(value: cryptoValue,
                                        withPrecision: .short,
                                        includeSymbol: true)
            }
            return moneyValue.displayString
        }

        static func headerTitle(state: TransactionState) -> String {
            switch state.action {
            case .swap:
                let prefix = "\(LocalizedString.Swap.swap): "
                guard let moneyValue = try? state.moneyValueFromSource().get() else {
                    return prefix
                }
                return prefix + formatForHeader(moneyValue: moneyValue)
            case .send:
                let prefix = "\(LocalizedString.Send.from): "
                guard let source = state.source else {
                    return prefix
                }
                return prefix + source.label
            case .withdraw:
                guard let source = state.source as? FiatAccount else {
                    fatalError("Expected a FiatAccount")
                }
                return "\(source.fiatCurrency.code) " + LocalizedString.Withdraw.account
            case .deposit:
                return LocalizedString.Deposit.dailyLimit
            case .receive,
                 .buy,
                 .sell,
                 .viewActivity:
                unimplemented()
            }
        }

        static func headerSubtitle(state: TransactionState) -> String {
            switch state.action {
            case .swap:
                let prefix = "\(LocalizedString.receive): "
                guard let moneyValue = try? state.moneyValueFromDestination().get() else {
                    return prefix
                }
                return prefix + formatForHeader(moneyValue: moneyValue)
            case .send:
                let prefix = "\(LocalizedString.Send.to): "
                guard let destination = state.destination else {
                    return prefix
                }
                if let address = destination as? CryptoReceiveAddress {
                    return prefix + address.address
                }
                guard let account = destination as? BlockchainAccount else {
                    return prefix
                }
                return prefix + account.label
            case .withdraw:
                return formatForHeader(moneyValue: state.availableBalance)
            case .deposit:
                return "\(state.maxDaily.displayString)"
            case .receive,
                 .buy,
                 .sell,
                 .viewActivity:
                unimplemented()
            }
        }
    }

    enum AccountPicker {
        static func sourceTitle(action: AssetAction) -> String {
            switch action {
            case .swap:
                return LocalizedString.Swap.swap
            case .deposit:
                return LocalizedString.Deposit.linkedBanks
            case .receive,
                 .buy,
                 .sell,
                 .send,
                 .viewActivity,
                 .withdraw:
                return ""
            }
        }

        static func sourceSubtitle(action: AssetAction) -> String {
            switch action {
            case .swap:
                return LocalizedString.Swap.sourceAccountPicketSubtitle
            case .withdraw,
                 .deposit,
                 .receive,
                 .buy,
                 .sell,
                 .send,
                 .viewActivity:
                return ""
            }
        }

        static func destinationTitle(action: AssetAction) -> String {
            switch action {
            case .swap:
                return LocalizedString.receive
            case .withdraw:
                return LocalizedString.Withdraw.withdrawTo
            case .deposit,
                 .receive,
                 .buy,
                 .sell,
                 .send,
                 .viewActivity:
                return ""
            }
        }

        static func destinationSubtitle(action: AssetAction) -> String {
            switch action {
            case .swap:
                return LocalizedString.Swap.destinationAccountPicketSubtitle
            case .deposit,
                 .receive,
                 .buy,
                 .sell,
                 .send,
                 .viewActivity,
                 .withdraw:
                return ""
            }
        }
    }

    enum TargetSelection {
        static func navigationTitle(action: AssetAction) -> String {
            switch action {
            case .swap:
                return LocalizedString.newSwap
            case .send:
                return LocalizedString.Send.send
            case .withdraw:
                return LocalizedString.Withdraw.withdraw
            case .deposit,
                 .receive,
                 .buy,
                 .sell,
                 .viewActivity:
                unimplemented()
            }
        }
    }

    static let networkFee = LocalizedString.networkFee
    static let availableBalanceTitle = LocalizedString.available
    static let maxButtonTitle = LocalizedString.Swap.swapMax

    static func maxButtonTitle(action: AssetAction) -> String {
        action.name + " \(LocalizedString.max)"
    }

    static func confirmDisclaimerVisibility(action: AssetAction) -> Bool {
        switch action {
        case .swap,
             .withdraw:
            return true
        case .deposit,
             .receive,
             .buy,
             .sell,
             .send,
             .viewActivity:
            return false
        }
    }

    static func confirmDisclaimerText(action: AssetAction) -> String {
        switch action {
        case .swap:
            return LocalizedString.Swap.confirmationDisclaimer
        case .withdraw:
            return LocalizedString.Withdraw.confirmationDisclaimer
        case .deposit,
             .receive,
             .buy,
             .sell,
             .send,
             .viewActivity:
            return ""
        }
    }
}
