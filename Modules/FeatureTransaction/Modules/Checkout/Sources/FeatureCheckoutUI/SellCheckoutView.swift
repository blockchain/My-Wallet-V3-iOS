import BlockchainUI
import FeatureCheckoutDomain
import SwiftUI

public struct SellCheckoutView<Object: LoadableObject>: View where Object.Output == SellCheckout, Object.Failure == Never {

    @BlockchainApp var app

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

extension SellCheckoutView {

    public init<P>(
        publisher: P,
        confirm: (() -> Void)? = nil
    ) where P: Publisher, P.Output == SellCheckout, P.Failure == Never, Object == PublishedObject<P, DispatchQueue> {
        self.viewModel = PublishedObject(publisher: publisher)
        self.confirm = confirm
    }

    public init(
        _ checkout: Object.Output,
        confirm: (() -> Void)? = nil
    ) where Object == PublishedObject<Just<SellCheckout>, DispatchQueue> {
        self.init(publisher: Just(checkout), confirm: confirm)
    }
}

extension SellCheckoutView {
    public typealias Loading = SellCheckoutLoadingView
    public typealias Loaded = SellCheckoutLoadedView
}

public struct SellCheckoutLoadingView: View {

    public var body: some View {
        ZStack {
            SellCheckoutLoadedView(checkout: .previewTrading)
                .redacted(reason: .placeholder)
            ProgressView()
        }
    }
}

@MainActor
public struct SellCheckoutLoadedView: View {

    struct Explain {
        let title: String
        let message: String
    }

    @BlockchainApp var app

    var checkout: SellCheckout
    var confirm: (() -> Void)?

    @State private var quote: MoneyValue?
    @State private var explain: Explain?
    @State private var remainingTime: TimeInterval = .hour

    public init(checkout: SellCheckout, confirm: (() -> Void)? = nil) {
        self.checkout = checkout
        self.confirm = confirm
    }
}

extension SellCheckoutView.Loaded {

    @ViewBuilder public var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                sell()
                rows()
                quoteExpiry()
                disclaimer()
            }
            .padding(.horizontal)
            Spacer()
            footer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .bottomSheet(item: $explain.animation()) { explain in
            explainer(explain)
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .primaryNavigation(title: L10n.NavigationTitle.sell)
    }

    @ViewBuilder func sell() -> some View {
        VStack(alignment: .center) {
            Text(checkout.quote.fiatValue?.toDisplayString(includeSymbol: true, format: .shortened) ?? "")
                .typography(.title1)
                .foregroundColor(.semantic.title)
            Text(checkout.value.displayString)
                .typography(.body1)
                .foregroundColor(.semantic.body)
        }
        .padding(.vertical)
    }

    func explainer(_ explain: Explain) -> some View {
        VStack(spacing: 24.pt) {
            VStack(spacing: 8.pt) {
                Text(explain.title)
                    .typography(.title3)
                    .foregroundColor(.semantic.title)
                Text(explain.message)
                    .typography(.body1)
                    .foregroundColor(.semantic.body)
            }
            PrimaryButton(title: L10n.Button.gotIt) {
                withAnimation { self.explain = nil }
            }
        }
        .padding()
        .multilineTextAlignment(.center)
    }

    @ViewBuilder func rows() -> some View {
        DividedVStack {
            TableRow(
                title: {
                    HStack {
                        TableRowTitle(L10n.Label.exchangeRate).foregroundColor(.semantic.body)
                        Icon.questionCircle.micro().color(.semantic.muted)
                    }
                },
                trailing: {
                    TableRowTitle("\(checkout.exchangeRate.base.displayString) = \(checkout.exchangeRate.quote.displayString)")
                }
            )
            .background(Color.semantic.background)
            .onTapGesture {
                explain = Explain(
                    title: L10n.Label.exchangeRate,
                    message: L10n.Label.exchangeRateDisclaimer.interpolating(checkout.exchangeRate.quote.code, checkout.exchangeRate.base.code)
                )
            }
            TableRow(
                title: {
                    TableRowTitle(L10n.Label.from).foregroundColor(.semantic.body)
                },
                trailing: {
                    TableRowTitle(checkout.value.currency.name)
                }
            )
            TableRow(
                title: {
                    TableRowTitle(L10n.Label.to).foregroundColor(.semantic.body)
                },
                trailing: {
                    TableRowTitle(checkout.quote.currency.name)
                }
            )
            if let networkFee = checkout.networkFee, networkFee.isNotZero {
                TableRow(
                    title: {
                        HStack {
                            TableRowTitle(L10n.Label.networkFee).foregroundColor(.semantic.body)
                            Icon.questionCircle.micro().color(.semantic.muted)
                        }
                    },
                    trailing: {
                        TableRowTitle(networkFee.displayString)
                    }
                )
                .background(Color.semantic.background)
                .onTapGesture {
                    explain = Explain(
                        title: L10n.Label.networkFee,
                        message: L10n.Label.networkFeeDescription.interpolating(networkFee.code)
                    )
                }
            }
            TableRow(
                title: {
                    TableRowTitle(L10n.Label.total).foregroundColor(.semantic.body)
                },
                trailing: {
                    VStack(alignment: .trailing) {
                        TableRowTitle(checkout.quote.displayString)
                        TableRowByline(checkout.value.displayString)
                    }
                }
            )
        }
        .padding(.vertical, 6.pt)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.semantic.background)
        )
    }

    @ViewBuilder func quoteExpiry() -> some View {
        if let expiration = checkout.expiresAt {
            CountdownView(deadline: expiration, remainingTime: $remainingTime)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.semantic.background)
                )
        }
    }

    func disclaimer() -> some View {
        Text(rich: L10n.Label.sellDisclaimer)
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
            PrimaryButton(title: L10n.Button.confirmSell) {
                confirm?()
                $app.post(event: blockchain.ux.transaction.checkout.confirmed)
            }
            .disabled(remainingTime < 5)
            .padding()
        }
    }
}

// MARK: Preview

struct SellCheckoutView_Previews: PreviewProvider {

    static var previews: some View {

        SellCheckoutLoadingView()
            .app(App.preview)
            .context([blockchain.ux.transaction.id: "sell"])
            .previewDisplayName("Loading")

        SellCheckoutLoadedView(checkout: .previewDeFi)
            .app(App.preview)
            .context([blockchain.ux.transaction.id: "sell"])
            .previewDisplayName("Private Key Sell")

        SellCheckoutLoadedView(checkout: .previewTrading)
            .app(App.preview)
            .context([blockchain.ux.transaction.id: "sell"])
            .previewDisplayName("Trading Sell")
    }
}
