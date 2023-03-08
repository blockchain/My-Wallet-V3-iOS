// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import MoneyKit
import SwiftUI

@MainActor
public struct DexCell: View {

    private typealias L10n = LocalizationConstants.Dex.Main

    let amount: CryptoValue?
    let amountFiat: FiatValue?
    let balance: CryptoValue?
    let isMaxEnabled: Bool
    let defaultFiatCurrency: FiatCurrency

    let didTapCurrency: () -> Void
    let didTapBalance: () -> Void

    public var body: some View {
        TableRow(
            title: { amountView },
            byline: { fiatAmountView },
            trailing: { trailingView }
        )
        .background(Color.semantic.background)
        .cornerRadius(Spacing.padding2)
    }

    @ViewBuilder
    private var trailingView: some View {
        VStack(alignment: .trailing) {
            currencyPill
            balanceView
        }
    }
}

extension DexCell {

    private var amountShortDisplayString: String? {
        amount?.toDisplayString(includeSymbol: false)
    }

    @ViewBuilder
    private var amountView: some View {
        Text(amountShortDisplayString ?? "0")
            .typography(.title2)
            .foregroundColor(.semantic.text)
    }
}

extension DexCell {

    @ViewBuilder
    private var fiatAmountView: some View {
        if let amountFiat {
            Text(amountFiat.displayString)
                .typography(.body1)
                .foregroundColor(.semantic.text)
        } else if amount == nil {
            Text(FiatValue.zero(currency: defaultFiatCurrency).displayString)
                .typography(.body1)
                .foregroundColor(.semantic.text)
        } else {
            ProgressView()
        }
    }
}

extension DexCell {

    @ViewBuilder
    private var balanceView: some View {
        if isMaxEnabled {
            Button(
                action: didTapBalance,
                label: { balanceBody }
            )
        } else {
            balanceBody
        }
    }

    @ViewBuilder
    private var balanceBody: some View {
        if let balance {
            balanceBodyLabel(balance)
        } else if amount == nil {
            Text(" ") // TODO: @paulo Check alternative as using EmptyView breaks alignment between top labels
        } else {
            ProgressView()
        }
    }

    @ViewBuilder
    private func balanceBodyLabel(_ value: CryptoValue) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.textSpacing) {
            Text(isMaxEnabled ? L10n.max : L10n.balance)
                .typography(.micro)
                .foregroundColor(.semantic.text)
            Text(value.displayString)
                .typography(.micro)
                .foregroundColor(isMaxEnabled ? .semantic.primary : .semantic.title)
        }
    }
}

extension DexCell {

    @ViewBuilder
    private var currencyPill: some View {
        Button(
            action: didTapCurrency,
            label: {
                if let amount {
                    currencyPillBody(amount)
                } else {
                    currencyPillPlaceholder
                }
            }
        )
    }

    @ViewBuilder
    private func currencyPillBody(_ value: CryptoValue) -> some View {
        HStack {
            AsyncMedia(
                url: value.currency.logoURL,
                placeholder: EmptyView.init
            )
            .frame(width: 16, height: 16)
            Text(value.displayCode)
                .typography(.body1)
                .foregroundColor(.semantic.title)
            Icon.chevronRight
                .color(.semantic.muted)
                .frame(width: 12)
        }
        .padding(.all, Spacing.padding1)
        .background(Color.semantic.light)
        .cornerRadius(Spacing.padding2)
    }

    @ViewBuilder
    private var currencyPillPlaceholder: some View {
        HStack {
            Icon.coins
                .color(.semantic.title)
                .frame(width: 16, height: 16)
            Text(L10n.select)
                .typography(.body1)
                .foregroundColor(.semantic.title)
            Icon.chevronRight
                .color(.semantic.muted)
                .frame(width: 12)
        }
        .padding(.all, Spacing.padding1)
        .background(Color.semantic.light)
        .cornerRadius(Spacing.padding2)
    }
}

struct DexCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DexCell(
                amount: nil,
                amountFiat: nil,
                balance: nil,
                isMaxEnabled: false,
                defaultFiatCurrency: .USD,
                didTapCurrency: { print("didTapCurrency") },
                didTapBalance: { print("didTapMax") }
            )
            DexCell(
                amount: .zero(currency: .ethereum),
                amountFiat: nil,
                balance: nil,
                isMaxEnabled: false,
                defaultFiatCurrency: .USD,
                didTapCurrency: { print("didTapCurrency") },
                didTapBalance: { print("didTapMax") }
            )
            DexCell(
                amount: .zero(currency: .ethereum),
                amountFiat: .zero(currency: .USD),
                balance: .one(currency: .ethereum),
                isMaxEnabled: false,
                defaultFiatCurrency: .USD,
                didTapCurrency: { print("didTapCurrency") },
                didTapBalance: { print("didTapMax") }
            )
            DexCell(
                amount: .zero(currency: .ethereum),
                amountFiat: .zero(currency: .USD),
                balance: .one(currency: .ethereum),
                isMaxEnabled: true,
                defaultFiatCurrency: .USD,
                didTapCurrency: { print("didTapCurrency") },
                didTapBalance: { print("didTapMax") }
            )
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(Color.semantic.light.ignoresSafeArea())
    }
}
