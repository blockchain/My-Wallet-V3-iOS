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
                feeExplainSection()
                rate()
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
        VStack(spacing: 0) {
            sourceSection()
                .padding(.bottom, -Spacing.padding1)
                .zIndex(0)
            Icon.arrowDown
                .small()
                .color(.semantic.title)
                .circle(backgroundColor: .semantic.background)
                .background(Circle().fill(Color.semantic.light).scaleEffect(1.5))
                .zIndex(1)
            targetSection()
                .padding(.top, -Spacing.padding1)
                .zIndex(0)
        }
    }


    @ViewBuilder
    func sourceSection() -> some View {
        let target = checkout.from
        let cryptoValue = target.cryptoValue
        DividedVStack {
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
                        if let fiatValue = target.fiatValue {
                            Text(fiatValue.displayString)
                                .typography(.paragraph2)
                                .foregroundColor(.semantic.title)
                                .padding(.top, 2)
                        }
                        Text(cryptoValue.displayString)
                            .typography(.caption1)
                            .foregroundColor(.semantic.body)
                    }
                }
            )

            if !target.fee.isZero {
                fee(
                    crypto: target.fee,
                    fiat: target.feeFiatValue
                )

                TableRow(
                    title: {
                        Text("Subtotal")
                            .typography(.paragraph2)
                            .foregroundColor(.semantic.body)
                    },
                    trailing: {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(target.amountFiatValueAddFee?.displayString ?? "")
                                .typography(.paragraph2)
                                .foregroundColor(.semantic.title)
                        }
                    }
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.semantic.background)
        )
    }

    @ViewBuilder
    func targetSection() -> some View {
        let target = checkout.to
        let cryptoValue = target.cryptoValue
        DividedVStack {
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
                        if let fiatValue = target.fiatValue {
                            Text(fiatValue.displayString)
                                .typography(.paragraph2)
                                .foregroundColor(.semantic.title)
                                .padding(.top, 2)
                        }
                        Text(cryptoValue.displayString)
                            .typography(.caption1)
                            .foregroundColor(.semantic.body)
                    }
                }
            )

            if !target.fee.isZero {
                fee(
                    crypto: target.fee,
                    fiat: target.feeFiatValue
                )

                TableRow(
                    title: {
                        Text(L10n.Label.amountToBeReceivedTitle)
                            .typography(.paragraph2)
                            .foregroundColor(.semantic.body)
                    },
                    trailing: {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(target.amountFiatValueSubtractFee?.displayString ?? "")
                                .typography(.paragraph2)
                                .foregroundColor(.semantic.title)
                        }
                    }
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.semantic.background)
        )
    }

    @ViewBuilder func rate() -> some View {
        TableRow(title: {
            Text(L10n.Label.exchangeRate)
                .typography(.paragraph2)
                .foregroundColor(.semantic.body)
        },
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
    func feeExplainSection() -> some View {
        if checkout.to.isPrivateKey {
            VStack {
                VStack(alignment: .leading, spacing: Spacing.padding1) {
                    Text(L10n.Label.networkFeesTitle)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)

                    Text(L10n.Label.networkFeesSubtitle)
                        .typography(.caption1)
                        .foregroundColor(.semantic.title)

                    SmallSecondaryButton(title: L10n.Button.learnMore,
                                         action: {

                        $app.post(event: blockchain.ux.transaction.checkout.fee.disclaimer)
                    })
                   .padding(.top, Spacing.padding2)
                }
                .padding(Spacing.padding2)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.semantic.background)
            )
            .batch {
                set(blockchain.ux.transaction.checkout.fee.disclaimer.then.launch.url, to: { blockchain.ux.transaction.checkout.fee.disclaimer.url })
            }
        }
    }


    @ViewBuilder
    func fee(crypto: CryptoValue, fiat: FiatValue?) -> some View {
        TableRow(title: {
            Text(L10n.Label.assetNetworkFees.interpolating(crypto.code))
                .typography(.paragraph2)
                .foregroundColor(.semantic.body)
        }, trailing: {
            VStack(alignment: .trailing, spacing: 4) {
                if let fiatValue = fiat, !crypto.isZero {
                    Text("~ \(fiatValue.displayString)")
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)
                        .padding(.top, 2)
                }

                Text("\(crypto.displayString)")
                    .typography(.caption1)
                    .foregroundColor(.semantic.body)
            }
        })
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

        SwapCheckoutLoadedView(checkout: .previewPrivateKeyToPrivateKeyNoTargetFees)
            .app(App.preview)
            .context([blockchain.ux.transaction.id: "swap"])
            .previewDisplayName("Private Key -> Private Key Swap No Fees")

        SwapCheckoutLoadedView(checkout: .previewPrivateKeyToTrading)
            .app(App.preview)
            .context([blockchain.ux.transaction.id: "swap"])
            .previewDisplayName("Private Key -> Trading Swap")

        SwapCheckoutLoadedView(checkout: .previewTradingToTrading)
            .app(App.preview)
            .context([blockchain.ux.transaction.id: "swap"])
            .previewDisplayName("Trading -> Trading Swap")

        SwapCheckoutLoadedView(checkout: .previewTradingToTradingNoFees)
            .app(App.preview)
            .context([blockchain.ux.transaction.id: "swap"])
            .previewDisplayName("Trading -> Trading Swap No Fees")

    }
}
