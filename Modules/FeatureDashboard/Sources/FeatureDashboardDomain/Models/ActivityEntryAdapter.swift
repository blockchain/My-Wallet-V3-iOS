// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureStakingDomain
import Foundation
import Localization
import PlatformKit
import ToolKit
import UnifiedActivityDomain

public enum ActivityEntryAdapter {

    public static func createEntry(with activity: CustodialActivityEvent.Fiat) -> ActivityEntry {
        let compositionView = ActivityItem.CompositionView(
            leadingImage: activity.leadingImage(),
            leading: [activity.leadingLabel1(), activity.leadingLabel2()],
            trailing: [activity.trailingLabel1()]
        )

        let entry = ActivityEntry(
            id: activity.identifier,
            type: .fiatOrder,
            network: activity.amount.code,
            pubKey: "",
            externalUrl: "",
            item: compositionView,
            state: activity.state.toActivityState(),
            timestamp: activity.date.timeIntervalSince1970,
            transactionType: .init(rawValue: activity.type.rawValue)
        )
        return entry
    }

    public static func createEntry(with activity: CustodialActivityEvent.Crypto) -> ActivityEntry {
        let compositionView = ActivityItem.CompositionView(
            leadingImage: activity.leadingImage(),
            leading: [activity.leadingLabel1(), activity.leadingLabel2()],
            trailing: [activity.trailingLabel1(), activity.trailingLabel2()]
        )

        let entry = ActivityEntry(
            id: activity.identifier,
            type: .cryptoOrder,
            network: activity.amount.code,
            pubKey: "",
            externalUrl: "",
            item: compositionView,
            state: activity.state.toActivityState(),
            timestamp: activity.date.timeIntervalSince1970,
            transactionType: .init(rawValue: activity.type.rawValue)
        )
        return entry
    }

    /// Some sell activities originate from a swap,
    /// the parameter `originFromSwap` alters the type to a swap so that details can be retrieved
    public static func createEntry(
        with activity: BuySellActivityItemEvent,
        originFromSwap: Bool = false,
        networkFromSwap: String? = nil
    ) -> ActivityEntry {
        let compositionView = ActivityItem.CompositionView(
            leadingImage: activity.leadingImage(),
            leading: [
                activity.leadingLabel1(),
                activity.leadingLabel2()
            ],
            trailing: [
                activity.trailingLabel1(),
                activity.trailingLabel2()
            ]
        )

        let type: ActivityProductType
        let network: String
        if originFromSwap {
            type = .swap
            network = networkFromSwap ?? activity.currencyType.code
        } else {
            type = activity.isBuy ? .buy : .sell
            network = activity.currencyType.code
        }
        let entry = ActivityEntry(
            id: activity.identifier,
            type: type,
            network: network,
            pubKey: "",
            externalUrl: "",
            item: compositionView,
            state: activity.status.toActivityState() ?? .unknown,
            timestamp: activity.creationDate.timeIntervalSince1970,
            transactionType: nil
        )
        return entry
    }

    public static func createEntry(with activity: EarnActivity, type: UnifiedActivityDomain.ActivityProductType) -> ActivityEntry {
        let compositionView = ActivityItem.CompositionView(
            leadingImage: activity.leadingImage(),
            leading: [
                activity.leadingLabel1(product: type),
                activity.leadingLabel2()
            ],
            trailing: [
                activity.trailingLabel1()
            ]
        )

        let entry = ActivityEntry(
            id: activity.id,
            type: type,
            network: activity.currency.code,
            pubKey: "",
            externalUrl: "",
            item: compositionView,
            state: activity.state.toActivityState(),
            timestamp: activity.date.insertedAt.timeIntervalSince1970,
            transactionType: .init(rawValue: activity.type.value)
        )
        return entry
    }

