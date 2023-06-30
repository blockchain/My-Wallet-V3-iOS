// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import Errors
import ErrorsUI
import FeatureAccountPickerDomain
import Localization
import MoneyKit
import PlatformKit
import SwiftUI
import ToolKit
import UIComponentsKit

struct AccountPickerRowView<
    BadgeView: View,
    DescriptionView: View,
    IconView: View,
    MultiBadgeView: View,
    WithdrawalLocksView: View
>: View {

    // MARK: - Internal properties

    let model: AccountPickerRow
    let send: (SuccessRowsAction) -> Void
    let badgeView: (AnyHashable) -> BadgeView
    let descriptionView: (AnyHashable) -> DescriptionView
    let iconView: (AnyHashable) -> IconView
    let multiBadgeView: (AnyHashable) -> MultiBadgeView
    let withdrawalLocksView: () -> WithdrawalLocksView
    let fiatBalance: String?
    let cryptoBalance: String?
    let currencyCode: String?
    let lastItem: Bool

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            switch model {
            case .label(let model):
                Text(model.text)
            case .accountGroup(let model):
                AccountGroupRow(
                    model: model,
                    badgeView: badgeView(model.id),
                    fiatBalance: fiatBalance,
                    currencyCode: currencyCode
                )
                .backport
                .addPrimaryDivider()
            case .button(let model):
                ButtonRow(model: model) {
                    send(.accountPickerRowDidTap(model.id))
                }
            case .linkedBankAccount(let model):
                LinkedBankAccountRow(
                    model: model,
                    badgeView: badgeView(model.id),
                    multiBadgeView: multiBadgeView(model.id)
                )
                .backport
                .addPrimaryDivider()
            case .paymentMethodAccount(let model):
                PaymentMethodRow(
                    model: model,
                    badgeTapped: { ux in
                        send(.ux(ux))
                    }
                )
                .backport
                .addPrimaryDivider()
            case .singleAccount(let model):
                SingleAccountRow(
                    model: model,
                    badgeView: badgeView(model.id),
                    descriptionView: descriptionView(model.id),
                    iconView: iconView(model.id),
                    multiBadgeView: multiBadgeView(model.id),
                    fiatBalance: fiatBalance,
                    cryptoBalance: cryptoBalance
                )
                .if(!lastItem, then: { view in
                    view
                        .backport
                        .addPrimaryDivider()
                })
            case .withdrawalLocks:
                withdrawalLocksView()
            }
        }
        .onTapGesture {
            send(.accountPickerRowDidTap(model.id))
        }
        .listRowInsets(EdgeInsets())
        .backport
        .hideListRowSeparator()
    }
}

// MARK: - Specific Rows

private struct AccountGroupRow<BadgeView: View>: View {

    let model: AccountPickerRow.AccountGroup
    let badgeView: BadgeView
    let fiatBalance: String?
    let currencyCode: String?

    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 16) {
                badgeView
                    .frame(width: 32, height: 32)
                    .padding(6)
                VStack {
                    HStack {
                        Text(model.title)
                            .typography(.body1)
                            .foregroundColor(.semantic.title)
                        Spacer()
                        Text(fiatBalance ?? " ")
                            .typography(.body1)
                            .foregroundColor(.semantic.title)
                            .shimmer(
                                enabled: fiatBalance == nil,
                                width: 90
                            )
                    }
                    HStack {
                        Text(model.description)
                            .typography(.paragraph1)
                            .foregroundColor(.semantic.body)
                        Spacer()
                        Text(currencyCode ?? " ")
                            .typography(.paragraph1)
                            .foregroundColor(.semantic.body)
                            .shimmer(
                                enabled: currencyCode == nil,
                                width: 100
                            )
                    }
                }
            }
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        }
    }
}

private struct ButtonRow: View {

    let model: AccountPickerRow.Button
    let action: () -> Void

    var body: some View {
        VStack {
            MinimalButton(title: model.text) {
                action()
            }
            .frame(height: ButtonSize.Standard.height)
        }
        .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
    }
}

private struct LinkedBankAccountRow<BadgeView: View, MultiBadgeView: View>: View {

    let model: AccountPickerRow.LinkedBankAccount
    let badgeView: BadgeView
    let multiBadgeView: MultiBadgeView

    @State private var action: AssetAction?

    var isDisabled: Bool {
        (action == .withdraw && model.capabilities?.withdrawal?.enabled == false)
            || ((action == .buy || action == .deposit) && model.capabilities?.deposit?.enabled == false)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    badgeView
                        .frame(width: 32, height: 32)
                        .padding(6)
                    Spacer()
                        .frame(width: 16)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(model.title)
                                .typography(.body1)
                                .foregroundColor(.semantic.title)
                            Text(model.description)
                                .typography(.paragraph1)
                                .foregroundColor(.semantic.body)
                        }
                    }
                    Spacer()
                }

                multiBadgeView
                    .padding(.top, 8)
            }
            .padding(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 24))
        }
        .bindings {
            subscribe($action, to: blockchain.ux.transaction.id)
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
    }
}

