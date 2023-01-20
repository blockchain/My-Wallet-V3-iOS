// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Foundation
import Localization
import MoneyKit
import PlatformKit
import ToolKit
import UnifiedActivityDomain

public enum ActivityDetailsAdapter {
    public static func createActivityDetails(with activity: CustodialActivityEvent.Crypto) -> ActivityDetail.GroupedItems {
        let group1 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.amountRow(),
            activity.coinPriceRow(),
            activity.totalRow()
        ])

        let group2 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.statusRow(),
            activity.fromRow(),
            activity.networkRow()
        ])

        let copyAction = ItemType.leaf(.button(.init(text: LocalizationConstants.SuperApp.ActivityDetails.copyTransactionButtonLabel,
                                                     style: .secondary,
                                                     actionType: .copy,
                                                     actionData: activity.identifier
                                                    )))

        let group3 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.dateRow(),
            activity.transactionRow(),
            copyAction
        ])

        return ActivityDetail.GroupedItems(
            title: activity.title(),
            icon: activity.leadingImage(),
            itemGroups: [group1, group2, group3],
            floatingActions: []
        )
    }

    public static func createActivityDetails(with activity: CustodialActivityEvent.Fiat) -> ActivityDetail.GroupedItems {
        let group1 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.totalRow()
        ])

        let group2 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.statusRow()
        ])

        let group3 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.dateRow(),
            activity.transactionRow()
        ])

        return ActivityDetail.GroupedItems(
            title: activity.title(),
            icon: activity.leadingImage(),
            itemGroups: [group1, group2, group3],
            floatingActions: []
        )
    }

    public static func createActivityDetails(with activity: BuySellActivityItemEvent) -> ActivityDetail.GroupedItems {
        let group1 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.purchaseRow(),
            activity.amountRow(),
            activity.coinPriceRow(),
            activity.feeRow()
        ])

        let group2 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.statusRow(),
            activity.paymentTypeRow()
        ])


        let copyAction = ItemType.leaf(.button(.init(text: LocalizationConstants.SuperApp.ActivityDetails.copyTransactionButtonLabel,
                                                     style: .secondary,
                                                     actionType: .copy,
                                                     actionData: activity.identifier
                                                    )))

        let group3 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.dateRow(),
            activity.transactionRow(),
            copyAction
        ])

        return ActivityDetail.GroupedItems(
            title: activity.title(),
            icon: activity.leadingImage(),
            itemGroups: [group1, group2, group3],
            floatingActions: []
        )
    }

    public static func createActivityDetails(with activity: SwapActivityItemEvent) -> ActivityDetail.GroupedItems {
        let group1 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.amountRow(),
            activity.forRow(),
            activity.exchangeRow(),
            activity.feeRow(),
            activity.totalRow()
        ])

        let group2 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.statusRow(),
            activity.fromRow(),
            activity.toRow(),
            activity.networkRow()
        ])

        let copyAction = ItemType.leaf(.button(.init(text: LocalizationConstants.SuperApp.ActivityDetails.copyTransactionButtonLabel,
                                                     style: .secondary,
                                                     actionType: .copy,
                                                     actionData: activity.identifier
                                                    )))

        let group3 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.dateRow(),
            activity.transactionRow(),
            copyAction
        ])

        return ActivityDetail.GroupedItems(
            title: activity.title(),
            icon: activity.leadingImage(),
            itemGroups: [group1, group2, group3],
            floatingActions: []
        )
    }
}

// MARK: Custodial crypto activity extensions

extension CustodialActivityEvent.State {
    fileprivate func toBadge() -> LeafItemType {
        switch self {
        case .completed:
            return LeafItemType.badge(.init(value: rawValue.capitalized, style: .success))
        case .failed:
            return LeafItemType.badge(.init(value: rawValue.capitalized, style: .error))
        case .pending:
            return LeafItemType.badge(.init(value: rawValue.capitalized, style: .default))
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

    fileprivate func title() -> String {
        switch type {
        case .withdrawal:
            return "\(LocalizationConstants.Activity.MainScreen.Item.withdraw) \(amount.displayCode)"
        case .deposit:
            return "\(LocalizationConstants.Activity.MainScreen.Item.deposit) \(amount.displayCode)"
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
            leading: [.text(.init(
                value: LocalizationConstants.SuperApp.ActivityDetails.amountLabel,
                style: leadingItemStyle
            ))],
            trailing: [
                .text(.init(
                    value: valuePair.quote.toDisplayString(includeSymbol: true),
                    style: trailingItemStyle
                )),
                .text(.init(
                    value: amount.displayString,
                    style: leadingItemStyle
                ))
            ]
        ))
    }

    fileprivate func coinPriceRow() -> ItemType {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        let trailingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .title
        )

        return ItemType.compositionView(.init(
            leading: [.text(.init(
                value: "\(amount.displayCode) \(LocalizationConstants.SuperApp.ActivityDetails.priceLabel)",
                style: leadingItemStyle
            ))],
            trailing: [
                .text(.init(
                    value: price.displayString,
                    style: trailingItemStyle
                ))
            ]
        ))
    }