    public static func createEntry(with activity: SwapActivityItemEvent) -> ActivityEntry {
        let compositionView = ActivityItem.CompositionView(
            leadingImage: activity.leadingImage(),
            leading: [
                activity.leadingLabel1(),
                activity.leadingLabel2()
            ],
            trailing: [
                activity.trailingLabel1(),
                activity.trailingLabel2()
            ]
        )

        let entry = ActivityEntry(
            id: activity.identifier,
            type: .swap,
            network: activity.pair.inputCurrencyType.code,
            pubKey: "",
            externalUrl: "",
            item: compositionView,
            state: activity.status.toActivityState(),
            timestamp: activity.date.timeIntervalSince1970,
            transactionType: nil
        )
        return entry
    }

    static func failedLabel() -> LeafItemType {
        let leadingItem2Style = ActivityItem.Text.Style(
            typography: ActivityTypography.caption1,
            color: ActivityColor.error
        )
        return .text(.init(
            value: "Failed",
            style: leadingItem2Style
        ))
    }
}

// MARK: Custodial crypto activity extensions

extension CustodialActivityEvent.State {
    fileprivate func toActivityState() -> ActivityState {
        switch self {
        case .completed:
            return .completed
        case .failed:
            return .failed
        case .pending:
            return .pending
        }
    }
}

extension CustodialActivityEvent.Crypto {
    fileprivate func leadingImage() -> ImageType {
        switch type {
        case .withdrawal:
            return ImageType.smallTag(.init(main: "https://login.blockchain.com/static/asset/icon/send.svg"))
        case .deposit:
            return ImageType.smallTag(.init(main: "https://login.blockchain.com/static/asset/icon/receive.svg"))
        }
    }

    fileprivate func leadingLabel1() -> LeafItemType {
        var string = ""
        switch type {
        case .withdrawal:
            string = "\(LocalizationConstants.Activity.MainScreen.Item.withdrew) \(amount.displayCode)"
        case .deposit:
            string = "\(LocalizationConstants.Activity.MainScreen.Item.receive) \(amount.displayCode)"
        }

        let leadingItem1Style = ActivityItem.Text.Style(
            typography: ActivityTypography.paragraph2,
            color: ActivityColor.title
        )

        return LeafItemType.text(.init(
            value: string,
            style: leadingItem1Style
        ))
    }

    fileprivate func leadingLabel2() -> LeafItemType {
        if state == .failed {
            return ActivityEntryAdapter.failedLabel()
        }

        let leadingItem2Style = ActivityItem.Text.Style(
            typography: ActivityTypography.caption1,
            color: ActivityColor.body
        )
        return .text(.init(
            value: DateFormatter.mediumWithoutYear.string(from: date),
            style: leadingItem2Style
        ))
    }

    fileprivate func trailingLabel1() -> LeafItemType {
        var string = ""
        switch type {
        case .withdrawal:
            string = "- \(valuePair.quote.toDisplayString(includeSymbol: true))"
        case .deposit:
            string = "\(valuePair.quote.toDisplayString(includeSymbol: true))"
        }
        let trailingItem1Style = ActivityItem.Text.Style(
            typography: ActivityTypography.paragraph2,
            color: ActivityColor.title
        )

        return .text(.init(
            value: string,
            style: trailingItem1Style
        ))
    }

    fileprivate func trailingLabel2() -> LeafItemType {
        let trailingItem2Style = ActivityItem.Text.Style(
            typography: ActivityTypography.caption1,
            color: ActivityColor.body
        )
        return .text(.init(
            value: amount.displayString,
            style: trailingItem2Style
        ))
    }
}

extension CustodialActivityEvent.Fiat {
    fileprivate func leadingImage() -> ImageType {
        switch type {
        case .withdrawal:
            return ImageType.smallTag(.init(main: "https://login.blockchain.com/static/asset/icon/send.svg"))
        case .deposit:
            return ImageType.smallTag(.init(main: "https://login.blockchain.com/static/asset/icon/receive.svg"))
        }
    }

    fileprivate func leadingLabel1() -> LeafItemType {
        var string = ""
        switch type {
        case .withdrawal:
            string = "\(LocalizationConstants.Activity.MainScreen.Item.withdraw) \(amount.displayCode)"
        case .deposit:
            string = "\(LocalizationConstants.Activity.MainScreen.Item.deposit) \(amount.displayCode)"
        }

        let leadingItem1Style = ActivityItem.Text.Style(
            typography: ActivityTypography.paragraph2,
            color: ActivityColor.title
        )

        return LeafItemType.text(.init(
            value: string,
            style: leadingItem1Style
        ))
    }

