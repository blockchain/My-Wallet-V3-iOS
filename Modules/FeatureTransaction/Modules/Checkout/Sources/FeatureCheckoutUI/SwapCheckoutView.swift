// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureCheckoutDomain
import SwiftUI

public struct SwapCheckoutView<Object: LoadableObject>: View where Object.Output == SwapCheckout, Object.Failure == Never {

    @BlockchainApp var app
    @Environment(\.context) var context

    @ObservedObject var viewModel: Object
    var confirm: (() -> Void)?

    public init(viewModel: Object, confirm: (() -> Void)? = nil) {
        _viewModel = .init(wrappedValue: viewModel)
        self.confirm = confirm
    }

    public var body: some View {
        AsyncContentView(
            source: viewModel,
            loadingView: Loading(),
            content: { object in Loaded(checkout: object, confirm: confirm) }
        )
        .onAppear {
            $app.post(event: blockchain.ux.transaction.checkout)
        }
    }
}

extension SwapCheckoutView {

    public init<P>(
        publisher: P,
        confirm: (() -> Void)? = nil
    ) where P: Publisher, P.Output == SwapCheckout, P.Failure == Never, Object == PublishedObject<P, DispatchQueue> {
        self.viewModel = PublishedObject(publisher: publisher)
        self.confirm = confirm
    }

    public init(
        _ checkout: Object.Output,
        confirm: (() -> Void)? = nil
    ) where Object == PublishedObject<Just<SwapCheckout>, DispatchQueue> {
        self.init(publisher: Just(checkout), confirm: confirm)
    }
}

extension SwapCheckoutView {
    public typealias Loading = SwapCheckoutLoadingView
    public typealias Loaded = SwapCheckoutLoadedView
}

public struct SwapCheckoutLoadingView: View {

    public var body: some View {
        ZStack {
            SwapCheckoutLoadedView(checkout: .preview)
                .redacted(reason: .placeholder)
            ProgressView()
        }
    }
}

public struct SwapCheckoutLoadedView: View {

    @BlockchainApp var app

    var checkout: SwapCheckout
    var confirm: (() -> Void)?

    @State private var isShowingFeeDetails = false
    @State private var remainingTime: TimeInterval = .hour

    public init(checkout: SwapCheckout, confirm: (() -> Void)? = nil) {
        self.checkout = checkout
        self.confirm = confirm
    }
}

extension SwapCheckoutView.Loaded {

