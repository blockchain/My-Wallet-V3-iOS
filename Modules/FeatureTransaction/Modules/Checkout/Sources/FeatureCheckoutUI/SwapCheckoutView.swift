// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureCheckoutDomain
import SwiftUI

public struct SwapCheckoutView: View {

    @EnvironmentObject<Object> var object

    public init() {}

    public var body: some View {
        switch object.checkout {
        case .loading:
            ZStack {
                ProgressView()
                    .progressViewStyle(.blockchain)
                    .frame(width: 20.vw, height: 20.vw)
            }
        case .loaded(let checkout):
            LoadedView(checkout: checkout)
        }
    }

    struct LoadedView: View {

        private typealias L10n = LocalizationConstants.Checkout

        @State private var isShowingExchangeRateDisclaimer: Bool = false
        @State private var isShowingFeeDetails: Bool = false

        @BlockchainApp var app
        @Environment(\.context) var context

        var checkout: SwapCheckout

        var body: some View {
            VStack(spacing: 0) {
                if let expiration = checkout.quoteExpiration {
                    CountdownView(deadline: expiration)
                        .padding()
                }
                ScrollView {
                    header()
                    exchangeRate()
                    fees()
                    disclaimer()
                }
                footer()
            }
            .onAppear {
                app.post(
                    event: blockchain.ux.transaction.checkout[].ref(to: context),
                    context: context
                )
            }
        }

        func header() -> some View {
            ZStack {
                VStack(spacing: 0) {
                    PrimaryDivider()

                    BalanceRow(
                        leadingTitle: L10n.Label.from,
                        leadingDescription: checkout.from.name,
                        trailingTitle: checkout.from.cryptoValue.displayString,
                        trailingDescription: "~\(checkout.from.fiatValue?.displayString ?? "...")"
                    ) {
                        cryptoLogo(checkout.from)
                    }

                    PrimaryDivider()

                    BalanceRow(
                        leadingTitle: L10n.Label.to,
                        leadingDescription: checkout.to.name,
                        trailingTitle: checkout.to.cryptoValue.displayString,
                        trailingDescription: "~\(checkout.to.fiatValue?.displayString ?? "...")"
                    ) {
                        cryptoLogo(checkout.to)
                    }

                    PrimaryDivider()
                }
                HStack {
                    Icon.arrowDown
                        .color(.semantic.muted)
                        .circle(backgroundColor: .semantic.background)
                        .frame(width: 36, height: 24)
                        .overlay(Circle().stroke(Color.semantic.muted, lineWidth: 0.5))
                        .padding(.leading, Spacing.padding3.pt)

                    Spacer()
                }
            }
        }

        @ViewBuilder
        func cryptoLogo(_ target: SwapCheckout.Target) -> some View {
            let currency = target.cryptoValue.currency
            ZStack {
                AsyncMedia(
                    url: currency.assetModel.logoPngUrl,
                    placeholder: {
                        Color.semantic.muted
                            .opacity(0.3)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(.circular)
                            )
                            .clipShape(Circle())
                    }
                )
                .frame(width: 32.pt, height: 32.pt)
                .overlay(
                    ZStack(alignment: .bottomTrailing) {
                        Color.clear
                        Circle()
                            .fill(Color.semantic.background)
                            .inscribed(
                                target.isPrivateKey
                                    ? Icon.private.color(currency.color)
                                    : Icon.trade.color(currency.color)
                            )
                            .frame(width: 12.pt, height: 12.pt)
                    }
                )
            }
            .frame(width: 36.pt, height: 36.pt)
        }

        func exchangeRate() -> some View {
            VStack {
                HStack {
                    Text(L10n.Label.exchangeRate)
                        .typography(.paragraph2)

                    Button(
                        action: {
                            withAnimation {
                                isShowingExchangeRateDisclaimer.toggle()
                            }
                        }, label: {
                            Icon.questionCircle
                                .accentColor(isShowingExchangeRateDisclaimer ? .semantic.primary : .semantic.muted)
                        }
                    )
                    .frame(width: 16.pt, height: 16.pt)

                    Spacer()

                    let base = checkout.exchangeRate.base
                    let quote = checkout.exchangeRate.quote

                    Text("\(base.displayString) = \(quote.displayString)")
                        .typography(.paragraph2)
                        .transition(.opacity)
                }
                .padding([.leading, .trailing, .top], 24.pt)

                if isShowingExchangeRateDisclaimer {
                    let to = checkout.to
                    let from = checkout.from
                    RichText(
                        L10n.Label.exchangeRateDisclaimer
                            .interpolating(to.cryptoValue.code, from.cryptoValue.code)
                    )
                    .transition(.scale.combined(with: .opacity))
                    .typography(.caption1)
                    .padding()
                    .background(Color.semantic.light)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding([.leading, .trailing], Spacing.padding2)
                    .onTap(blockchain.ux.transaction.checkout.exchange.rate.disclaimer, \.then.launch.url) {
                        try await app.get(blockchain.ux.transaction.checkout.exchange.rate.disclaimer.url) as URL
                    }
                }
            }
        }

