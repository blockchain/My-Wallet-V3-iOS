// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureStakingDomain
import Foundation
import Localization
import MoneyKit
import PlatformKit
import ToolKit
import UnifiedActivityDomain

private func explorerUrl(currency: CurrencyType) -> String? {
    guard currency.isCryptoCurrency else {
        return nil
    }
    guard currency == .crypto(.bitcoin) || currency == .crypto(.bitcoinCash) || currency == .crypto(.ethereum) else {
        return nil
    }
    return "https://www.blockchain.com/\(currency.code.lowercased())/tx"
}

public enum ActivityDetailsAdapter {
    public static func createActivityDetails(with activity: CustodialActivityEvent.Crypto) -> ActivityDetail.GroupedItems {
        let group1 = ActivityDetail.GroupedItems.Item(
            title: "",
            itemGroup: [
                activity.amountRow(),
                activity.coinPriceRow(),
                activity.proccessingFee(),
                activity.totalRow()
            ].compactMap { $0 }
        )

        let itemsGroup2 = [
            activity.statusRow(),
            activity.fromRow(),
            activity.toRow()
        ].compactMap { $0 }

        let group2 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: itemsGroup2)

        let copyAction = ItemType.leaf(.button(.init(
            text: LocalizationConstants.SuperApp.ActivityDetails.copyTransactionButtonLabel,
            style: .secondary,
            actionType: .copy,
            actionData: activity.identifier
        )))

        let group3 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.dateRow(),
            activity.transactionIdRow(),
            copyAction
        ])

        let copyHashAction = ItemType.leaf(.button(.init(
            text: LocalizationConstants.SuperApp.ActivityDetails.copyTransactionHashButtonLabel,
            style: .secondary,
            actionType: .copy,
            actionData: activity.txHash
        )))

        let group4 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.transactionHashRow(),
            copyHashAction
        ])

        let normalizedTxHash = activity.txHash.splitIfNotEmpty(separator: ":").first.map(String.init)
        let txHash = normalizedTxHash ?? activity.txHash
        let floatingActions: [ActivityItem.Button]
        if let url = activity.amount.currency.network()?.networkConfig.explorerUrl ?? explorerUrl(currency: activity.amount.currencyType), txHash.isNotEmpty {
            floatingActions = [
                ActivityItem.Button(
                    text: LocalizationConstants.SuperApp.ActivityDetails.viewOnExplorer,
                    style: .secondary,
                    actionType: .opneURl,
                    actionData: "\(url)/\(txHash)"
                )
            ]
        } else {
            floatingActions = []
        }

        return ActivityDetail.GroupedItems(
            title: activity.title(),
            icon: activity.leadingImage(),
            itemGroups: [group1, group2, group3, group4],
            floatingActions: floatingActions
        )
    }

    public static func createActivityDetails(with activity: CustodialActivityEvent.Fiat) -> ActivityDetail.GroupedItems {
        let group1 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.totalRow()
        ])

        let group2 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.statusRow()
        ])

        let copyAction = ItemType.leaf(.button(.init(
            text: LocalizationConstants.SuperApp.ActivityDetails.copyTransactionButtonLabel,
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

    public static func createActivityDetails(with activity: BuySellActivityItemEvent) -> ActivityDetail.GroupedItems {
        let items = [
            activity.purchaseRow(),
            activity.amountRow(),
            activity.coinPriceRow(),
            activity.feeRow()
        ].compactMap { $0 }

        let group1 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: items)

        let group2 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.statusRow(),
            activity.paymentTypeRow()
        ])

        let copyAction = ItemType.leaf(.button(.init(
            text: LocalizationConstants.SuperApp.ActivityDetails.copyTransactionButtonLabel,
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

        let items = [
            activity.statusRow(),
            activity.fromRow(),
            activity.toRow()
        ].compactMap { $0 }

        let group2 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: items)

        let copyAction = ItemType.leaf(.button(.init(
            text: LocalizationConstants.SuperApp.ActivityDetails.copyTransactionButtonLabel,
            style: .secondary,
            actionType: .copy,
            actionData: activity.identifier
        )))

        let group3 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
            activity.dateRow(),
            activity.transactionIdRow(),
            copyAction
        ])

        var group4: ActivityDetail.GroupedItems.Item?
        if let hashRow = activity.transactionHashRow() {
            let copyHashAction = ItemType.leaf(.button(.init(
                text: LocalizationConstants.SuperApp.ActivityDetails.copyTransactionHashButtonLabel,
                style: .secondary,
                actionType: .copy,
                actionData: activity.identifier
            )))
            group4 = ActivityDetail.GroupedItems.Item(title: "", itemGroup: [
                hashRow,
                copyHashAction
            ])
        }

        let normalizedTxHash = activity.withdrawalTxHash?.splitIfNotEmpty(separator: ":").first.map(String.init)
        let txHash = normalizedTxHash ?? activity.withdrawalTxHash ?? ""
        let floatingActions: [ActivityItem.Button]
        let explorerFromNetwork = activity.amounts.withdrawal.currency.cryptoCurrency?.network()?.networkConfig.explorerUrl
        if let url = explorerFromNetwork ?? explorerUrl(currency: activity.amounts.withdrawal.currency), txHash.isNotEmpty {
            floatingActions = [
                ActivityItem.Button(
                    text: LocalizationConstants.SuperApp.ActivityDetails.viewOnExplorer,
                    style: .secondary,
                    actionType: .opneURl,
                    actionData: "\(url)/\(txHash)"
                )
            ]
        } else {
            floatingActions = []
        }

        let itemGroups: [ActivityDetail.GroupedItems.Item] = if let group4 {
            [group1, group2, group3, group4]
        } else {
            [group1, group2, group3]
        }
        return ActivityDetail.GroupedItems(
            title: activity.title(),
            icon: activity.leadingImage(),
            itemGroups: itemGroups,
            floatingActions: floatingActions
        )
    }
}

