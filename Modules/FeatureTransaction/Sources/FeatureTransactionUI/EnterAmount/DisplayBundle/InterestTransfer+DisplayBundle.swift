// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

private struct InterestTransferAnalyticsEvent: AnalyticsEvent {
    var name: String = ""
}

extension DisplayBundle {

    static func interestTransfer(sourceAccount: SingleAccount) -> DisplayBundle {
        typealias LocalizedString = LocalizationConstants.Interest.Screen.EnterAmount.Transfer
        let code = sourceAccount.currencyType.displayCode
        return DisplayBundle(
            title: LocalizedString.title + " \(code)",
            amountDisplayBundle: .init(
                events: .init(
                    min: InterestTransferAnalyticsEvent(),
                    max: InterestTransferAnalyticsEvent()
                ),
                strings: .init(
                    useMin: LocalizedString.useMin,
                    useMax: LocalizedString.useMax
                ),
                accessibilityIdentifiers: .init()
            )
        )
    }
}

extension DisplayBundle {

    static func stakingDeposit(sourceAccount: SingleAccount) -> DisplayBundle {
        typealias LocalizedString = LocalizationConstants.Interest.Screen.EnterAmount.Transfer
        let code = sourceAccount.currencyType.displayCode
        return DisplayBundle(
            title: LocalizedString.title + " \(code)",
            amountDisplayBundle: .init(
                events: .init(
                    min: InterestTransferAnalyticsEvent(),
                    max: InterestTransferAnalyticsEvent()
                ),
                strings: .init(
                    useMin: LocalizedString.useMin,
                    useMax: LocalizedString.useMax
                ),
                accessibilityIdentifiers: .init()
            )
        )
    }
}

extension DisplayBundle {

    static func activeRewardsDeposit(sourceAccount: SingleAccount) -> DisplayBundle {
        typealias LocalizedString = LocalizationConstants.Interest.Screen.EnterAmount.Transfer
        let code = sourceAccount.currencyType.displayCode
        return DisplayBundle(
            title: LocalizedString.title + " \(code)",
            amountDisplayBundle: .init(
                events: .init(
                    min: InterestTransferAnalyticsEvent(),
                    max: InterestTransferAnalyticsEvent()
                ),
                strings: .init(
                    useMin: LocalizedString.useMin,
                    useMax: LocalizedString.useMax
                ),
                accessibilityIdentifiers: .init()
            )
        )
    }
}

extension DisplayBundle {

    static func activeRewardsWithdraw(sourceAccount: SingleAccount) -> DisplayBundle {
        typealias LocalizedString = LocalizationConstants.Interest.Screen.EnterAmount.Transfer
        let code = sourceAccount.currencyType.displayCode
        return DisplayBundle(
            title: LocalizedString.title + " \(code)",
            amountDisplayBundle: .init(
                events: .init(
                    min: InterestTransferAnalyticsEvent(),
                    max: InterestTransferAnalyticsEvent()
                ),
                strings: .init(
                    useMin: LocalizedString.useMin,
                    useMax: LocalizedString.useMax
                ),
                accessibilityIdentifiers: .init()
            )
        )
    }
}