        func fees() -> some View {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack {
                        Text(L10n.Label.networkFees)
                        Spacer()
                        Text(checkout.totalFeesInFiat?.displayString ?? L10n.Label.noNetworkFee)
                        IconButton(icon: isShowingFeeDetails ? .chevronUp : .chevronDown) {
                            withAnimation { isShowingFeeDetails.toggle() }
                        }
                        .frame(width: 16.pt, height: 16.pt)
                    }
                    .typography(.paragraph2)
                    .padding()

                    if isShowingFeeDetails {
                        PrimaryDivider()
                        fee(
                            crypto: checkout.from.fee,
                            fiat: checkout.from.feeFiatValue
                        )
                        PrimaryDivider()
                        fee(
                            crypto: checkout.to.fee,
                            fiat: checkout.to.feeFiatValue
                        )
                    }
                }
                .background(Color.semantic.background)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.semantic.muted, lineWidth: 0.5)
                )
                .padding(0.5)

                RichText(L10n.Label.feesDisclaimer.interpolating(checkout.from.code, checkout.to.code))
                    .typography(.caption1)
                    .padding(16.pt)
                    .onTap(blockchain.ux.transaction.checkout.fee.disclaimer, \.then.launch.url) {
                        try await app.get(blockchain.ux.transaction.checkout.fee.disclaimer.url) as URL
                    }
            }
            .background(Color.semantic.light)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding()
        }

        func disclaimer() -> some View {
            RichText(L10n.Label.refundDisclaimer)
                .multilineTextAlignment(.center)
                .typography(.caption1)
                .foregroundColor(.semantic.body)
                .padding()
                .onTap(blockchain.ux.transaction.checkout.refund.policy.disclaimer, \.then.launch.url) {
                    try await app.get(blockchain.ux.transaction.checkout.refund.policy.disclaimer.url) as URL
                }
        }

        func footer() -> some View {
            VStack(spacing: 0) {
                PrimaryDivider()
                PrimaryButton(
                    title: L10n.Button.confirmSwap.interpolating(checkout.from.cryptoValue.code, checkout.to.cryptoValue.code)
                ) {
                    app.post(
                        event: blockchain.ux.transaction.checkout.confirmed[].ref(to: context),
                        context: context
                    )
                }
                .padding()
            }
        }

        func fee(crypto: CryptoValue, fiat: FiatValue?) -> some View {
            HStack {
                Text(L10n.Label.assetNetworkFees.interpolating(crypto.code))
                    .typography(.paragraph2)

                Spacer()

                VStack(alignment: .trailing, spacing: 4.pt) {
                    Text(crypto.isZero ? L10n.Label.noNetworkFee : crypto.displayString)

                    if let fiatValue = fiat, !crypto.isZero {
                        Text(fiatValue.displayString)
                            .typography(.caption1)
                            .foregroundTexture(.semantic.body)
                    }
                }
                .typography(.caption1)
                .transition(.opacity)
            }
            .foregroundTexture(.semantic.title)
            .padding()
        }
    }
}

extension SwapCheckoutView {

    public class Object: ObservableObject {

        public enum State {
            case loading, loaded(SwapCheckout)
        }

        @Published var checkout: State = .loading

        public init<P: Publisher>(publisher: P) where P.Output == SwapCheckout, P.Failure == Never {
            publisher.map(State.loaded).assign(to: &$checkout)
        }
    }
}

extension CryptoCurrency {

    var color: Color {
        assetModel.spotColor.map(Color.init(hex:))
            ?? (CustodialCoinCode(rawValue: code)?.spotColor).map(Color.init(hex:))
            ?? Color(hex: ERC20Code.spotColor(code: code))
    }
}

// MARK: Preview

struct SwapCheckoutView_Previews: PreviewProvider {

    static var previews: some View {
        SwapCheckoutView()
            .environmentObject(SwapCheckoutView.Object(publisher: AnyPublisher.just(.preview)))
            .app(App.preview)
            .previewDisplayName("Private Key -> Private Key Swap")

        SwapCheckoutView()
            .environmentObject(SwapCheckoutView.Object(publisher: AnyPublisher.just(.previewPrivateKeyToTrading)))
            .app(App.preview)
            .previewDisplayName("Private Key -> Trading Swap")

        SwapCheckoutView()
            .environmentObject(SwapCheckoutView.Object(publisher: AnyPublisher.just(.previewTradingToTrading)))
            .app(App.preview)
            .previewDisplayName("Trading -> Trading Swap")
    }
}

private struct NamespaceOnTapActionModifier<
    Event: L & I_blockchain_ui_type_action,
    Action: L,
    T: Hashable
>: ViewModifier {

    @BlockchainApp var app
    @Environment(\.context) var context

    let event: Event
    let action: KeyPath<L_blockchain_ui_type_action, Action>
    let data: (() async throws -> T)?

    init(
        event: Event,
        action: KeyPath<L_blockchain_ui_type_action, Action>,
        data: (() async throws -> T)?
    ) {
        self.event = event
        self.action = action
        self.data = data
    }

    func body(content: Content) -> some View {
        content.onTapGesture {
            Task(priority: .userInitiated) { @MainActor in
                try await app.post(
                    event: event[].as(blockchain.ui.type.action)[keyPath: action],
                    context: [
                        blockchain.ui.type.action[keyPath: action]: data?()
                    ]
                )
            }
        }
    }
}

extension View {

    public func onTap(
        _ event: some L & I_blockchain_ui_type_action,
        _ action: KeyPath<L_blockchain_ui_type_action, some L>,
        data: (() async throws -> some Hashable)? = nil
    ) -> some View {
        modifier(NamespaceOnTapActionModifier(event: event, action: action, data: data))
    }
}
