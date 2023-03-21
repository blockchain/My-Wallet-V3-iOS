// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import Foundation
import Localization
import MoneyKit
import SwiftUI

@available(iOS 15, *)
public struct DexMainView: View {

    typealias L10n = LocalizationConstants.Dex.Main

    @ObservedObject var viewStore: ViewStoreOf<DexMain>
    let store: StoreOf<DexMain>
    @BlockchainApp var app

    public init(store: StoreOf<DexMain>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        WithViewStore(store, observe: { $0.noBalance }, content: { viewStore in
            if viewStore.state {
                noBalance
            } else {
                dexBody
            }
        })
        .onAppear {
            viewStore.send(.onAppear)
        }
    }

    private var dexBody: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack(spacing: 0) {
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
                Spacer()
            }
            .background(Color.semantic.light.ignoresSafeArea())
        })
    }
}

@available(iOS 15, *)
extension DexMainView {

    private func estimatedFeeValue(
        _ viewStore: ViewStoreOf<DexMain>
    ) -> FiatValue {
        viewStore.source.fees ??
            FiatValue.zero(currency: viewStore.fiatCurrency)
    }

    private func estimatedFeeLabel(
        _ viewStore: ViewStoreOf<DexMain>
    ) -> some View {
        Text("~ \(estimatedFeeValue(viewStore).displayString)")
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
                Text(L10n.estimatedFee)
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

@available(iOS 15, *)
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
            title: L10n.flip,
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
            title: L10n.settings,
            foregroundColor: .semantic.title,
            leadingView: { Icon.settings.micro() },
            action: {
                print("Settings")
            }
        )
    }
}

@available(iOS 15, *)
extension DexMainView {

    private func inputSection(
        _ viewStore: ViewStoreOf<DexMain>
    ) -> some View {
        ZStack {
            VStack {
                DexCell(
                    viewStore.source,
                    defaultFiatCurrency: viewStore.fiatCurrency,
                    didTapCurrency: { print("didTapCurrency Source") },
                    didTapBalance: { print("didTapBalance") }
                )
                DexCell(
                    viewStore.destination,
                    defaultFiatCurrency: viewStore.fiatCurrency,
                    didTapCurrency: { print("didTapCurrency Destination") }
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

@available(iOS 15, *)
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

            Text(L10n.NoBalance.title)
                .multilineTextAlignment(.center)
                .typography(.title3)
                .foregroundColor(.semantic.title)
                .padding(.horizontal, Spacing.padding2)
                .padding(.vertical, Spacing.padding1)

            Text(L10n.NoBalance.body)
                .multilineTextAlignment(.center)
                .typography(.body1)
                .foregroundColor(.semantic.body)
                .padding(.horizontal, Spacing.padding2)

            PrimaryButton(title: L10n.NoBalance.button, action: {
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

@available(iOS 15, *)
struct DexMainView_Previews: PreviewProvider {
    static var dexMainView: some View {
        DexMainView(
            store: Store(
                initialState: DexMain.State(
                    source: .init(
                        amount: .create(major: 0.557, currency: .ethereum),
                        amountFiat: .create(minor: 78335, currency: .USD),
                        balance: .one(currency: .ethereum),
                        fees: nil
                    ),
                    destination: nil,
                    fiatCurrency: .USD
                ),
                reducer: DexMain(
                    balances: { .just(.preview) }
                )
            )
        )
        .app(App.preview)
    }

    static var empty: some View {
        DexMainView(
            store: Store(
                initialState: DexMain.State(
                    source: .init(
                        amount: nil,
                        amountFiat: nil,
                        balance: nil,
                        fees: nil
                    ),
                    destination: nil,
                    fiatCurrency: .USD
                ),
                reducer: DexMain(
                    balances: { .just(.empty) }
                )
            )
        )
        .app(App.preview)
    }

    static var previews: some View {
        PrimaryNavigationView {
            empty
        }
        .previewDisplayName("No Balances")
        PrimaryNavigationView {
            dexMainView
        }
        .previewDisplayName("No Destination")
    }
}