// MARK: Custodial crypto activity extensions

extension CustodialActivityEvent.State {
    fileprivate func toBadge() -> LeafItemType {
        switch self {
        case .completed:
            LeafItemType.badge(.init(value: rawValue.capitalized, style: .success))
        case .failed:
            LeafItemType.badge(.init(value: rawValue.capitalized, style: .error))
        case .pending:
            LeafItemType.badge(.init(value: rawValue.capitalized, style: .default))
        }
    }
}

extension CustodialActivityEvent.Crypto {
    fileprivate func leadingImage() -> ImageType {
        switch type {
        case .withdrawal:
            if let networkIcon = amount.currency.logoURL?.absoluteString {
                ImageType.smallTag(.init(main: networkIcon, tag: ActivityRemoteIcons.send.url(mode: .dark)))
            } else {
                ImageType.smallTag(.init(main: ActivityRemoteIcons.send.url(mode: .dark)))
            }
        case .deposit:
            if let networkIcon = amount.currency.logoURL?.absoluteString {
                ImageType.smallTag(.init(main: networkIcon, tag: ActivityRemoteIcons.receive.url(mode: .dark)))
            } else {
                ImageType.smallTag(.init(main: ActivityRemoteIcons.receive.url(mode: .dark)))
            }
        }
    }

    fileprivate func title() -> String {
        switch type {
        case .withdrawal:
            "\(LocalizationConstants.Activity.MainScreen.Item.withdrew) \(amount.displayCode)"
        case .deposit:
            "\(LocalizationConstants.Activity.MainScreen.Item.receive) \(amount.displayCode)"
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

        return ItemType.compositionView(
            .init(
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
                            value: valuePair.quote.toDisplayString(includeSymbol: true),
                            style: trailingItemStyle
                        )
                    ),
                    .text(
                        .init(
                            value: amount.displayString,
                            style: leadingItemStyle
                        )
                    )
                ]
            )
        )
    }

    fileprivate func proccessingFee() -> ItemType? {
        guard type == .withdrawal else {
            return nil
        }
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        let trailingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .title
        )

        return ItemType.compositionView(
            .init(
                leading: [
                    .text(
                        .init(
                            value: LocalizationConstants.SuperApp.ActivityDetails.processingFeeLabel,
                            style: leadingItemStyle
                        )
                    )
                ],
                trailing: [
                    .text(
                        .init(
                            value: fee.convert(using: price).toDisplayString(includeSymbol: true),
                            style: trailingItemStyle
                        )
                    ),
                    .text(
                        .init(
                            value: fee.toDisplayString(includeSymbol: true),
                            style: leadingItemStyle
                        )
                    )
                ]
            )
        )
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

        return ItemType.compositionView(
            .init(
                leading: [
                    .text(
                        .init(
                            value: "\(amount.displayCode) \(LocalizationConstants.SuperApp.ActivityDetails.priceLabel)",
                            style: leadingItemStyle
                        )
                    )
                ],
                trailing: [
                    .text(
                        .init(
                            value: price.displayString,
                            style: trailingItemStyle
                        )
                    )
                ]
            )
        )
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

        let totalInCrypto: CryptoValue
        do {
            totalInCrypto = try amount + fee
        } catch {
            totalInCrypto = amount
        }
        let total = MoneyValue(cryptoValue: totalInCrypto)
        let totalInFiat = total.convert(using: price)

        return ItemType.compositionView(
            .init(
                leading: [
                    .text(
                        .init(
                            value: LocalizationConstants.SuperApp.ActivityDetails.totalLabel,
                            style: leadingItemStyle
                        )
                    )
                ],
                trailing: [
                    .text(
                        .init(
                            value: totalInFiat.toDisplayString(includeSymbol: true),
                            style: trailingItemStyle
                        )
                    ),
                    .text(
                        .init(
                            value: total.toDisplayString(includeSymbol: true),
                            style: leadingItemStyle
                        )
                    )
                ]
            )
        )
    }

    fileprivate func statusRow() -> ItemType {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        return ItemType.compositionView(
            .init(
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
            )
        )
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

        let source: String = switch type {
        case .deposit:
            "\(amount.displayCode) \(LocalizationConstants.SuperApp.ActivityDetails.wallet)"
        case .withdrawal:
            LocalizationConstants.SuperApp.ActivityDetails.blockchainAccount
        }

        return ItemType.compositionView(
            .init(
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
                            value: source,
                            style: trailingItemStyle
                        )
                    )
                ]
            )
        )
    }

    fileprivate func toRow() -> ItemType? {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        let trailingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .title
        )

        let destination: String = switch type {
        case .deposit:
            LocalizationConstants.SuperApp.ActivityDetails.blockchainAccount
        case .withdrawal:
            receivingAddress ?? "\(amount.displayCode) \(LocalizationConstants.SuperApp.ActivityDetails.wallet)"
        }
        return ItemType.compositionView(
            .init(
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
                            value: destination,
                            style: trailingItemStyle
                        )
                    )
                ]
            )
        )
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
                        value: DateFormatter.elegantDateFormatter.string(from: date),
                        style: trailingItemStyle
                    )
                )
            ]
        ))
    }

    fileprivate func transactionIdRow() -> ItemType {
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
                        value: identifier,
                        style: trailingItemStyle
                    )
                )
            ]
        ))
    }

    fileprivate func transactionHashRow() -> ItemType {
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
                        value: LocalizationConstants.SuperApp.ActivityDetails.transactionHashLabel,
                        style: leadingItemStyle
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: txHash,
                        style: trailingItemStyle
                    )
                )
            ]
        ))
    }
}