    fileprivate func leadingLabel2() -> LeafItemType {
        if state == .failed {
            return ActivityEntryAdapter.failedLabel()
        }

        let leadingItem2Style = ActivityItem.Text.Style(
            typography: ActivityTypography.caption1,
            color: ActivityColor.body
        )
        return .text(.init(
            value: DateFormatter.mediumWithoutYear.string(from: date),
            style: leadingItem2Style
        ))
    }

    fileprivate func trailingLabel1() -> LeafItemType {
        var string = ""
        switch type {
        case .withdrawal:
            string = "- \(amount.toDisplayString(includeSymbol: true))"
        case .deposit:
            string = "\(amount.toDisplayString(includeSymbol: true))"
        }
        let trailingItem1Style = ActivityItem.Text.Style(
            typography: ActivityTypography.paragraph2,
            color: ActivityColor.title
        )

        return .text(.init(
            value: string,
            style: trailingItem1Style
        ))
    }
}

// MARK: Buy/Sell activity extensions

extension BuySellActivityItemEvent.EventStatus {
    fileprivate func toActivityState() -> ActivityState? {
        switch self {
        case .pending:
            return .pending
        case .failed:
            return .failed
        case .finished:
            return .completed
        case .pendingConfirmation:
            return .confirming
        default:
            return nil
        }
    }
}

extension BuySellActivityItemEvent {
    fileprivate func leadingImage() -> ImageType {
        isBuy ?
        ImageType.smallTag(.init(
            main: "https://login.blockchain.com/static/asset/icon/plus.svg",
            tag: nil
        )) :
        ImageType.smallTag(.init(
            main: "https://login.blockchain.com/static/asset/icon/minus.svg",
            tag: nil
        ))
    }

    fileprivate func leadingLabel1() -> LeafItemType {
        let string = "\(isBuy ? LocalizationConstants.Activity.MainScreen.Item.buy : LocalizationConstants.Activity.MainScreen.Item.sell)"
        let fullLabelString = "\(string) \(isBuy ? outputValue.code : inputValue.code)"
        let leadingItem1Style = ActivityItem.Text.Style(
            typography: ActivityTypography.paragraph2,
            color: ActivityColor.title
        )

        return .text(.init(
            value: fullLabelString,
            style: leadingItem1Style
        ))
    }

    fileprivate func leadingLabel2() -> LeafItemType {
        if status == .failed {
            return ActivityEntryAdapter.failedLabel()
        }

        let leadingItem2Style = ActivityItem.Text.Style(
            typography: ActivityTypography.caption1,
            color: ActivityColor.body
        )
        return .text(.init(
            value: DateFormatter.mediumWithoutYear.string(from: creationDate),
            style: leadingItem2Style
        ))
    }

    fileprivate func trailingLabel1() -> LeafItemType {
        let trailingItem1Style = ActivityItem.Text.Style(
            typography: ActivityTypography.paragraph2,
            color: ActivityColor.title
        )

        return .text(.init(
            value: isBuy ? inputValue.displayString : outputValue.displayString,
            style: trailingItem1Style
        ))
    }

    fileprivate func trailingLabel2() -> LeafItemType {
        let trailingItem2Style = ActivityItem.Text.Style(
            typography: ActivityTypography.caption1,
            color: ActivityColor.body
        )
        return .text(.init(
            value: isBuy ? outputValue.displayString : inputValue.displayString,
            style: trailingItem2Style
        ))
    }
}

// MARK: Swap activity extensions

extension SwapActivityItemEvent.EventStatus {
    fileprivate func toActivityState() -> ActivityState {
        switch self {
        case .inProgress:
            return .pending
        case .failed:
            return .failed
        case .complete:
            return .completed
        default:
            return .unknown
        }
    }
}

extension SwapActivityItemEvent {
    fileprivate func leadingImage() -> ImageType {
        ImageType.smallTag(.init(
            main: "https://login.blockchain.com/static/asset/icon/swap.svg",
            tag: nil
        ))
    }