private struct PaymentMethodRow: View {

    @BlockchainApp var app
    @State var isCardsSuccessRateEnabled: Bool = false
    @State private var action: AssetAction?

    let model: AccountPickerRow.PaymentMethod
    let badgeTapped: (UX.Dialog) -> Void

    var isDisabled: Bool {
        (action == .withdraw && model.capabilities?.withdrawal?.enabled == false)
            || ((action == .buy || action == .deposit) && model.capabilities?.deposit?.enabled == false)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 0) {
                ZStack {
                    if let url = model.badgeURL {
                        AsyncMedia(url: url)
                            .frame(width: 24, height: 24)
                    } else {
                        model.badgeView
                            .frame(width: 24, height: 24)
                            .scaledToFit()
                    }
                }
                .frame(width: 24, height: 24)
                .padding(6)
                .background(model.badgeBackground)
                .clipShape(Circle())

                Spacer()
                    .frame(width: 16)

                VStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(model.title)
                            .typography(.body1)
                            .foregroundColor(.semantic.title)
                        Text(model.description)
                            .typography(.paragraph1)
                            .foregroundColor(.semantic.body)
                    }
                }
                .offset(x: 0, y: -2) // visually align due to font padding
                Spacer()
            }
            .task {
                do {
                    isCardsSuccessRateEnabled = try await app.get(blockchain.app.configuration.card.success.rate.is.enabled)
                } catch {
                    app.post(error: error)
                }
            }
            if let ux = model.ux, isCardsSuccessRateEnabled {
                BadgeView(title: ux.title, style: model.block ? .error : .warning)
                    .onTapGesture {
                        badgeTapped(ux)
                    }
                    .padding(.leading, 64.pt)
                    .frame(height: 24.pt)
            }
        }
        .bindings {
            subscribe($action, to: blockchain.ux.transaction.id)
        }
        .padding(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 24))
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
    }
}

private struct SingleAccountRow<
    BadgeView: View,
    DescriptionView: View,
    IconView: View,
    MultiBadgeView: View
>: View {

    @State var price: MoneyValue?
    @State var todayPrice: MoneyValue?
    @State var yesterdayPrice: MoneyValue?
    @State var fastRisingMinDelta: Double?

    var delta: Decimal? {
        guard let todayPrice, let yesterdayPrice, let delta = try? MoneyValue.delta(yesterdayPrice, todayPrice) else {
            return nil
        }
        return delta / 100
    }

    var priceChangeString: String? {
        guard let delta else {
            return nil
        }
        var arrowString: String {
            if delta.isZero {
                return ""
            }
            if delta.isSignMinus {
                return "↓"
            }

            return "↑"
        }

        if #available(iOS 15.0, *) {
            let deltaFormatted = delta.formatted(.percent.precision(.fractionLength(2)))
            return "\(arrowString) \(deltaFormatted)"
        } else {
            return "\(arrowString) \(delta) %"
        }
    }

    var titleString: String? {
        transactionFlowAction == .buy ? price?.toDisplayString(includeSymbol: true) : fiatBalance
    }

    var descriptionString: String? {
        transactionFlowAction == .buy ?
       priceChangeString : cryptoBalance
    }

    var descriptionColor: Color? {
        guard let delta else {
            return nil
        }

        guard transactionFlowAction == .buy else {
            return Color.semantic.body
        }

        if delta.isSignMinus {
            return Color.semantic.pink
        } else if delta.isZero {
            return Color.semantic.body
        } else {
            return Color.semantic.success
        }
    }

    @State var transactionFlowAction: AssetAction?
    let model: AccountPickerRow.SingleAccount
    let badgeView: BadgeView
    let descriptionView: DescriptionView
    let iconView: IconView
    let multiBadgeView: MultiBadgeView
    let fiatBalance: String?
    let cryptoBalance: String?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        badgeView
                            .frame(width: 32, height: 32)
                    }
                    .padding(6)

                    iconView
                        .frame(width: 16, height: 16)
                }
                Spacer()
                    .frame(width: 16)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(model.title)
                            .typography(.body1)
                            .foregroundColor(.semantic.title)
                            .scaledToFill()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        descriptionView
                    }

                    if Decimal((fastRisingMinDelta ?? 100) / 100).isLessThanOrEqualTo(delta ?? 0), transactionFlowAction == .buy {
                        Icon
                            .fireFilled
                            .micro()
                            .color(.semantic.warningMuted)
                    }

                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(titleString ?? "")
                            .typography(.body1)
                            .foregroundColor(.semantic.title)
                            .scaledToFill()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .shimmer(
                                enabled: titleString == nil,
                                width: 90
                            )

                        Text(descriptionString ?? "")
                            .typography(.caption1)
                            .foregroundColor(descriptionColor)
                            .scaledToFill()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .shimmer(
                                enabled: descriptionString == nil,
                                width: 100
                            )
                    }
                }
            }
            multiBadgeView
        }
        .bindings {
            subscribe($todayPrice, to: blockchain.api.nabu.gateway.price.at.time[PriceTime.now.id].crypto[model.currency].fiat.quote.value)
            subscribe($yesterdayPrice, to: blockchain.api.nabu.gateway.price.at.time[PriceTime.oneDay.id].crypto[model.currency].fiat.quote.value)
            subscribe($price, to: blockchain.api.nabu.gateway.price.crypto[model.currency].fiat.quote.value)
            subscribe($transactionFlowAction, to: blockchain.ux.transaction.id)
            subscribe($fastRisingMinDelta, to: blockchain.app.configuration.prices.rising.fast.percent)
        }
        .padding(EdgeInsets(top: 16, leading: 8.0, bottom: 16.0, trailing: 16.0))
    }
}