    fileprivate func totalRow() -> ItemType {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        let trailingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .title
        )

        return ItemType.compositionView(.init(
            leading: [.text(.init(
                value: LocalizationConstants.SuperApp.ActivityDetails.totalLabel,
                style: leadingItemStyle
            ))],
            trailing: [
                .text(.init(
                    value: valuePair.quote.toDisplayString(includeSymbol: true),
                    style: trailingItemStyle
                )),
                .text(.init(
                    value: amount.displayString,
                    style: leadingItemStyle
                ))
            ]
        ))
    }

    fileprivate func statusRow() -> ItemType {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        return ItemType.compositionView(.init(
            leading: [.text(.init(
                value: LocalizationConstants.SuperApp.ActivityDetails.statusLabel,
                style: leadingItemStyle
            ))],
            trailing: [
                state.toBadge()
            ]
        ))
    }

    fileprivate func fromRow() -> ItemType {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        let trailingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .title
        )

        return ItemType.compositionView(.init(
            leading: [.text(.init(
                value: LocalizationConstants.SuperApp.ActivityDetails.fromLabel,
                style: leadingItemStyle
            ))],
            trailing: [
                .text(.init(
                    value: receivingAddress ?? "",
                    style: trailingItemStyle
                ))
            ]
        ))
    }

    // TODO: Figure out network
    fileprivate func networkRow() -> ItemType {
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
                        value: LocalizationConstants.SuperApp.ActivityDetails.networkLabel,
                        style: leadingItemStyle
                    ))],
            trailing: [
                .text(
                    .init(
                        value: amount.displayCode,
                        style: trailingItemStyle
                    ))
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
                    ))],
            trailing: [
                .text(
                    .init(
                        value: DateFormatter.elegantDateFormatter.string(from: date),
                        style: trailingItemStyle
                    ))
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
                    ))],
            trailing: [
                .text(
                    .init(
                        value: txHash,
                        style: trailingItemStyle
                    ))
            ]
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

    fileprivate func title() -> String {
        switch type {
        case .withdrawal:
            return "\(LocalizationConstants.SuperApp.ActivityDetails.cashedOut) \(amount.displayCode)"
        case .deposit:
            return "\(LocalizationConstants.SuperApp.ActivityDetails.added) \(amount.displayCode)"
        }
    }

    fileprivate func totalRow() -> ItemType {
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
                        value: LocalizationConstants.SuperApp.ActivityDetails.totalLabel,
                        style: leadingItemStyle
                    ))],
            trailing: [
                .text(
                    .init(
                        value: amount.toDisplayString(includeSymbol: true),
                        style: trailingItemStyle
                    ))
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
                    ))],
            trailing: [
                state.toBadge()
            ]
        ))
    }

    // TODO: Get bank/payment details. The enum needs to be enriched with the id of the payment and another call needs to be made for the details. Does not seem efficient, the BE should supply this
    //    func fromRow() -> ItemType {
    //        let leadingItemStyle = ActivityItem.Text.Style(typography: .paragraph2,
    //                                                       color: .text)
    //
    //        let trailingItemStyle = ActivityItem.Text.Style(typography: .paragraph2,
    //                                                        color: .title)
    //        var fromString = ""
    //
    //
    //
    //        return ItemType.compositionView(.init(leading: [.text(.init(value: "From",
    //                                                                    style: leadingItemStyle))],
    //                                              trailing: [.text(.init(value: receivingAddress ?? "",
    //                                                                     style: trailingItemStyle))
    //                                                        ]))
    //    }

    //    func toRow() -> ItemType {
    //        let leadingItemStyle = ActivityItem.Text.Style(typography: .paragraph2,
    //                                                       color: .text)
    //
    //        let trailingItemStyle = ActivityItem.Text.Style(typography: .paragraph2,
    //                                                        color: .title)
    //        var fromString = ""
    //
    //
    //
    //        return ItemType.compositionView(.init(leading: [.text(.init(value: "From",
    //                                                                    style: leadingItemStyle))],
    //                                              trailing: [.text(.init(value: receivingAddress ?? "",
    //                                                                     style: trailingItemStyle))
    //                                                        ]))
    //    }

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
                    ))],
            trailing: [
                .text(
                    .init(
                        value: DateFormatter.elegantDateFormatter.string(from: date),
                        style: trailingItemStyle
                    ))
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
                    ))],
            trailing: [
                .text(
                    .init(
                        value: identifier,
                        style: trailingItemStyle
                    ))
            ]
        ))
    }
}