    @ViewBuilder public var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                swap()
                rate()
                fees()
                quoteExpiry()
                disclaimer()
            }
            .padding(.horizontal)
            Spacer()
            footer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.semantic.light.ignoresSafeArea())
        .primaryNavigation(title: L10n.NavigationTitle.swap)
    }

    @ViewBuilder func swap() -> some View {
        ZStack {
            VStack {
                target(checkout.from)
                target(checkout.to)
            }
            Icon.arrowDown
                .color(.semantic.title)
                .circle(backgroundColor: .semantic.background)
                .frame(width: 24.pt, height: 24.pt)
                .background(Circle().fill(Color.semantic.light).scaleEffect(1.5))
        }
    }

    @ViewBuilder func target(_ target: SwapCheckout.Target) -> some View {
        let cryptoValue = target.cryptoValue
        TableRow(
            leading: {
                cryptoValue.currency.logo()
            },
            title: {
                Text(cryptoValue.currency.name)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            },
            byline: {
                Text(target.name)
                    .typography(.caption1)
                    .foregroundColor(.semantic.body)
            },
            trailing: {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(cryptoValue.displayString)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)
                    if let fiatValue = target.fiatValue {
                        Text(fiatValue.displayString)
                            .typography(.caption1)
                            .foregroundColor(.semantic.body)
                            .padding(.top, 2)
                    }
                }
            }
        )
        .padding(.vertical, 4.pt)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.semantic.background)
        )
    }

    @ViewBuilder func rate() -> some View {
        TableRow(
            title: TableRowTitle(L10n.Label.exchangeRate),
            trailingTitle: "\(checkout.exchangeRate.base.displayString) = \(checkout.exchangeRate.quote.displayString)"
        )
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.semantic.background)
        )
    }

    @ViewBuilder func quoteExpiry() -> some View {
        if let expiration = checkout.quoteExpiration {
            CountdownView(deadline: expiration, remainingTime: $remainingTime)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.semantic.background)
                )
        }
    }

    @ViewBuilder
    func fees() -> some View {
        if app.currentMode == .pkw {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack {
                        Text(L10n.Label.networkFees)
                        Spacer()
                        if let fee = checkout.totalFeesInFiat {
                            Text("~ \(fee.displayString)")
                        } else {
                            Text(L10n.Label.noNetworkFee)
                        }

                        if isShowingFeeDetails {
                            IconButton(icon: .chevronDown, action: {
                                withAnimation { isShowingFeeDetails.toggle() }
                            })
                            .frame(width: 16.pt, height: 16.pt)
                        } else {
                            IconButton(icon: .chevronRight, action: {
                                withAnimation { isShowingFeeDetails.toggle() }
                            })
                            .frame(width: 16.pt, height: 16.pt)
                        }
                    }
                    .typography(.paragraph2)
                    .padding()

                    if isShowingFeeDetails {
                        Group {
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
                }
                PrimaryDivider()
                RichText(L10n.Label.feesDisclaimer.interpolating(checkout.from.code, checkout.to.code))
                    .typography(.caption1)
                    .padding(16.pt)
                    .onTapGesture {
                        $app.post(event: blockchain.ux.transaction.checkout.fee.disclaimer)
                    }
            }
            .batch {
                set(blockchain.ux.transaction.checkout.fee.disclaimer.then.launch.url, to: { blockchain.ux.transaction.checkout.fee.disclaimer.url })
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.semantic.background)
            )
        }
    }

    func fee(crypto: CryptoValue, fiat: FiatValue?) -> some View {
        TableRow(
            title: TableRowTitle(L10n.Label.assetNetworkFees.interpolating(crypto.code)),
            trailing: {
                VStack(alignment: .trailing, spacing: 4) {
                    Group {
                        if crypto.isZero {
                            Text(L10n.Label.noNetworkFee)
                        } else {
                            Text("~ \(crypto.displayString)")
                        }
                    }
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
                    if let fiatValue = fiat, !crypto.isZero {
                        Text(fiatValue.displayString)
                            .typography(.caption1)
                            .foregroundColor(.semantic.body)
                            .padding(.top, 2)
                    }
                }
            }
        )
    }

    func disclaimer() -> some View {
        Text(rich: L10n.Label.refundDisclaimer)
            .typography(.caption1)
            .foregroundColor(.semantic.body)
            .multilineTextAlignment(.center)
            .onTapGesture {
                $app.post(event: blockchain.ux.transaction.checkout.refund.policy.disclaimer)
            }
            .batch {
                set(blockchain.ux.transaction.checkout.refund.policy.disclaimer.then.launch.url, to: { blockchain.ux.transaction.checkout.refund.policy.disclaimer.url })
            }
    }

    func footer() -> some View {
        VStack(spacing: 0) {
            PrimaryButton(title: L10n.Button.confirmSwap) {
                confirm?()
                $app.post(event: blockchain.ux.transaction.checkout.confirmed)
            }
            .disabled(remainingTime < 5)
            .padding()
        }
    }
}

// MARK: Preview

struct SwapCheckoutView_Previews: PreviewProvider {

    static var previews: some View {

        SwapCheckoutLoadingView()
            .app(App.preview)
            .context([blockchain.ux.transaction.id: "swap"])
            .previewDisplayName("Loading")

        SwapCheckoutLoadedView(checkout: .preview)
            .app(App.preview)
            .context([blockchain.ux.transaction.id: "swap"])
            .previewDisplayName("Private Key -> Private Key Swap")

        SwapCheckoutLoadedView(checkout: .previewPrivateKeyToTrading)
            .app(App.preview)
            .context([blockchain.ux.transaction.id: "swap"])
            .previewDisplayName("Private Key -> Trading Swap")

        SwapCheckoutLoadedView(checkout: .previewTradingToTrading)
            .app(App.preview)
            .context([blockchain.ux.transaction.id: "swap"])
            .previewDisplayName("Trading -> Trading Swap")
    }
}
