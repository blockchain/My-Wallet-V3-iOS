import BlockchainUI
import FeatureCheckoutDomain
import SwiftUI

public struct WithdrawCheckoutView: View {

    @BlockchainApp var app

    let checkout: WithdrawCheckout
    let confirm: (() -> Void)?

    @State private var isExternalTradingEnabled: Bool = false

    public init(checkout: WithdrawCheckout, confirm: (() -> Void)? = nil) {
        self.checkout = checkout
        self.confirm = confirm
    }

    public var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            ScrollView {
                Group {
                    rows()
                    disclaimer()
                }
                .padding(.horizontal)
            }
            footer()
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .bindings {
            subscribe($isExternalTradingEnabled, to: blockchain.app.is.external.brokerage)
        }
    }

    @ViewBuilder func rows() -> some View {
        DividedVStack(spacing: .zero) {
            from()
            to()
            if !isExternalTradingEnabled {
                fee()
            }
            settlement()
            total()
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.semantic.background)
        )
    }

    @ViewBuilder func from() -> some View {
        TableRow(
            title: {
                Text(L10n.Label.from)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
            },
            byline: {
                Text(checkout.from)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            }
        )
    }

    @ViewBuilder func to() -> some View {
        TableRow(
            title: {
                Text(L10n.Label.to)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
            },
            byline: {
                Text(checkout.to)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            }
        )
    }

    @ViewBuilder func fee() -> some View {
        TableRow(
            title: {
                Text(L10n.Label.blockchainFee)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
            },
            byline: {
                Text(checkout.fee.displayString)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            }
        )
    }

    @State private var now: Date = Date()
    @State private var relativeDateTimeFormatter = with(RelativeDateTimeFormatter()) { formatter in
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
    }

    @ViewBuilder func settlement() -> some View {
        if let settlementDate = checkout.settlementDate {
            TableRow(
                title: {
                    Text(L10n.Label.fundsWillArrive)
                        .typography(.caption1)
                        .foregroundColor(.semantic.text)
                },
                byline: {
                    Text(relativeDateTimeFormatter.localizedString(for: settlementDate, relativeTo: now))
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)
                }
            )
        }
    }

    @ViewBuilder func total() -> some View {
        TableRow(
            title: {
                Text(L10n.Label.total)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
            },
            byline: {
                Text(checkout.total.displayString)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            }
        )
    }

    @ViewBuilder func disclaimer() -> some View {
        let date = DateFormatter.birthday.string(from: Date.now)

        VStack(alignment: .leading) {
            Text(rich: isExternalTradingEnabled ?
                 L10n.Label.withdrawDisclaimerBakkt(date: date) :
                    L10n.Label.withdrawDisclaimer.interpolating(checkout.total.displayString))
                .typography(.caption1)
                .foregroundColor(.semantic.text)
            if isExternalTradingEnabled {
                Image("bakkt-logo", bundle: .componentLibrary)
                    .foregroundColor(.semantic.title)
                    .padding(.top, Spacing.padding2)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder func footer() -> some View {
        VStack(spacing: .zero) {
            PrimaryButton(
                title: L10n.Label.withdraw,
                action: confirmed
            )
        }
        .padding()
        .background(Rectangle().fill(Color.semantic.background).ignoresSafeArea())
    }

    func confirmed() {
        $app.post(event: blockchain.ux.transaction.checkout.confirmed)
        confirm?()
    }
}

public struct AsyncCheckoutView<Object: LoadableObject, Checkout, CheckoutView: View>: View where Object.Output == Checkout, Object.Failure == Never {

    @BlockchainApp var app
    @Environment(\.context) var context

    @ObservedObject var viewModel: Object
    var checkout: (Checkout) -> CheckoutView

    public init(
        viewModel: Object,
        checkout: @escaping (Checkout) -> CheckoutView
    ) {
        _viewModel = .init(wrappedValue: viewModel)
        self.checkout = checkout
    }

    public var body: some View {
        AsyncContentView(
            source: viewModel,
            loadingView: Loading(),
            content: checkout
        )
        .onAppear {
            app.post(
                event: blockchain.ux.transaction.checkout[].ref(to: context),
                context: context
            )
        }
    }
}

extension AsyncCheckoutView {

    public init<P>(
        publisher: P,
        checkout: @escaping (Checkout) -> CheckoutView
    ) where P: Publisher, P.Output == Checkout, P.Failure == Never, Object == PublishedObject<P, DispatchQueue> {
        self.viewModel = PublishedObject(publisher: publisher)
        self.checkout = checkout
    }

    public init(
        _ object: Checkout,
        checkout: @escaping (Checkout) -> CheckoutView
    ) where Object == PublishedObject<Just<Checkout>, DispatchQueue> {
        self.init(publisher: Just(object), checkout: checkout)
    }
}

extension AsyncCheckoutView {

    public struct Loading: View {

        public var body: some View {
            ZStack {
                BlockchainProgressView()
            }
        }
    }
}

struct WithdrawCheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawCheckoutView(checkout: .preview)
    }
}