// MARK: Buy/Sell activity extensions

extension BuySellActivityItemEvent.EventStatus {
    fileprivate func toBadge() -> LeafItemType {
        switch self {
        case .pending:
            return LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.pendingStatus,
                    style: .default
                ))
        case .failed:
            return LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.failedStatus,
                    style: .error
                ))
        case .finished:
            return LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.completeStatus,
                    style: .success
                ))
        case .pendingConfirmation:
            return LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.pendingStatus,
                    style: .default
                ))
        default:
            return LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.pendingStatus,
                    style: .default
                ))
        }
    }
}

extension BuySellActivityItemEvent.PaymentMethod {
    fileprivate func toString() -> String {
        switch self {
        case .applePay:
            return LocalizationConstants.SuperApp.ActivityDetails.paymentMethodApplePay
        case .bankAccount:
            return LocalizationConstants.SuperApp.ActivityDetails.paymentMethodBankAccount
        case .funds:
            return LocalizationConstants.SuperApp.ActivityDetails.paymentMethodFunds
        case .card:
            return LocalizationConstants.SuperApp.ActivityDetails.paymentMethodCard
        case .bankTransfer:
            return LocalizationConstants.SuperApp.ActivityDetails.paymentMethodBankTransfer
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

    fileprivate func title() -> String {
        "\(isBuy ? LocalizationConstants.Activity.MainScreen.Item.buy : LocalizationConstants.Activity.MainScreen.Item.sell) \(outputValue.currency.displayCode)"
    }

    fileprivate func purchaseRow() -> ItemType {
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
                        value: LocalizationConstants.SuperApp.ActivityDetails.purchaseLabel,
                        style: leadingItemStyle
                    ))],
            trailing: [
                .text(
                    .init(
                        value: inputValue.displayString,
                        style: trailingItemStyle
                    ))
            ]
        ))
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
                    ))],
            trailing: [
                .text(
                    .init(
                        value: outputValue.displayString,
                        style: trailingItemStyle
                    ))
            ]
        ))
    }

    fileprivate func coinPriceRow() -> ItemType {
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
                        value: "\(outputValue.displayCode) \(LocalizationConstants.SuperApp.ActivityDetails.priceLabel)",
                        style: leadingItemStyle
                    ))],
            trailing: [
                .text(
                    .init(
                        value: price?.displayString ?? "",
                        style: trailingItemStyle
                    ))
            ]
        ))
    }

    fileprivate func feeRow() -> ItemType {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        let trailingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .title
        )

        let feeType: LeafItemType = fee.isZero ?
            .badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.free,
                    style: .success
                )) :
            .text(
                .init(
                    value: fee.displayString,
                    style: trailingItemStyle
                ))

        return ItemType.compositionView(.init(
            leading: [
                .text(
                    .init(
                        value: LocalizationConstants.SuperApp.ActivityDetails.feeLabel,
                        style: leadingItemStyle
                    ))],
            trailing: [feeType]
        ))
    }

    fileprivate func paymentTypeRow() -> ItemType {
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
                        value: LocalizationConstants.SuperApp.ActivityDetails.paymentTypeLabel,
                        style: leadingItemStyle
                    ))],
            trailing: [
                .text(
                    .init(
                        value: paymentMethod.toString(),
                        style: trailingItemStyle))
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
                    ))],
            trailing: [
                status.toBadge()
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
                    ))],
            trailing: [
                .text(
                    .init(
                        value: DateFormatter.elegantDateFormatter.string(from: creationDate),
                        style: trailingItemStyle
                    ))
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
                    ))],
            trailing: [
                .text(
                    .init(
                        value: identifier,
                        style: trailingItemStyle
                    ))
            ]
        ))
    }
}