    fileprivate func leadingLabel1() -> LeafItemType {
        let string = "\(LocalizationConstants.Activity.MainScreen.Item.swap) \(pair.inputCurrencyType.code) -> \(pair.outputCurrencyType.code)"
        let leadingItem1Style = ActivityItem.Text.Style(
            typography: ActivityTypography.paragraph2,
            color: ActivityColor.title
        )

        return .text(.init(
            value: string,
            style: leadingItem1Style
        ))
    }

    fileprivate func leadingLabel2() -> LeafItemType {
        if status == .failed {
            return ActivityEntryAdapter.failedLabel()
        }
        let leadingItem2Style = ActivityItem.Text.Style(
            typography: ActivityTypography.caption1,
            color: ActivityColor.body
        )
        return .text(.init(
            value: DateFormatter.mediumWithoutYear.string(from: date),
            style: leadingItem2Style
        ))
    }

    fileprivate func trailingLabel1() -> LeafItemType {
        let trailingItem1Style = ActivityItem.Text.Style(
            typography: ActivityTypography.paragraph2,
            color: ActivityColor.title
        )

        return .text(.init(
            value: amounts.fiatValue.displayString,
            style: trailingItem1Style
        ))
    }

    fileprivate func trailingLabel2() -> LeafItemType {
        let trailingItem2Style = ActivityItem.Text.Style(
            typography: ActivityTypography.caption1,
            color: ActivityColor.body
        )
        return .text(.init(
            value: amounts.withdrawal.toDisplayString(includeSymbol: true),
            style: trailingItem2Style
        ))
    }
}

extension EarnActivity {
    func activityTitle(product: ActivityProductType) -> String {
        switch type {
        case .deposit where product == .staking:
            return LocalizationConstants.Activity.MainScreen.Item.staked
        case .deposit where product == .activeRewards:
            return LocalizationConstants.Activity.MainScreen.Item.subscribed
        case .deposit:
            return LocalizationConstants.Activity.MainScreen.Item.added
        case .debit:
            return LocalizationConstants.Activity.MainScreen.Item.debited
        case .interestEarned:
            return LocalizationConstants.Activity.MainScreen.Item.rewardsEarned
        case .withdraw where state == .complete:
            return LocalizationConstants.Activity.MainScreen.Item.withdraw
        case .withdraw where state == .pending || state == .processing || state == .manualReview:
            return LocalizationConstants.Activity.MainScreen.Item.withdrawing
        default:
            assertionFailure("added a new activity type perhaps?")
            return ""
        }
    }

    fileprivate func leadingImage() -> ImageType {
        ImageType.smallTag(.init(
            main: "https://login.blockchain.com/static/asset/icon/rewards.svg",
            tag: nil
        ))
    }

    fileprivate func leadingLabel1(product: ActivityProductType) -> LeafItemType {
        let transactionTypeTitle: String = activityTitle(product: product)
        let string = "\(currency.code) \(transactionTypeTitle)"

        let leadingItem1Style = ActivityItem.Text.Style(
            typography: ActivityTypography.paragraph2,
            color: ActivityColor.title
        )

        return .text(.init(
            value: string,
            style: leadingItem1Style
        ))
    }

    fileprivate func leadingLabel2() -> LeafItemType {
        let leadingItem2Style = ActivityItem.Text.Style(
            typography: ActivityTypography.caption1,
            color: ActivityColor.body
        )
        return .text(.init(
            value: DateFormatter.mediumWithoutYear.string(from: date.insertedAt),
            style: leadingItem2Style
        ))
    }

    fileprivate func trailingLabel1() -> LeafItemType {
        let trailingItem1Style = ActivityItem.Text.Style(
            typography: ActivityTypography.paragraph2,
            color: ActivityColor.title
        )

        return .text(.init(
            value: value.toDisplayString(includeSymbol: true),
            style: trailingItem1Style
        ))
    }
}

extension EarnActivity.State {
    fileprivate func toActivityState() -> ActivityState {
        switch self {
        case .pending:
            return .pending
        case .failed:
            return .failed
        case .complete:
            return .completed
        default:
            return .unknown
        }
    }
}
