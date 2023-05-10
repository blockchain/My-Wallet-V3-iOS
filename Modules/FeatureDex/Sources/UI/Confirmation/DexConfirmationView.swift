import BlockchainUI
import SwiftUI

@available(iOS 15.0, *)
struct DexConfirmationView: View {

    struct Explain {
        let title: String
        let message: String
    }

    typealias L10n = FeatureDexUI.L10n.Confirmation

    let store: StoreOf<DexConfirmation>
    @ObservedObject var viewStore: ViewStore<DexConfirmation.State, DexConfirmation.Action>

    @State private var explain: Explain?

    init(store: StoreOf<DexConfirmation>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(alignment: .center) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 24) {
                    swap()
                    rows()
                    disclaimer()
                }
            }
            .padding(.horizontal)
            Spacer()
            footer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.semantic.light.ignoresSafeArea())
        .bindings {
            subscribe(viewStore.binding(\.$from.toFiatExchangeRate), to: blockchain.api.nabu.gateway.price.crypto[viewStore.from.currency.code].fiat.quote.value)
            subscribe(viewStore.binding(\.$to.toFiatExchangeRate), to: blockchain.api.nabu.gateway.price.crypto[viewStore.to.currency.code].fiat.quote.value)
        }
        .bottomSheet(item: $explain.animation()) { explain in
            explainer(explain)
        }
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
            PrimaryButton(title: L10n.gotIt) {
                withAnimation {
                    self.explain = nil
                }
            }
        }
        .padding()
        .multilineTextAlignment(.center)
    }

    @ViewBuilder func swap() -> some View {
        ZStack {
            VStack {
                target(viewStore.from)
                target(viewStore.to)
            }
            Icon.arrowDown
                .small()
                .color(.semantic.title)
                .circle(backgroundColor: .semantic.background)
                .background(Circle().fill(Color.semantic.light).scaleEffect(1.5))
        }
    }

    @ViewBuilder func target(_ target: DexConfirmation.State.Target) -> some View {
        let cryptoValue = target.value
        TableRow(
            title: {
                Text(cryptoValue.toDisplayString(includeSymbol: false))
                    .typography(.title2.mono())
                    .foregroundColor(.semantic.title)
            },
            byline: {
                if let exchangeRate = target.toFiatExchangeRate {
                    Text(cryptoValue.convert(using: exchangeRate).displayString)
                        .typography(.body1)
                        .foregroundColor(.semantic.body)
                }
            },
            trailing: {
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        cryptoValue.currency.logo(size: 24.pt)
                        Text(cryptoValue.currency.displayCode)
                            .typography(.body1)
                            .foregroundColor(.semantic.title)
                            .padding(.trailing, 2.pt)
                    }
                    .padding(6.pt)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.semantic.light)
                    )
                    Spacer()
                }
            }
        )
        .padding(.vertical, 4.pt)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.semantic.background)
        )
    }

    @ViewBuilder func rows() -> some View {
        DividedVStack {
            TableRow(
                title: {
                    TableRowTitle(L10n.exchangeRate).foregroundColor(.semantic.body)
                },
                trailing: {
                    TableRowTitle("\(viewStore.exchangeRate.base.displayString) = \(viewStore.exchangeRate.quote.displayString)")
                }
            )
            TableRow(
                title: {
                    TableRowTitle(L10n.allowedSlippage).foregroundColor(.semantic.body)
                },
                trailing: {
                    TableRowTitle(viewStore.slippage.formatted(.percent))
                }
            )
            TableRow(
                title: {
                    HStack {
                        TableRowTitle(L10n.minAmount).foregroundColor(.semantic.body)
                        Icon.questionCircle.micro().color(.semantic.muted)
                    }
                },
                trailing: {
                    valueWithQuote(viewStore.minimumReceivedAmount, using: viewStore.from.toFiatExchangeRate, isEstimated: false)
                }
            )
            .onTapGesture {
                explain = Explain(title: L10n.minAmount, message: L10n.minAmountDescription)
            }
            TableRow(
                title: {
                    HStack {
                        TableRowTitle(L10n.networkFee).foregroundColor(.semantic.body)
                        Icon.questionCircle.micro().color(.semantic.muted)
                    }
                },
                trailing: {
                    valueWithQuote(viewStore.fee.network, using: viewStore.from.toFiatExchangeRate)
                }
            )
            .onTapGesture {
                explain = Explain(title: L10n.networkFee, message: L10n.networkFeeDescription.interpolating(viewStore.from.currency.displayCode))
            }
            TableRow(
                title: {
                    HStack {
                        TableRowTitle(L10n.blockchainFee).foregroundColor(.semantic.body)
                        Icon.questionCircle.micro().color(.semantic.muted)
                    }
                },
                trailing: {
                    valueWithQuote(viewStore.fee.blockchain, using: viewStore.to.toFiatExchangeRate)
                }
            )
            .onTapGesture {
                explain = Explain(title: L10n.blockchainFee, message: L10n.blockchainFeeDescription)
            }
        }
        .padding(.vertical, 6.pt)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.semantic.background)
        )
    }

    @ViewBuilder func valueWithQuote(
        _ cryptoValue: CryptoValue,
        using exchangeRate: MoneyValue?,
        isEstimated: Bool = true
    ) -> some View {
        VStack(alignment: .trailing) {
            if isEstimated {
                TableRowTitle("~ \(cryptoValue.displayString)")
            } else {
                TableRowTitle(cryptoValue.displayString)
            }
            if let exchangeRate {
                TableRowByline(cryptoValue.convert(using: exchangeRate).displayString)
            }
        }
    }

    @ViewBuilder func disclaimer() -> some View {
        Text(L10n.disclaimer.interpolating(viewStore.minimumReceivedAmount.displayString))
            .typography(.caption1)
            .foregroundColor(.semantic.body)
            .multilineTextAlignment(.center)
    }

    func footer() -> some View {
        VStack(spacing: Spacing.padding2) {
            if viewStore.priceUpdated {
                HStack {
                    Icon.error.color(.semantic.warning).small()
                    Text(L10n.priceUpdated)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)
                    Spacer()
                    SmallPrimaryButton(title: L10n.accept) {
                        viewStore.send(.acceptPrice, animation: .linear)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.semantic.light)
                )
            }
            Group {
                if viewStore.enoughBalance {
                    PrimaryButton(title: L10n.swap) {
                        viewStore.send(.confirm)
                    }
                    .disabled(viewStore.priceUpdated)
                } else {
                    Text(L10n.notEnoughBalance.interpolating(viewStore.from.currency.displayCode))
                        .typography(.caption1)
                        .foregroundColor(.semantic.warning)
                    AlertButton(
                        title: L10n.notEnoughBalanceButton.interpolating(viewStore.from.currency.displayCode),
                        action: {}
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.semantic.background)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

@available(iOS 15.0, *)
struct DexConfirmationView_Previews: PreviewProvider {

    static var app: AppProtocol = App.preview.withPreviewData()

    static var previews: some View {
        DexConfirmationView(
            store: .init(
                initialState: .preview,
                reducer: DexConfirmation(app: app)
            )
        )
        .app(app)
        .previewDisplayName("Confirmation")

        DexConfirmationView(
            store: .init(
                initialState: .preview.setup { state in
                    state.priceUpdated = true
                },
                reducer: DexConfirmation(app: app)
            )
        )
        .app(app)
        .previewDisplayName("Price updated")

        DexConfirmationView(
            store: .init(
                initialState: .preview.setup { state in
                    state.enoughBalance = false
                },
                reducer: DexConfirmation(app: app)
            )
        )
        .app(app)
        .previewDisplayName("Not enough balance")
    }
}