// MARK: Swap activity extensions

extension SwapActivityItemEvent.EventStatus {
    fileprivate func toBadge() -> LeafItemType {
        switch self {
        case .inProgress:
            return LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.pendingStatus,
                    style: .default
                ))
        case .failed:
            return LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.failedStatus,
                    style: .error
                ))
        case .complete:
            return LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.completeStatus,
                    style: .success
                ))
        case .pendingRefund:
            return LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.pendingStatus,
                    style: .default
                ))
        default:
            return LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.pendingStatus,
                    style: .default
                ))
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

    fileprivate func title() -> String {
        "\(LocalizationConstants.Activity.MainScreen.Item.swap) \(pair.inputCurrencyType.code) -> \(pair.outputCurrencyType.code)"
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
                    ))],
            trailing: [
                .text(
                    .init(
                        value: amounts.deposit.displayString,
                        style: trailingItemStyle
                    ))]
        ))
    }

    fileprivate func forRow() -> ItemType {
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
                        value: LocalizationConstants.SuperApp.ActivityDetails.forLabel,
                        style: leadingItemStyle
                    ))],
            trailing: [
                .text(
                    .init(
                        value: amounts.withdrawal.displayString,
                        style: trailingItemStyle
                    ))]
        ))
    }

    // TODO: Figure out exchange row
    fileprivate func exchangeRow() -> ItemType {
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
                        value: LocalizationConstants.SuperApp.ActivityDetails.exchangeLabel,
                        style: leadingItemStyle
                    ))],
            trailing: [
                .text(
                    .init(
                        value: amounts.withdrawal.displayString,
                        style: trailingItemStyle
                    ))]
        ))
    }

    fileprivate func feeRow() -> ItemType {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        let trailingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .title
        )

        let feeType: LeafItemType = amounts.withdrawalFee.isZero ?
            .badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.free,
                    style: .success
                )) :
            .text(
                .init(
                    value: amounts.withdrawalFee.displayString,
                    style: trailingItemStyle
                ))

        return ItemType.compositionView(.init(
            leading: [
                .text(
                    .init(
                        value: LocalizationConstants.SuperApp.ActivityDetails.feeLabel,
                        style: leadingItemStyle
                    ))],
            trailing: [feeType]
        ))
    }

    fileprivate func totalRow() -> ItemType {
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
                        value: LocalizationConstants.SuperApp.ActivityDetails.totalLabel,
                        style: leadingItemStyle
                    ))],
            trailing: [
                .text(
                    .init(
                        value: amounts.fiatValue.displayString,
                        style: trailingItemStyle
                    ))]
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
                    ))],
            trailing: [
                status.toBadge()
            ]
        ))
    }

    fileprivate func fromRow() -> ItemType {
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
                    ))],
            trailing: [
                .text(
                    .init(
                        value: (kind.depositAddress ?? kind.depositTxHash) ?? "",
                        style: trailingItemStyle
                    ))]
        ))
    }

    fileprivate func toRow() -> ItemType {
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
                    ))],
            trailing: [
                .text(
                    .init(
                        value: kind.depositAddress ?? kind.depositTxHash ?? "",
                        style: trailingItemStyle
                    ))]
        ))
    }

    // TODO: Check network
    fileprivate func networkRow() -> ItemType {
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
                        value: LocalizationConstants.SuperApp.ActivityDetails.networkLabel,
                        style: leadingItemStyle
                    ))],
            trailing: [
                .text(
                    .init(
                        value: pair.outputCurrencyType.displayCode,
                        style: trailingItemStyle
                    ))]
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
                    ))],
            trailing: [
                .text(
                    .init(
                        value: DateFormatter.elegantDateFormatter.string(from: date),
                        style: trailingItemStyle
                    ))
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
                    ))],
            trailing: [
                .text(
                    .init(
                        value: identifier,
                        style: trailingItemStyle
                    ))
            ]
        ))
    }
}