struct AccountPickerRowView_Previews: PreviewProvider {

    static let accountGroupIdentifier = UUID()
    static let singleAccountIdentifier = UUID()

    static let accountGroupRow = AccountPickerRow.accountGroup(
        AccountPickerRow.AccountGroup(
            id: UUID(),
            title: "All Wallets",
            description: "Total Balance"
        )
    )

    static let buttonRow = AccountPickerRow.button(
        AccountPickerRow.Button(
            id: UUID(),
            text: "See Balance"
        )
    )

    static let linkedBankAccountRow = AccountPickerRow.linkedBankAccount(
        AccountPickerRow.LinkedBankAccount(
            id: UUID(),
            title: "BTC",
            description: "5243424",
            capabilities: nil
        )
    )

    static let paymentMethodAccountRow = AccountPickerRow.paymentMethodAccount(
        AccountPickerRow.PaymentMethod(
            id: UUID(),
            title: "Visa •••• 0000",
            description: "$1,200",
            badgeView: Image(systemName: "creditcard"),
            badgeBackground: .badgeBackgroundInfo,
            capabilities: nil
        )
    )

    static let singleAccountRow = AccountPickerRow.singleAccount(
        AccountPickerRow.SingleAccount(
            id: UUID(),
            currency: "BTC",
            title: "BTC Trading Wallet",
            description: "Bitcoin"
        )
    )

    static var previews: some View {
        Group {
            AccountPickerRowView(
                model: accountGroupRow,
                send: { _ in },
                badgeView: { _ in EmptyView() },
                descriptionView: { _ in EmptyView() },
                iconView: { _ in EmptyView() },
                multiBadgeView: { _ in EmptyView() },
                withdrawalLocksView: { EmptyView() },
                fiatBalance: "$2,302.39",
                cryptoBalance: "0.21204887 BTC",
                currencyCode: "USD",
                lastItem: false
            )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("AccountGroupRow")

            AccountPickerRowView(
                model: buttonRow,
                send: { _ in },
                badgeView: { _ in EmptyView() },
                descriptionView: { _ in EmptyView() },
                iconView: { _ in EmptyView() },
                multiBadgeView: { _ in EmptyView() },
                withdrawalLocksView: { EmptyView() },
                fiatBalance: nil,
                cryptoBalance: nil,
                currencyCode: nil,
                lastItem: false
            )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("ButtonRow")

            AccountPickerRowView(
                model: linkedBankAccountRow,
                send: { _ in },
                badgeView: { _ in Icon.bank },
                descriptionView: { _ in EmptyView() },
                iconView: { _ in EmptyView() },
                multiBadgeView: { _ in EmptyView() },
                withdrawalLocksView: { EmptyView() },
                fiatBalance: nil,
                cryptoBalance: nil,
                currencyCode: nil,
                lastItem: false
            )
            .previewLayout(PreviewLayout.fixed(width: 320, height: 100))
            .padding()
            .previewDisplayName("LinkedBankAccountRow")
        }

        Group {
            AccountPickerRowView(
                model: paymentMethodAccountRow,
                send: { _ in },
                badgeView: { _ in EmptyView() },
                descriptionView: { _ in EmptyView() },
                iconView: { _ in EmptyView() },
                multiBadgeView: { _ in EmptyView() },
                withdrawalLocksView: { EmptyView() },
                fiatBalance: nil,
                cryptoBalance: nil,
                currencyCode: nil,
                lastItem: false
            )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("PaymentMethodAccountRow")

            AccountPickerRowView(
                model: singleAccountRow,
                send: { _ in },
                badgeView: { _ in EmptyView() },
                descriptionView: { _ in EmptyView() },
                iconView: { _ in EmptyView() },
                multiBadgeView: { _ in EmptyView() },
                withdrawalLocksView: { EmptyView() },
                fiatBalance: "$2,302.39",
                cryptoBalance: "0.21204887 BTC",
                currencyCode: nil,
                lastItem: false
            )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("SingleAccountRow")
        }
        EmptyView()
    }
}
