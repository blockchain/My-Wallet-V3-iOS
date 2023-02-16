// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import PlatformKit
import RxDataSources
import ToolKit

// swiftlint:disable type_body_length
public final class ActivityItemViewModel: IdentifiableType, Hashable {

    typealias AccessibilityId = Accessibility.Identifier.Activity
    typealias LocalizationStrings = LocalizationConstants.Activity.MainScreen.Item

    public typealias Descriptors = AssetBalanceViewModel.Value.Presentation.Descriptors

    public var identity: AnyHashable {
        event
    }

    public var descriptors: Descriptors {
        let accessibility = AccessibilityId.ActivityCell.self
        switch event.status {
        case .pending:
            return .muted(
                cryptoAccessiblitySuffix: accessibility.cryptoValuePrefix,
                fiatAccessiblitySuffix: accessibility.fiatValuePrefix
            )
        case .complete:
            return .activity(
                cryptoAccessiblitySuffix: accessibility.cryptoValuePrefix,
                fiatAccessiblitySuffix: accessibility.fiatValuePrefix
            )
        case .product:
            return .activity(
                cryptoAccessiblitySuffix: accessibility.cryptoValuePrefix,
                fiatAccessiblitySuffix: accessibility.fiatValuePrefix
            )
        }
    }

    public var titleLabelContent: LabelContent {
        var text = ""
        switch event {
        case .buySell(let orderDetails):
            switch (orderDetails.status, orderDetails.isBuy) {
            case (.pending, true):
                text = "\(LocalizationStrings.buying) \(orderDetails.outputValue.currency.displayCode)"
            case (_, true):
                text = "\(LocalizationStrings.buy) \(orderDetails.outputValue.currency.displayCode)"
            case (_, false):
                text = [
                    LocalizationStrings.sell,
                    orderDetails.inputValue.currency.displayCode,
                    "->",
                    orderDetails.outputValue.currency.displayCode
                ].joined(separator: " ")
            }
        case .interest(let event):
            switch (event.type, event.state) {
            case (.withdraw, .complete):
                text = LocalizationStrings.withdraw + " \(event.cryptoCurrency.code)"
            case (.withdraw, .pending),
                 (.withdraw, .processing),
                 (.withdraw, .manualReview):
                text = LocalizationStrings.withdrawing + " \(event.cryptoCurrency.code)"
            case (.interestEarned, _):
                text = event.cryptoCurrency.code + " \(LocalizationStrings.rewardsEarned)"
            case (.transfer, _):
                text = LocalizationStrings.added + " \(event.cryptoCurrency.code)"
            default:
                assertionFailure("added a new activity type perhaps?")
                text = "\(event.cryptoCurrency.code)"
            }
        case .earn(let product, let event):
            switch (event.type, event.state) {
            case (.withdraw, .complete):
                text = LocalizationStrings.withdraw + " \(event.currency.code)"
            case (.withdraw, .pending),
                (.withdraw, .processing),
                (.withdraw, .manualReview):
                text = LocalizationStrings.withdrawing + " \(event.currency.code)"
            case (.interestEarned, _):
                text = event.currency.code + " \(LocalizationStrings.rewardsEarned)"
            case (.deposit, _) where product == .staking:
                text = LocalizationStrings.staked + " \(event.currency.code)"
            case (.deposit, _) where product == .active:
                text = LocalizationStrings.subscribed + " \(event.currency.code)"
            case (.deposit, _):
                text = LocalizationStrings.added + " \(event.currency.code)"
            case (.debit, _):
                text = LocalizationStrings.debited + " \(event.currency.code)"
            default:
                assertionFailure("added a new activity type perhaps?")
                text = "\(event.currency.code)"
            }
        case .swap(let event):
            let pair = event.pair
            switch (event.status, pair.outputCurrencyType) {
            case (.complete, .crypto):
                text = LocalizationStrings.swap
            case (.complete, .fiat):
                text = LocalizationStrings.sell
            case (_, .crypto):
                text = LocalizationStrings.pendingSwap
            case (_, .fiat):
                text = LocalizationStrings.pendingSell
            }
            text += " \(pair.inputCurrencyType.displayCode) -> \(pair.outputCurrencyType.displayCode)"

        case .simpleTransactional(let event):
            switch (event.status, event.type) {
            case (.pending, .receive):
                text = LocalizationStrings.receiving + " \(event.currency.displayCode)"
            case (.pending, .send):
                text = LocalizationStrings.sending + " \(event.currency.displayCode)"
            case (.complete, .receive):
                text = LocalizationStrings.receive + " \(event.currency.displayCode)"
            case (.complete, .send):
                text = LocalizationStrings.send + " \(event.currency.displayCode)"
            }
        case .transactional(let event):
            switch (event.status, event.type) {
            case (.pending, .receive):
                text = LocalizationStrings.receiving + " \(event.currency.displayCode)"
            case (.pending, .send):
                text = LocalizationStrings.sending + " \(event.currency.displayCode)"
            case (.complete, .receive):
                text = LocalizationStrings.receive + " \(event.currency.displayCode)"
            case (.complete, .send):
                text = LocalizationStrings.send + " \(event.currency.displayCode)"
            }
        case .fiat(let event):
            switch (event.type, event.state) {
            case (.deposit, .completed):
                text = LocalizationStrings.deposit + " \(event.amount.displayCode)"
            case (.withdrawal, .completed):
                text = LocalizationStrings.withdraw + " \(event.amount.displayCode)"
            case (.deposit, _):
                text = LocalizationStrings.depositing + " \(event.amount.displayCode)"
            case (.withdrawal, _):
                text = LocalizationStrings.withdrawing + " \(event.amount.displayCode)"
            }
        case .crypto(let event):
            switch (event.state, event.type) {
            case (.pending, .deposit):
                text = LocalizationStrings.receiving + " \(event.amount.displayCode)"
            case (.pending, .withdrawal):
                text = LocalizationStrings.sending + " \(event.amount.displayCode)"
            case (_, .deposit):
                text = LocalizationStrings.receive + " \(event.amount.displayCode)"
            case (_, .withdrawal):
                text = LocalizationStrings.send + " \(event.amount.displayCode)"
            }
        }
        return .init(
            text: text,
            font: descriptors.primaryFont,
            color: descriptors.primaryTextColor,
            alignment: .left,
            adjustsFontSizeToFitWidth: .true(factor: 0.75),
            accessibility: .id(AccessibilityId.ActivityCell.titleLabel)
        )
    }

