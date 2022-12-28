// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
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
            network: activity.amount.displayCode,
            pubKey: "",
            externalUrl: "",
            item: compositionView,
            state: activity.state.toActivityState(),
            timestamp: activity.date.timeIntervalSince1970
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
            network: activity.amount.displayCode,
            pubKey: "",
            externalUrl: "",
            item: compositionView,
            state: activity.state.toActivityState(),
            timestamp: activity.date.timeIntervalSince1970
        )
        return entry
    }

    public static func createEntry(with activity: BuySellActivityItemEvent) -> ActivityEntry {
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
            network: activity.currencyType.displayCode,
            pubKey: "",
            externalUrl: "",
            item: compositionView,
            state: activity.status.toActivityState() ?? .unknown,
            timestamp: activity.creationDate.timeIntervalSince1970
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
            network: activity.pair.inputCurrencyType.displayCode,
            pubKey: "",
            externalUrl: "",
            item: compositionView,
            state: activity.status.toActivityState(),
            timestamp: activity.date.timeIntervalSince1970
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
            return ImageType.smallTag(.init(main: "https://login.blockchain.com/static/asset/icon/receive.svg"))
        case .deposit:
            return ImageType.smallTag(.init(main: "https://login.blockchain.com/static/asset/icon/send.svg"))
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
            return ImageType.smallTag(.init(main: "https://login.blockchain.com/static/asset/icon/receive.svg"))
        case .deposit:
            return ImageType.smallTag(.init(main: "https://login.blockchain.com/static/asset/icon/send.svg"))
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
        let fullLabelString = "\(string) \(outputValue.code)"
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
            value: inputValue.displayString,
            style: trailingItem1Style
        ))
    }

    fileprivate func trailingLabel2() -> LeafItemType {
        let trailingItem2Style = ActivityItem.Text.Style(
            typography: ActivityTypography.caption1,
            color: ActivityColor.body
        )
        return .text(.init(
            value: outputValue.displayString,
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