extension CustodialActivityEvent.Fiat {
    fileprivate func leadingImage() -> ImageType {
        switch type {
        case .withdrawal:
            ImageType.smallTag(.init(main: ActivityRemoteIcons.send.url(mode: .dark)))
        case .deposit:
            ImageType.smallTag(.init(main: ActivityRemoteIcons.receive.url(mode: .dark)))
        }
    }

    fileprivate func title() -> String {
        switch type {
        case .withdrawal:
            "\(LocalizationConstants.SuperApp.ActivityDetails.cashedOut) \(amount.displayCode)"
        case .deposit:
            "\(LocalizationConstants.SuperApp.ActivityDetails.added) \(amount.displayCode)"
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
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: amount.toDisplayString(includeSymbol: true),
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
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: DateFormatter.elegantDateFormatter.string(from: date),
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
                        value: identifier,
                        style: trailingItemStyle
                    )
                )
            ]
        ))
    }
}

// MARK: Buy/Sell activity extensions

extension BuySellActivityItemEvent.EventStatus {
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
        case .finished:
            LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.completeStatus,
                    style: .success
                ))
        case .pendingConfirmation:
            LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.pendingStatus,
                    style: .default
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

extension BuySellActivityItemEvent.PaymentMethod {
    fileprivate func toString() -> String {
        switch self {
        case .applePay:
            LocalizationConstants.SuperApp.ActivityDetails.paymentMethodApplePay
        case .bankAccount:
            LocalizationConstants.SuperApp.ActivityDetails.paymentMethodBankAccount
        case .funds:
            LocalizationConstants.SuperApp.ActivityDetails.paymentMethodFunds
        case .card:
            LocalizationConstants.SuperApp.ActivityDetails.paymentMethodCard
        case .bankTransfer:
            LocalizationConstants.SuperApp.ActivityDetails.paymentMethodBankTransfer
        }
    }
}

extension BuySellActivityItemEvent {
    fileprivate func leadingImage() -> ImageType {
        if isBuy {
            if let logoURL = outputValue.currency.cryptoCurrency?.logoURL?.absoluteString {
                ImageType.smallTag(.init(main: logoURL, tag: ActivityRemoteIcons.buy.url(mode: .dark)))
            } else {
                ImageType.smallTag(.init(main: ActivityRemoteIcons.buy.url(mode: .dark)))
            }
        } else {
            if let logoURL = inputValue.currency.cryptoCurrency?.logoURL?.absoluteString {
                ImageType.smallTag(.init(main: logoURL, tag: ActivityRemoteIcons.sell.url(mode: .dark)))
            } else {
                ImageType.smallTag(.init(main: ActivityRemoteIcons.sell.url(mode: .dark)))
            }
        }
    }

