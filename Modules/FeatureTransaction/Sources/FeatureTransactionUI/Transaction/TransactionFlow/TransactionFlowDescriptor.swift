// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit
import PlatformKit
import ToolKit

enum TransactionFlowDescriptor {

    private typealias LocalizedString = LocalizationConstants.Transaction

    enum EnterAmountScreen {

        private static func formatForHeader(moneyValue: MoneyValue) -> String {
            moneyValue.displayString
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
                return LocalizedString.Withdraw.availableToWithdrawTitle
            case .interestTransfer,
                 .interestWithdraw,
                 .stakingDeposit,
                 .activeRewardsDeposit,
                 .activeRewardsWithdraw:
                guard let account = state.source else {
                    return ""
                }
                return LocalizedString.from + ": \(account.label)"
            case .deposit:
                return LocalizedString.Deposit.dailyLimit
            case .buy:
                guard let source = state.source, let destination = state.destination else {
                    return LocalizedString.Buy.title
                }
                return "\(LocalizedString.Buy.title) \(destination.currencyType.displayCode) using \(source.label)"
            case .sell:
                return [
                    LocalizedString.Sell.headerTitlePrefix,
                    state.source?.label
                ].compactMap { $0 }.joined(separator: " ")
            case .sign,
                 .receive,
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
                return prefix + destination.label
            case .withdraw:
                return formatForHeader(moneyValue: state.maxSpendable)
            case .interestTransfer,
                    .interestWithdraw,
                    .stakingDeposit,
                    .activeRewardsDeposit,
                    .activeRewardsWithdraw:
                guard let destination = state.destination else {
                    return ""
                }
                guard let account = destination as? BlockchainAccount else {
                    return ""
                }
                return LocalizedString.to + ": \(account.label)"
            case .deposit:
                return state.maxDaily.displayString
            case .buy:
                let prefix = "\(LocalizedString.Buy.title):"
                guard let destination = state.destination else {
                    return prefix
                }
                return "\(prefix) \(destination.currencyType.displayCode) \(destination.label)"
            case .sell:
                return [
                    LocalizedString.Sell.headerSubtitlePrefix,
                    state.destination?.label
                ].compactMap { $0 }.joined(separator: " ")
            case .sign,
                 .receive,
                 .viewActivity:
                unimplemented()
            }
        }
    }

    enum AccountPicker {
        static func sourceTitle(action: AssetAction) -> String {
            switch action {
            case .swap:
                return LocalizedString.Swap.swapFrom
            case .deposit:
                return LocalizedString.Deposit.linkedBanks
            case .buy:
                return LocalizedString.Buy.selectSourceTitle
            case .sell:
                return LocalizedString.Sell.selectSourceTitle
            case .interestWithdraw, .activeRewardsWithdraw:
                return LocalizedString.Withdraw.withdrawTo
            case .interestTransfer, .stakingDeposit, .activeRewardsDeposit:
                return LocalizedString.Transfer.addFrom
            case .sign,
                 .receive,
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
            case .sell:
                return LocalizedString.Sell.selectSourceSubtitle
            case .sign,
                 .withdraw,
                 .deposit,
                 .receive,
                 .buy,
                 .send,
                 .viewActivity,
                 .interestWithdraw,
                 .interestTransfer,
                 .stakingDeposit,
                 .activeRewardsDeposit,
                 .activeRewardsWithdraw:
                return ""
            }
        }

        static func destinationTitle(action: AssetAction) -> String {
            switch action {
            case .swap:
                return LocalizedString.Swap.swapTo
            case .withdraw,
                 .interestWithdraw,
                 .activeRewardsWithdraw:
                return LocalizedString.Withdraw.withdrawTo
            case .buy:
                return LocalizedString.Buy.selectDestinationTitle
            case .sell:
                return LocalizedString.Sell.title
            case .interestTransfer, .stakingDeposit, .activeRewardsDeposit:
                return LocalizedString.Transfer.addFrom
            case .sign,
                 .deposit,
                 .receive,
                 .send,
                 .viewActivity:
                return ""
            }
        }

        static func destinationSubtitle(action: AssetAction) -> String {
            switch action {
            case .swap:
                return LocalizedString.Swap.destinationAccountPicketSubtitle
            case .sell:
                return LocalizedString.Sell.selectDestinationTitle
            case .sign,
                 .deposit,
                 .receive,
                 .buy,
                 .send,
                 .viewActivity,
                 .withdraw,
                 .interestWithdraw,
                 .interestTransfer,
                 .stakingDeposit,
                 .activeRewardsDeposit,
                 .activeRewardsWithdraw:
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
            case .withdraw,
                 .interestWithdraw,
                 .activeRewardsWithdraw:
                return LocalizedString.Withdraw.withdraw
            case .interestTransfer, .stakingDeposit, .activeRewardsDeposit:
                return LocalizedString.transfer
            case .sign,
                 .deposit,
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
        // Somtimes a `transfer` is referred to as `Add`.
        // This is to avoid confusion as a transfer and a withdraw
        // can sometimes sound the same to users. We do not always
        // call a transfer `Add` though so that's why we have
        // this if-statement.
        if action == .interestTransfer {
            return LocalizedString.add + " \(LocalizedString.max)"
        }
        return action.name + " \(LocalizedString.max)"
    }

    static func confirmDisclaimerVisibility(action: AssetAction) -> Bool {
        switch action {
        case .swap,
             .withdraw,
             .interestWithdraw,
             .deposit,
             .buy,
             .sell,
             .activeRewardsWithdraw:
            return true
        case .sign,
             .receive,
             .send,
             .viewActivity,
             .interestTransfer,
             .stakingDeposit,
             .activeRewardsDeposit:
            return false
        }
    }

    static func confirmDisclaimerText(
        action: AssetAction,
        currencyCode: String = "",
        accountLabel: String = "",
        isSafeConnect: Bool? = nil
    ) -> NSAttributedString {
        switch action {
        case .swap:
            return addRefundPolicyLink(LocalizedString.Swap.confirmationDisclaimer)
        case .sell:
            return addRefundPolicyLink(LocalizedString.Sell.confirmationDisclaimer)
        case .withdraw:
            return LocalizedString.Withdraw.confirmationDisclaimer.attributed
        case .buy:
            if isSafeConnect == true {
                return addSafeConnectTermsAndPolicyLink(
                    String(
                        format: LocalizedString.Buy.safeConnectConfirmationDisclaimer,
                        currencyCode,
                        LocalizedString.termsOfService,
                        LocalizedString.privacyPolicy
                    )
                )
            } else {
                return "".attributed
            }
        case .interestWithdraw, .activeRewardsWithdraw:
            return String(
                format: LocalizedString.InterestWithdraw.confirmationDisclaimer,
                currencyCode,
                accountLabel
            ).attributed
        case .deposit:
            if isSafeConnect == true {
                return addSafeConnectTermsAndPolicyLink(
                    String(
                        format: LocalizedString.Deposit.safeConnectConfirmationDisclaimer,
                        LocalizedString.termsOfService,
                        LocalizedString.privacyPolicy
                    )
                )
            } else {
                return "".attributed
            }
        case .sign,
             .receive,
             .send,
             .viewActivity,
             .interestTransfer,
             .stakingDeposit,
             .activeRewardsDeposit:
            return "".attributed
        }
    }

    private static func addRefundPolicyLink(_ string: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(
            string: String(
                format: string,
                LocalizedString.refundPolicy
            )
        )
        // swiftlint:disable:next line_length
        let refundPolicyLink = "https://support.blockchain.com/hc/en-us/articles/4417063009172-Will-I-be-refunded-if-my-Swap-or-Sell-from-a-Private-Key-Wallet-fails-"
        let refundPolicyRange = (attributedString.string as NSString).range(of: LocalizedString.refundPolicy)
        attributedString.addAttribute(.link, value: refundPolicyLink, range: refundPolicyRange)
        return attributedString
    }

    private static func addSafeConnectTermsAndPolicyLink(_ string: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string)

        let termsLink = "https://drive.google.com/file/d/11mNukqbBA_EbEBJd7bn9Idj1iiG8QWIL/view"
        let termsRange = (attributedString.string as NSString).range(of: LocalizedString.termsOfService)
        attributedString.addAttribute(.link, value: termsLink, range: termsRange)

        let privacyPolicyLink = "https://www.yapily.com/legal/privacy-policy/"
        let privacyPolicyRange = (attributedString.string as NSString).range(of: LocalizedString.privacyPolicy)
        attributedString.addAttribute(.link, value: privacyPolicyLink, range: privacyPolicyRange)

        return attributedString
    }

    static func confirmDisclaimerForBuy(paymentMethod: PaymentMethod?, lockDays: Int) -> String {
        switch lockDays {
        case 0:
            return [LocalizedString.Buy.confirmationDisclaimer, LocalizedString.Buy.noLockInfo].joined(separator: " ")
        default:
            let paymentMethodName = paymentMethod?.label ?? ""
            let lockDaysString = [
                "\(lockDays)",
                lockDays > 1 ? LocalizedString.Buy.days : LocalizedString.Buy.day
            ].joined(separator: " ")
            return [
                LocalizedString.Buy.confirmationDisclaimer,
                String(
                    format: LocalizedString.Buy.lockInfo,
                    paymentMethodName,
                    lockDaysString
                )
            ].joined(separator: " ")
        }
    }
}

extension String {
    var attributed: NSAttributedString {
        NSAttributedString(string: self)
    }
}
