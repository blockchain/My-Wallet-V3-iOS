// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import Foundation
import MoneyKit
import SwiftUI

public struct DexMainView: View {

    let store: StoreOf<DexMain>
    @BlockchainApp var app

    public init(store: StoreOf<DexMain>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                if viewStore.state.availableBalances.isEmpty {
                    noBalance
                        .onAppear {
                            viewStore.send(.onAppear)
                        }
                } else {
                    dexBody
                }
            }
            .bindings {
                subscribe(
                    viewStore.binding(\.$defaultFiatCurrency),
                    to: blockchain.user.currency.preferred.fiat.trading.currency
                )
            }
            .bindings {
                subscribe(
                    viewStore.binding(\.$slippage),
                    to: blockchain.ux.currency.exchange.dex.settings.slippage
                )
            }
            .batch {
                set(
                    blockchain.ux.currency.exchange.dex.settings.tap.then.enter.into,
                    to: blockchain.ux.currency.exchange.dex.settings.sheet
                )
            }
        }
    }

    private var dexBody: some View {
        VStack(spacing: 0) {
            WithViewStore(store) { viewStore in
                inputSection(viewStore)
                    .padding(.horizontal, Spacing.padding2)
                    .padding(.top, Spacing.padding3)
                    .padding(.bottom, Spacing.padding2)
                quickActionsSection(viewStore)
                    .padding(.horizontal, Spacing.padding2)

                estimatedFee(viewStore)
                    .padding(.top, Spacing.padding3)
                    .padding(.horizontal, Spacing.padding2)

                SecondaryButton(title: "Select a token", action: {
                    print("select a token")
                })
                .disabled(true)
                .padding(.top, Spacing.padding3)
                .padding(.horizontal, Spacing.padding2)
            }
            Spacer()
        }
        .background(Color.semantic.light.ignoresSafeArea())
    }
}

extension DexMainView {

    private func estimatedFeeLabel(
        _ viewStore: ViewStoreOf<DexMain>
    ) -> some View {
        func estimatedFeeString(
            _ viewStore: ViewStoreOf<DexMain>
        ) -> String {
            // TODO: @paulo Use fees from quote.
            if let fiatCurrency = viewStore.defaultFiatCurrency {
                return FiatValue.zero(currency: fiatCurrency).displayString
            } else {
                return ""
            }
        }
        return Text("~ \(estimatedFeeString(viewStore))")
            .typography(.paragraph2)
            .foregroundColor(
                viewStore.source.amount?.isZero ?? true ?
                    .semantic.body : .semantic.title
            )
    }

    private func estimatedFee(
        _ viewStore: ViewStoreOf<DexMain>
    ) -> some View {
        HStack {
            HStack {
                AsyncMedia(
                    url: viewStore.source.amount?.currency.logoURL,
                    placeholder: {
                        Circle()
                            .foregroundColor(.semantic.light)
                    }
                )
                .frame(width: 16, height: 16)
                Text(L10n.Main.estimatedFee)
                    .typography(.body1)
                    .foregroundColor(.semantic.title)
            }
            Spacer()
            estimatedFeeLabel(viewStore)
        }
        .padding(Spacing.padding2)
        .background(Color.semantic.background)
        .cornerRadius(Spacing.padding2)
    }
}

extension DexMainView {

    private func quickActionsSection(
        _ viewStore: ViewStoreOf<DexMain>
    ) -> some View {
        HStack {
            flipButton(viewStore)
            Spacer()
            settingsButton(viewStore)
        }
    }

    private func flipButton(
        _ viewStore: ViewStoreOf<DexMain>
    ) -> some View {
        SmallMinimalButton(
            title: L10n.Main.flip,
            foregroundColor: .semantic.title,
            leadingView: { Icon.flip.micro() },
            action: {
                print("Flip")
            }
        )
    }

    private func settingsButton(
        _ viewStore: ViewStoreOf<DexMain>
    ) -> some View {
        SmallMinimalButton(
            title: L10n.Main.settings,
            foregroundColor: .semantic.title,
            leadingView: { Icon.settings.micro() },
            action: { viewStore.send(.didTapSettings) }
        )
    }
}

extension DexMainView {

    private func inputSection(
        _ viewStore: ViewStoreOf<DexMain>
    ) -> some View {
        ZStack {
            VStack {
                DexCellView(
                    store: store.scope(
                        state: \.source,
                        action: DexMain.Action.sourceAction
                    )
                )
                DexCellView(
                    store: store.scope(
                        state: \.destination,
                        action: DexMain.Action.destinationAction
                    )
                )
            }
            inputSectionFlipButton(viewStore)
        }
    }

    private func inputSectionFlipButton(
        _ viewStore: ViewStoreOf<DexMain>
    ) -> some View {
        Button(
            action: { print("switch") },
            label: {
                ZStack {
                    Circle()
                        .frame(width: 40)
                        .foregroundColor(Color.semantic.light)
                    Icon.arrowDown
                        .color(.semantic.title)
                        .circle(backgroundColor: .semantic.background)
                        .frame(width: 24)
                }
            }
        )
    }
}

extension DexMainView {

    private var noBalanceCard: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                Icon.coins.with(length: 88.pt)
                    .color(.semantic.title)
                    .circle(backgroundColor: .semantic.light)
                    .padding(8)

                ZStack {
                    Circle()
                        .frame(width: 54)
                        .foregroundColor(Color.semantic.background)
                    Icon.walletReceive.with(length: 44.pt)
                        .color(.semantic.background)
                        .circle(backgroundColor: .semantic.primary)
                }
            }
            .padding(.top, Spacing.padding3)
            .padding(.horizontal, Spacing.padding2)

            Text(L10n.Main.NoBalance.title)
                .multilineTextAlignment(.center)
                .typography(.title3)
                .foregroundColor(.semantic.title)
                .padding(.horizontal, Spacing.padding2)
                .padding(.vertical, Spacing.padding1)

            Text(L10n.Main.NoBalance.body)
                .multilineTextAlignment(.center)
                .typography(.body1)
                .foregroundColor(.semantic.body)
                .padding(.horizontal, Spacing.padding2)

            PrimaryButton(title: L10n.Main.NoBalance.button, action: {
                $app.post(event: blockchain.ux.frequent.action.receive)
            })
            .padding(.vertical, Spacing.padding3)
            .padding(.horizontal, Spacing.padding2)
        }
        .background(Color.semantic.background)
        .cornerRadius(Spacing.padding2)
        .padding(.horizontal, Spacing.padding3)
        .padding(.vertical, Spacing.padding3)
    }

    private var noBalance: some View {
        VStack {
            noBalanceCard
            Spacer()
        }
        .background(Color.semantic.light.ignoresSafeArea())
    }
}

struct DexMainView_Previews: PreviewProvider {

    private static var app = App.preview.withPreviewData()

    static var initialState: some View {
        DexMainView(
            store: Store(
                initialState: DexMain.State(),
                reducer: DexMain(
                    app: app
                )
            )
        )
        .app(app)
    }

    static var noBalances: some View {
        DexMainView(
            store: Store(
                initialState: DexMain.State(),
                reducer: DexMain(
                    app: app
                )
            )
        )
        .app(app)
    }

    static var previews: some View {
        PrimaryNavigationView {
            initialState
        }
        .previewDisplayName("Initial State")
        PrimaryNavigationView {
            noBalances
        }
        .previewDisplayName("No Balances")
    }
}