    fileprivate func title() -> String {
        guard isBuy else {
            return "\(LocalizationConstants.Activity.MainScreen.Item.sell) \(inputValue.currency.displayCode)"
        }
        return "\(LocalizationConstants.Activity.MainScreen.Item.buy) \(outputValue.currency.displayCode)"
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

        let leadingTitle = isBuy
        ? LocalizationConstants.SuperApp.ActivityDetails.purchaseLabel
        : LocalizationConstants.SuperApp.ActivityDetails.saleLabel

        let valueTitle = isBuy
        ? inputValue.displayString
        : outputValue.displayString

        return ItemType.compositionView(.init(
            leading: [
                .text(
                    .init(
                        value: leadingTitle,
                        style: leadingItemStyle
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: valueTitle,
                        style: trailingItemStyle
                    )
                )
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

        let valueTitle = isBuy
        ? outputValue.displayString
        : inputValue.displayString

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
                        value: valueTitle,
                        style: trailingItemStyle
                    )
                )
            ]
        ))
    }

    fileprivate func coinPriceRow() -> ItemType? {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        let trailingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .title
        )

        if let displayPrice = price?.displayString {
            return ItemType.compositionView(.init(
                leading: [
                    .text(
                        .init(
                            value: "\(outputValue.displayCode) \(LocalizationConstants.SuperApp.ActivityDetails.priceLabel)",
                            style: leadingItemStyle
                        ))
                ],
                trailing: [
                    .text(
                        .init(
                            value: displayPrice,
                            style: trailingItemStyle
                        )
                    )
                ]
            ))
        }

        return nil
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
                    ))
            ],
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
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: paymentMethod.toString(),
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
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: DateFormatter.elegantDateFormatter.string(from: creationDate),
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
                        value: identifier,
                        style: trailingItemStyle
                    )
                )
            ]
        ))
    }
}

// MARK: Swap activity extensions

extension SwapActivityItemEvent.EventStatus {
    fileprivate func toBadge() -> LeafItemType {
        switch self {
        case .inProgress:
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
        case .pendingRefund:
            LeafItemType.badge(
                .init(
                    value: LocalizationConstants.SuperApp.ActivityDetails.pendingStatus,
                    style: .default
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

extension SwapActivityItemEvent {
    fileprivate func leadingImage() -> ImageType {
        if let inputLogoUrl = pair.inputCurrencyType.cryptoCurrency?.logoURL?.absoluteString,
            let outputLogoUrl = pair.outputCurrencyType.cryptoCurrency?.logoURL?.absoluteString
        {
            ImageType.overlappingPair(
                .init(back: outputLogoUrl, front: inputLogoUrl)
            )
        } else {
            ImageType.smallTag(
                .init(
                    main: ActivityRemoteIcons.swap.url(mode: .dark),
                    tag: nil
                )
            )
        }
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
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: amounts.deposit.displayString,
                        style: trailingItemStyle
                    )
                )
            ]
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
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: amounts.withdrawal.displayString,
                        style: trailingItemStyle
                    )
                )
            ]
        ))
    }

    fileprivate func exchangeRow() -> ItemType {
        let exchangeRate: MoneyValuePair = MoneyValuePair(base: amounts.deposit, quote: amounts.withdrawal).exchangeRate

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
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: "\(exchangeRate.quote.displayString)/\(exchangeRate.base.displayCode)",
                        style: trailingItemStyle
                    )
                )
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
                    )
                )
            ],
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
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: amounts.fiatValue.displayString,
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
                status.toBadge()
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

        if let depositHash = depositTxHash {
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
                            value: depositHash,
                            style: trailingItemStyle
                        )
                    )
                ]
            ))
        }

        return nil
    }

    fileprivate func toRow() -> ItemType? {
        let leadingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .text
        )

        let trailingItemStyle = ActivityItem.Text.Style(
            typography: .paragraph2,
            color: .title
        )

        if let withdrawalAddress = kind.withdrawalAddress {
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
                            value: withdrawalAddress,
                            style: trailingItemStyle
                        )
                    )
                ]
            ))
        }

        return nil
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
                        value: DateFormatter.elegantDateFormatter.string(from: date),
                        style: trailingItemStyle
                    )
                )
            ]
        ))
    }

    fileprivate func transactionIdRow() -> ItemType {
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
                        value: identifier,
                        style: trailingItemStyle
                    )
                )
            ]
        ))
    }

    fileprivate func transactionHashRow() -> ItemType? {
        guard withdrawalTxHash.isNotNilOrEmpty, depositTxHash.isNotNilOrEmpty else {
            return nil
        }
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
                        value: LocalizationConstants.SuperApp.ActivityDetails.transactionHashLabel,
                        style: leadingItemStyle
                    )
                )
            ],
            trailing: [
                .text(
                    .init(
                        value: withdrawalTxHash ?? depositTxHash ?? "",
                        style: trailingItemStyle
                    )
                )
            ]
        ))
    }
}