    public var descriptionLabelContent: LabelContent {
        switch event.status {
        case .pending(confirmations: let confirmations):
            return .init(
                text: "\(confirmations.current) \(LocalizationStrings.of) \(confirmations.total)",
                font: descriptors.secondaryFont,
                color: descriptors.secondaryTextColor,
                alignment: .left,
                accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
            )
        case .complete:
            return .init(
                text: DateFormatter.medium.string(from: event.creationDate),
                font: descriptors.secondaryFont,
                color: descriptors.secondaryTextColor,
                alignment: .left,
                accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
            )
        case .product(let status):
            let failedLabelContent: LabelContent = .init(
                text: LocalizationStrings.failed,
                font: descriptors.secondaryFont,
                color: .destructive,
                alignment: .left,
                accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
            )

            switch status {
            case .custodial(let status):
                switch status {
                case .failed:
                    return failedLabelContent
                case .completed, .pending:
                    break
                }
            case .interest(let state):
                switch state {
                case .processing,
                     .pending,
                     .manualReview:
                    return .init(
                        text: LocalizationStrings.pending,
                        font: descriptors.secondaryFont,
                        color: descriptors.secondaryTextColor,
                        alignment: .left,
                        accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
                    )
                case .failed,
                     .rejected,
                     .refunded:
                    return failedLabelContent
                case .cleared,
                     .complete,
                     .unknown:
                    return .init(
                        text: DateFormatter.medium.string(from: event.creationDate),
                        font: descriptors.secondaryFont,
                        color: descriptors.secondaryTextColor,
                        alignment: .left,
                        accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
                    )
                }
            case .earn(let state):
                switch state {
                case .processing,
                        .pending,
                        .manualReview:
                    return .init(
                        text: LocalizationStrings.pending,
                        font: descriptors.secondaryFont,
                        color: descriptors.secondaryTextColor,
                        alignment: .left,
                        accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
                    )
                case .failed,
                        .rejected,
                        .refunded:
                    return failedLabelContent
                case _:
                    return .init(
                        text: DateFormatter.medium.string(from: event.creationDate),
                        font: descriptors.secondaryFont,
                        color: descriptors.secondaryTextColor,
                        alignment: .left,
                        accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
                    )
                }
            case .buySell(let status):
                if status == .failed {
                    return failedLabelContent
                }
            case .swap(let status):
                if status == .failed {
                    return failedLabelContent
                }
            }

            return .init(
                text: DateFormatter.medium.string(from: event.creationDate),
                font: descriptors.secondaryFont,
                color: descriptors.secondaryTextColor,
                alignment: .left,
                accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
            )
        }
    }

