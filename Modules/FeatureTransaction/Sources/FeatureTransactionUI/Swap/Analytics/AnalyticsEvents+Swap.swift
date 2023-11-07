// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import MoneyKit
import PlatformKit

extension AnalyticsEvents {
    public enum Swap: AnalyticsEvent {
        case verifyNowClicked
        case trendingPairClicked
        case newSwapClicked
        case fromPickerSeen
        case fromAccountSelected
        case toPickerSeen
        case swapTargetAddressSheet
        case swapEnterAmount
        case swapConfirmSeen
        case cancelTransaction
        case swapConfirmPair(asset: CurrencyType, target: String)
        case enterAmountCtaClick(source: CurrencyType, target: String)
        case swapConfirmCta(source: CurrencyType, target: String)
        case transactionSuccess(asset: CurrencyType, source: String, target: String)
        case transactionFailed(asset: CurrencyType, target: String?, source: String?)

        public var name: String {
            switch self {
            case .verifyNowClicked:
                "swap_kyc_verify_clicked"
            case .trendingPairClicked:
                "swap_suggested_pair_clicked"
            case .newSwapClicked:
                "swap_new_clicked"
            case .fromPickerSeen:
                "swap_from_picker_seen"
            case .fromAccountSelected:
                "swap_from_account_clicked"
            case .toPickerSeen:
                "swap_to_picker_seen"
            case .swapTargetAddressSheet:
                "swap_pair_locked_seen"
            case .swapEnterAmount:
                "swap_amount_screen_seen"
            case .swapConfirmSeen:
                "swap_checkout_shown"
            case .cancelTransaction:
                "swap_checkout_cancel"
            case .swapConfirmPair:
                "swap_pair_locked_confirm"
            case .enterAmountCtaClick:
                "swap_amount_screen_confirm"
            case .swapConfirmCta:
                "swap_checkout_confirm"
            case .transactionSuccess:
                "swap_checkout_success"
            case .transactionFailed:
                "swap_checkout_error"
            }
        }

        public var params: [String: String]? {
            switch self {
            case .swapConfirmPair(let asset, let target):
                return ["asset": asset.name, "target": target]
            case .enterAmountCtaClick(let source, let target):
                return ["source": source.name, "target": target]
            case .swapConfirmCta(let source, let target):
                return ["source": source.name, "target": target]
            case .transactionSuccess(let asset, let source, let target):
                return ["asset": asset.name, "source": source, "target": target]
            case .transactionFailed(let asset, let target, let source):
                guard let target, let source else {
                    return ["asset": asset.name]
                }
                return ["asset": asset.name, "target": target, "source": source]
            default:
                return [:]
            }
        }
    }
}
