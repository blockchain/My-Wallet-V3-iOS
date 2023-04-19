// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import Localization
import MoneyKit
import SwiftUI

@available(iOS 15, *)
@MainActor
public struct DexCellView: View {

    private typealias L10n = LocalizationConstants.Dex.Main

    let store: StoreOf<DexCell>
    @BlockchainApp var app

    public init(store: StoreOf<DexCell>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            TableRow(
                title: { amountView },
                byline: { fiatAmountView },
                trailing: { trailingView }
            )
            .background(Color.semantic.background)
            .cornerRadius(Spacing.padding2)
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onChange(of: viewStore.availableBalances) { _ in
                viewStore.send(.preselectCurrency)
            }
            .bindings {
                if let currency = viewStore.balance?.currency.code {
                    subscribe(
                        viewStore.binding(\.$price),
                        to: blockchain.api.nabu.gateway.price.crypto[currency].fiat.quote.value
                    )
                }
            }
            .bindings {
                subscribe(
                    viewStore.binding(\.$defaultFiatCurrency),
                    to: blockchain.user.currency.preferred.fiat.trading.currency
                )
            }
            .sheet(isPresented: viewStore.binding(\.$showAssetPicker), content: {
                AssetPickerView(
                    store: store.scope(
                        state: \.assetPicker,
                        action: DexCell.Action.assetPicker
                    )
                )
            })
        }
    }

    @ViewBuilder
    private var trailingView: some View {
        VStack(alignment: .trailing) {
            currencyPill
            balanceView
        }
    }
}

@available(iOS 15, *)
extension DexCellView {

    private func amountShortDisplayString(_ viewStore: ViewStoreOf<DexCell>) -> String? {
        viewStore.state.amount?.toDisplayString(includeSymbol: false)
    }

    @ViewBuilder
    private var amountView: some View {
        WithViewStore(store) { viewStore in
            Text(amountShortDisplayString(viewStore) ?? "0")
                .typography(.title2)
                .foregroundColor(.semantic.text)
        }
    }
}

@available(iOS 15, *)
extension DexCellView {

    @ViewBuilder
    private var fiatAmountView: some View {
        WithViewStore(store) { viewStore in
            if let amountFiat = viewStore.state.amountFiat {
                Text(amountFiat.displayString)
                    .typography(.body1)
                    .foregroundColor(.semantic.text)
            } else {
                ProgressView()
            }
        }
    }
}

@available(iOS 15, *)
extension DexCellView {

    @ViewBuilder
    private var balanceView: some View {
        WithViewStore(store) { viewStore in
            if viewStore.state.isMaxEnabled {
                Button(
                    action: { viewStore.send(.onTapBalance) },
                    label: { balanceBody }
                )
            } else {
                balanceBody
            }
        }
    }

    @ViewBuilder
    private var balanceBody: some View {
        WithViewStore(store) { viewStore in
            if let balance = viewStore.state.balance {
                balanceBodyLabel(balance.value)
            } else if viewStore.state.amount == nil {
                Text(" ") // TODO: @paulo Check alternative as using EmptyView breaks alignment between top labels
            } else {
                ProgressView()
            }
        }
    }

    @ViewBuilder
    private func balanceBodyLabel(_ value: CryptoValue) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.textSpacing) {
            WithViewStore(store) { viewStore in
                Text(viewStore.state.isMaxEnabled ? L10n.max : L10n.balance)
                    .typography(.micro)
                    .foregroundColor(.semantic.text)
                Text(value.displayString)
                    .typography(.micro)
                    .foregroundColor(viewStore.state.isMaxEnabled ? .semantic.primary : .semantic.title)
            }
        }
    }
}

@available(iOS 15, *)
extension DexCellView {

    @ViewBuilder
    private var currencyPill: some View {
        WithViewStore(store) { viewStore in
            Button(
                action: { viewStore.send(.onTapCurrencySelector) },
                label: {
                    if let value = viewStore.state.currency {
                        currencyPillBody(value)
                    } else {
                        currencyPillPlaceholder
                    }
                }
            )
        }
    }

    @ViewBuilder
    private func currencyPillBody(_ value: CryptoCurrency) -> some View {
        HStack {
            AsyncMedia(
                url: value.logoURL,
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

@available(iOS 15, *)
struct DexCellView_Previews: PreviewProvider {

    static var availableBalances: [DexBalance] {
        [

            DexBalance(value: .one(currency: .ethereum)),
            DexBalance(value: .one(currency: .bitcoin))
        ]
    }

    static var supportedTokens: [CryptoCurrency] {
        [

            .bitcoin,
            .ethereum
        ]
    }

    static var states: [DexCell.State] {
        [
            DexCell.State(
                style: .source
            ),
            DexCell.State(
                style: .source,
                defaultFiatCurrency: .USD
            ),
            DexCell.State(
                style: .source,
                balance: .init(value: .one(currency: .ethereum)),
                defaultFiatCurrency: .USD
            ),
            DexCell.State(
                style: .source,
                balance: .init(value: .one(currency: .ethereum)),
                defaultFiatCurrency: .USD
            ),
            DexCell.State(
                style: .source,
                amount: .one(currency: .ethereum),
                balance: .init(value: .one(currency: .ethereum)),
                defaultFiatCurrency: .USD
            ),
            DexCell.State(
                style: .source,
                availableBalances: availableBalances,
                supportedTokens: supportedTokens,
                amount: .one(currency: .ethereum),
                balance: .init(value: .one(currency: .ethereum)),
                price: .create(major: 17483.23, currency: .USD),
                defaultFiatCurrency: .USD
            )
        ]
    }

    static var previews: some View {
        VStack {
            ForEach(states.indexed(), id: \.index) { _, state in
                DexCellView(
                    store: Store(
                        initialState: state,
                        reducer: DexCell(
                            app: App.preview,
                            balances: { .just(.preview) }
                        )
                    )
                )
                .app(App.preview)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(Color.semantic.light.ignoresSafeArea())
    }
}