    /// The color of the `EventType` image.
    public var eventColor: UIColor {
        switch event {
        case .buySell(let orderDetails):
            switch (orderDetails.status, orderDetails.isBuy) {
            case (.failed, _):
                return .destructive
            case (_, true):
                return orderDetails.outputValue.currency.brandUIColor
            case (_, false):
                return orderDetails.inputValue.currency.brandUIColor
            }
        case .swap(let event):
            if event.status == .failed {
                return .destructive
            }
            return event.pair.inputCurrencyType.brandUIColor
        case .interest(let interest):
            switch interest.state {
            case .pending,
                 .processing,
                 .manualReview:
                return .mutedText
            case .failed,
                 .rejected:
                return .destructive
            case .refunded,
                 .cleared,
                 .unknown,
                 .complete:
                return interest.cryptoCurrency.brandUIColor
            }
        case .earn(_, let item):
            switch item.state {
            case .pending, .processing, .manualReview:
                return .mutedText
            case .failed, .rejected:
                return .destructive
            case _:
                return item.currency.brandUIColor
            }
        case .fiat(let event):
            switch event.state {
            case .failed:
                return .destructive
            case .pending:
                return .mutedText
            case .completed:
                return event.amount.currency.brandColor
            }
        case .crypto(let event):
            switch event.state {
            case .failed:
                return .destructive
            case .pending:
                return .mutedText
            case .completed:
                return event.amount.currencyType.brandUIColor
            }
        case .simpleTransactional(let event):
            switch event.status {
            case .complete:
                return event.currency.brandUIColor
            case .pending:
                return .mutedText
            }
        case .transactional(let event):
            switch event.status {
            case .complete:
                return event.currency.brandUIColor
            case .pending:
                return .mutedText
            }
        }
    }

    /// The fill color of the `BadgeImageView`
    public var backgroundColor: UIColor {
        eventColor.withAlphaComponent(0.15)
    }

