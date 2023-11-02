// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureStakingDomain
import Foundation
import Localization
import MoneyKit
import PlatformKit
import ToolKit
import UnifiedActivityDomain

extension ActivityDetailsAdapter {
    public static func createActivityDetails(from account: String, type: ActivityProductType, activity: EarnActivity) -> ActivityDetail.GroupedItems {
        let group1 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [activity.amountRow()])

        let items = [
            activity.statusRow(),
            activity.fromRow(),
            activity.toRow(accountName: account)
        ].compactMap { $0 }

        let group2 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: items)

        let copyAction = ItemType.leaf(.button(.init(
            text: LocalizationConstants.SuperApp.ActivityDetails.copyTransactionButtonLabel,
            style: .secondary,
            actionType: .copy,
            actionData: activity.id
        )))

        let group3 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.dateRow(),
            activity.transactionRow(),
            copyAction
        ])

        return ActivityDetail.GroupedItems(
            title: activity.title(product: type),
            icon: activity.leadingImage(),
            itemGroups: [group1, group2, group3],
            floatingActions: []
        )
    }
}

extension EarnActivity {
    fileprivate func leadingImage() -> ImageType {
        if let logoURL = currency.cryptoCurrency?.logoURL?.absoluteString {
            ImageType.smallTag(
                .init(
                    main: logoURL,
                    tag: ActivityRemoteIcons.earn.url(mode: .dark)
                )
            )
        } else {
            ImageType.smallTag(
                .init(
                    main: ActivityRemoteIcons.earn.url(mode: .dark),
                    tag: nil
                )
            )
        }
    }

    fileprivate func title(product: ActivityProductType) -> String {
        switch type {
        case .interestEarned:
            activityTitle(product: product).interpolating(currency.code)
        default:
            "\(currency.code) \(activityTitle(product: product))"
        }
    }

    fileprivate func amountRow() -> ItemType {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        let trailingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .title
        )

        return ItemType.compositionView(.init(
            leading: [
                .text(
                    .init(
                        value: LocalizationConstants.SuperApp.ActivityDetails.amountLabel,
                        style: leadingItemStyle
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: value.toDisplayString(includeSymbol: true),
                        style: trailingItemStyle
                    )
                )
            ]
        ))
    }

    fileprivate func statusRow() -> ItemType {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        return ItemType.compositionView(.init(
            leading: [
                .text(
                    .init(
                        value: LocalizationConstants.SuperApp.ActivityDetails.statusLabel,
                        style: leadingItemStyle
                    )
                )
            ],
            trailing: [
                state.toBadge()
            ]
        ))
    }

    fileprivate func fromRow() -> ItemType? {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        let trailingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .title
        )

        return ItemType.compositionView(.init(
            leading: [
                .text(
                    .init(
                        value: LocalizationConstants.SuperApp.ActivityDetails.fromLabel,
                        style: leadingItemStyle
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: "Blockchain.com",
                        style: trailingItemStyle
                    )
                )
            ]
        ))
    }

    fileprivate func toRow(accountName: String) -> ItemType? {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        let trailingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .title
        )

        return ItemType.compositionView(.init(
            leading: [
                .text(
                    .init(
                        value: LocalizationConstants.SuperApp.ActivityDetails.toLabel,
                        style: leadingItemStyle
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: accountName,
                        style: trailingItemStyle
                    )
                )
            ]
        ))
    }

    fileprivate func dateRow() -> ItemType {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        let trailingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .title
        )

        return ItemType.compositionView(.init(
            leading: [
                .text(
                    .init(
                        value: LocalizationConstants.SuperApp.ActivityDetails.dateLabel,
                        style: leadingItemStyle
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: DateFormatter.elegantDateFormatter.string(from: date.insertedAt),
                        style: trailingItemStyle
                    )
                )
            ]
        ))
    }

    fileprivate func transactionRow() -> ItemType {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        let trailingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .title
        )

        return ItemType.compositionView(.init(
            leading: [
                .text(
                    .init(
                        value: LocalizationConstants.SuperApp.ActivityDetails.transactionIdLabel,
                        style: leadingItemStyle
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: id,
                        style: trailingItemStyle
                    )
                )
            ]
        ))
    }
}

extension EarnActivity.State {
    fileprivate func toBadge() -> LeafItemType {
        switch self {
        case .pending:
            LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.pendingStatus,
                    style: .default
                ))
        case .failed:
            LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.failedStatus,
                    style: .error
                ))
        case .complete:
            LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.completeStatus,
                    style: .success
                ))
        default:
            LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.pendingStatus,
                    style: .default
                ))
        }
    }
}
