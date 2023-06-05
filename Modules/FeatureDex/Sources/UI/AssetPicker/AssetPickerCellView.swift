// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import MoneyKit
import SwiftUI

@MainActor
public struct AssetPickerCellView: View {

    let data: AssetRowData
    @State var price: FiatValue?
    @State var delta: Decimal?
    let action: () -> Void

    public var body: some View {
        cell.bindings {
            subscribe(
                $price,
                to: blockchain.api.nabu.gateway.price.crypto[data.currency.code].fiat.quote.value
            )

            subscribe($delta, to: blockchain.api.nabu.gateway.price.crypto[data.currency.code].fiat.delta.since.yesterday)

        }
    }

    @MainActor
    @ViewBuilder
    private var cell: some View {
        switch data.content {
        case .balance:
            balance
        case .token:
            token
        }
    }

    @MainActor
    @ViewBuilder
    private var balance: some View {
        SimpleBalanceRow(
            leadingTitle: data.leadingTitle,
            leadingDescription: data.leadingDescription,
            trailingTitle: data.trailingTitle(price: price),
            trailingDescription: data.trailingDescription(delta: delta),
            inlineTagView: data.networkTag ,
            action: { action() },
            leading: { leadingIcon }
        )
    }

    @MainActor
    @ViewBuilder
    private var token: some View {
        SimpleBalanceRow(
            leadingTitle: data.leadingTitle,
            leadingDescription: data.leadingDescription,
            trailingTitle: data.trailingTitle(price: price),
            trailingDescription: data.trailingDescription(delta: delta),
            trailingDescriptionColor: data.trailingColor(delta: delta),
            inlineTagView: data.networkTag,
            action: { action() },
            leading: { leadingIcon }
        )
    }

    @MainActor
    @ViewBuilder
    private var leadingIcon: some View {
        AsyncMedia(
            url: data.url
        )
        .resizingMode(.aspectFit)
        .frame(width: 24.pt, height: 24.pt)
    }
}

extension AssetRowData {

    var leadingTitle: String { currency.name }
    var leadingDescription: String { currency.displayCode }

    private static func fiatBalance(
        price: FiatValue,
        balance: CryptoValue
    ) -> FiatValue? {
        let moneyValuePair = MoneyValuePair(
            base: .one(currency: balance.currency),
            quote: price.moneyValue
        )
        return try? balance
            .moneyValue
            .convert(using: moneyValuePair)
            .fiatValue
    }

    func trailingTitle(price: FiatValue?) -> String? {
        switch content {
        case .token:
            return price?.toDisplayString(includeSymbol: true)
        case .balance(let balance):
            guard let price else { return nil }
            return Self.fiatBalance(
                price: price,
                balance: balance.value
            )?.displayString
        }
    }

    func trailingDescription(delta: Decimal?) -> String? {
        switch content {
        case .token:
            return Self.deltaChange(delta: delta)
        case .balance(let balance):
            return balance.value.displayString
        }
    }

    func trailingColor(delta: Decimal?) -> Color? {
        switch content {
        case .token:
            return Self.deltaChangeColor(delta: delta)
        case .balance:
            return .semantic.body
        }
    }


    var url: URL? { currency.logoURL }

    var tag: String? { nil }

    private static func deltaChange(delta: Decimal?) -> String? {
        guard let delta else {
            return nil
        }

        var formattedDelta = ""
        if #available(iOS 15.0, *) {
            formattedDelta = delta.formatted(.percent.precision(.fractionLength(2)))
        }

        if delta.isSignMinus {
            return "\("↓" + formattedDelta)"
        } else if delta.isZero {
            return formattedDelta
        } else {
            return "\("↑" + formattedDelta)"
        }
    }

    private static func deltaChangeColor(delta: Decimal?) -> Color? {
        guard let delta else {
            return nil
        }

        if delta.isSignMinus {
            return Color.WalletSemantic.pink
        } else if delta.isZero {
            return Color.WalletSemantic.body
        } else {
            return Color.WalletSemantic.success
        }
    }
}

struct AssetPickerCellView_Previews: PreviewProvider {

    static var dataSource: [AssetRowData] = [
        .init(content: .token(.ethereum)),
        .init(content: .token(.bitcoin)),
        .init(content: .balance(.init(value: .one(currency: .ethereum)))),
        .init(content: .balance(.init(value: .one(currency: .bitcoin))))
    ]

    static var previews: some View {
        VStack {
            ForEach(dataSource) { data in
                AssetPickerCellView(
                    data: data,
                    action: { print(data) }
                )
                .app(App.preview)
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.padding2)
        .background(Color.semantic.light.ignoresSafeArea())
    }
}


private extension AssetRowData {
    var networkTag: TagView? {
        switch content {
        case .balance(let balance):
            guard let networkName = balance.network?.nativeAsset.name, networkName != balance.currency.name else {
                return nil
            }
            return TagView(text: networkName, variant: .outline)

        case .token:
            return nil
        }
    }
}