    /// The `imageResource` for the `BadgeImageViewModel`
    public var imageResource: ImageResource {
        switch event {
        case .earn(_, let staking):
            switch staking.state {
            case .pending,
                    .processing,
                    .manualReview:
                return .local(name: "clock-icon", bundle: .platformUIKit)
            case .failed,
                    .rejected:
                return .local(name: "activity-failed-icon", bundle: .platformUIKit)
            case .complete:
                switch staking.type {
                case .deposit:
                    return .local(name: "plus-icon", bundle: .platformUIKit)
                case .withdraw:
                    return .local(name: "minus-icon", bundle: .platformUIKit)
                case .interestEarned:
                    return .local(name: Icon.interest.name, bundle: .componentLibrary)
                case .debit:
                    return .local(name: "minus-icon", bundle: .platformUIKit)
                case _:
                    // NOTE: `.unknown` is filtered out in
                    // the `ActivityScreenInteractor`
                    assertionFailure("Unexpected case for interest \(staking.state)")
                    return .local(name: Icon.question.name, bundle: .componentLibrary)
                }
            case .cleared:
                return .local(name: "clock-icon", bundle: .platformUIKit)
            case _:
                assertionFailure("Unexpected case for interest \(staking.state)")
                return .local(name: Icon.question.name, bundle: .componentLibrary)
            }
        case .interest(let interest):
            switch interest.state {
            case .pending,
                 .processing,
                 .manualReview:
                return .local(name: "clock-icon", bundle: .platformUIKit)
            case .failed,
                 .rejected:
                return .local(name: "activity-failed-icon", bundle: .platformUIKit)
            case .complete:
                switch interest.type {
                case .transfer:
                    return .local(name: "plus-icon", bundle: .platformUIKit)
                case .withdraw:
                    return .local(name: "minus-icon", bundle: .platformUIKit)
                case .interestEarned:
                    return .local(name: Icon.interest.name, bundle: .componentLibrary)
                case .unknown:
                    // NOTE: `.unknown` is filtered out in
                    // the `ActivityScreenInteractor`
                    assertionFailure("Unexpected case for interest \(interest.state)")
                    return .local(name: Icon.question.name, bundle: .componentLibrary)
                }
            case .cleared:
                return .local(name: "clock-icon", bundle: .platformUIKit)
            case .refunded,
                 .unknown:
                assertionFailure("Unexpected case for interest \(interest.state)")
                return .local(name: Icon.question.name, bundle: .componentLibrary)
            }
        case .buySell(let value):
            if value.status == .failed {
                return .local(name: "activity-failed-icon", bundle: .platformUIKit)
            }
            if value.isBuy && value.recurringBuyId != nil {
                return .local(name: Icon.repeat.name, bundle: .componentLibrary)
            }

            let imageName = value.isBuy ? "plus-icon" : "minus-icon"
            return .local(name: imageName, bundle: .platformUIKit)
        case .fiat(let event):
            switch event.state {
            case .failed:
                return .local(name: "activity-failed-icon", bundle: .platformUIKit)
            case .pending:
                return .local(name: "clock-icon", bundle: .platformUIKit)
            case .completed:
                switch event.type {
                case .deposit:
                    return .local(name: "deposit-icon", bundle: .platformUIKit)
                case .withdrawal:
                    return .local(name: "withdraw-icon", bundle: .platformUIKit)
                }
            }
        case .crypto(let event):
            switch event.state {
            case .failed:
                return .local(name: "activity-failed-icon", bundle: .platformUIKit)
            case .pending:
                return .local(name: "clock-icon", bundle: .platformUIKit)
            case .completed:
                switch event.type {
                case .deposit:
                    return .local(name: "receive-icon", bundle: .platformUIKit)
                case .withdrawal:
                    return .local(name: "send-icon", bundle: .platformUIKit)
                }
            }
        case .swap(let event):
            if event.status == .failed {
                return .local(name: "activity-failed-icon", bundle: .platformUIKit)
            }
            return .local(name: "swap-icon", bundle: .platformUIKit)
        case .transactional(let event):
            switch (event.status, event.type) {
            case (.pending, _):
                return .local(name: "clock-icon", bundle: .platformUIKit)
            case (_, .send):
                return .local(name: "send-icon", bundle: .platformUIKit)
            case (_, .receive):
                return .local(name: "receive-icon", bundle: .platformUIKit)
            }
        case .simpleTransactional(let event):
            switch (event.status, event.type) {
            case (.pending, _):
                return .local(name: "clock-icon", bundle: .platformUIKit)
            case (_, .send):
                return .local(name: "send-icon", bundle: .platformUIKit)
            case (_, .receive):
                return .local(name: "receive-icon", bundle: .platformUIKit)
            }
        }
    }

    public let event: ActivityItemEvent

    public init(event: ActivityItemEvent) {
        self.event = event
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(event)
    }
}

extension ActivityItemViewModel: Equatable {
    public static func == (lhs: ActivityItemViewModel, rhs: ActivityItemViewModel) -> Bool {
        lhs.event == rhs.event
    }
}
