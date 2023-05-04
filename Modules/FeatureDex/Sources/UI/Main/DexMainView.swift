// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureDexDomain
import BlockchainUI
import SwiftUI

public struct DexMainView: View {

    let store: StoreOf<DexMain>
    @ObservedObject var viewStore: ViewStore<DexMain.State, DexMain.Action>

    @State private var error: UX.Error?

    @BlockchainApp var app

    public init(store: StoreOf<DexMain>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            if viewStore.state.availableBalances.isEmpty {
                noBalance
            } else {
                content
            }
        }
        .onAppear {
            viewStore.send(.onAppear)
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
        .bottomSheet(item: $error.animation()) { error in
            ErrorView(
                ux: error,
                navigationBarClose: false,
                fallback: { viewStore.source.currency?.logo(size: 96) },
                dismiss: {
                    withAnimation {
                        self.error = nil
                    }
                }
            )
            .frame(height: 40.vh)
        }
    }

    private var content: some View {
        VStack(spacing: Spacing.padding2) {
            inputSection()
                .padding(.top, Spacing.padding3)
            quickActionsSection()
            estimatedFee()
                .padding(.top, Spacing.padding3)
            allowanceButton()
            continueButton()
            Spacer()
        }
        .padding(.horizontal, Spacing.padding2)
        .background(Color.semantic.light.ignoresSafeArea())
    }

    @ViewBuilder private func allowanceButton() -> some View {
        switch viewStore.state.allowance.status {
        case .notRequired:
            EmptyView()
        case .complete:
            MinimalButton(
                title: String(format: L10n.Allowance.approved, viewStore.source.currency?.code ?? ""),
                isOpaque: true,
                action: { }
            )
        case .pending:
            MinimalButton(
                title: "",
                isLoading: true,
                isOpaque: true,
                action: { }
            )
        case .required:
            MinimalButton(
                title: String(format: L10n.Allowance.approve, viewStore.source.currency?.code ?? ""),
                isOpaque: true,
                action: { viewStore.send(.didTapAllowance) }
            )
        }
    }

    @ViewBuilder private func continueButton() -> some View {
        switch viewStore.state.continueButtonState {
        case .error(let error):
            AlertButton(
                title: error.title,
                action: { self.error = error }
            )
        case .enterAmount, .previewSwapDisabled, .selectToken:
            SecondaryButton(title: viewStore.state.continueButtonState.title) {
                print(viewStore.state.continueButtonState.title)
            }
            .disabled(true)
        case .previewSwap:
            SecondaryButton(title: viewStore.state.continueButtonState.title) {
                print(viewStore.state.continueButtonState.title)
                viewStore.send(.didTapPreview)
            }
        }
    }
}

extension DexMainView {

    private func estimatedFeeLabel() -> some View {
        func estimatedFeeString() -> String {
            // TODO: @paulo Use fees from quote.
            if let fiatCurrency = viewStore.defaultFiatCurrency {
                return FiatValue.zero(currency: fiatCurrency).displayString
            } else {
                return ""
            }
        }
        return Text("~ \(estimatedFeeString())")
            .typography(.paragraph2)
            .foregroundColor(
                viewStore.source.amount?.isZero ?? true ?
                    .semantic.body : .semantic.title
            )
    }

    private func estimatedFee() -> some View {
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
            estimatedFeeLabel()
        }
        .padding(Spacing.padding2)
        .background(Color.semantic.background)
        .cornerRadius(Spacing.padding2)
    }
}

extension DexMainView {

    private func quickActionsSection() -> some View {
        HStack {
            flipButton()
            Spacer()
            settingsButton()
        }
    }

    private func flipButton() -> some View {
        SmallMinimalButton(
            title: L10n.Main.flip,
            foregroundColor: .semantic.title,
            leadingView: { Icon.flip.micro() },
            action: {
                print("Flip")
            }
        )
    }

    private func settingsButton() -> some View {
        SmallMinimalButton(
            title: L10n.Main.settings,
            foregroundColor: .semantic.title,
            leadingView: { Icon.settings.micro() },
            action: { viewStore.send(.didTapSettings) }
        )
    }
}

extension DexMainView {

    private func inputSection() -> some View {
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
            inputSectionFlipButton()
        }
    }

    private func inputSectionFlipButton() -> some View {
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

    static var states: [(String, DexMain.State)] = [
        ("Default", DexMain.State()),
        ("Not enough ETH", DexMain.State().setup { state in
            state.source.balance = DexBalance(
                value: .create(major: 1.0, currency: .ethereum)
            )
            state.source.inputText = "2"
        }),
        ("Unable to swap these tokens", DexMain.State().setup { state in
            // TODO: Fix this preview
            let error = UX.Error(
                title: "Unable to swap these tokens",
                message: "We don't currently support swapping these tokens"
            )
            state.quote = .failure(error)
        }),
        ("Not enough ETH for gas fees", DexMain.State().setup { state in
            // TODO: Fix this preview
            let error = UX.Error(
                title: "Not enough ETH for gas fees",
                message: "You do not have enough ETH to cover the gas fees on this transaction"
            )
            state.quote = .failure(error)
        })
    ]

    static var previews: some View {
        ForEach(states, id: \.0) { label, state in
            PrimaryNavigationView {
                DexMainView(
                    store: Store(
                        initialState: state,
                        reducer: DexMain(app: app)
                    )
                )
                .app(app)
            }
            .previewDisplayName(label)
        }
    }
}
