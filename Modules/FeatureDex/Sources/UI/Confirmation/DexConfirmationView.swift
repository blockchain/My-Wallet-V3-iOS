// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureDexDomain
import SwiftUI

struct DexConfirmationView: View {

    typealias L10n = FeatureDexUI.L10n.Confirmation

    let store: StoreOf<DexConfirmation>
    @ObservedObject var viewStore: ViewStore<DexConfirmation.State, DexConfirmation.Action>
    @Environment(\.presentationMode) private var presentationMode
    @BlockchainApp var app

    init(store: StoreOf<DexConfirmation>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    @ViewBuilder
    var body: some View {
        Group {
            VStack(alignment: .center) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 24) {
                        swap()
                            .padding(.top, Spacing.padding2)
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
                subscribe(
                    viewStore.binding(\.$fromFiatExchangeRate),
                    to: blockchain.api.nabu.gateway.price.crypto[viewStore.quote.from.currency.code].fiat.quote.value
                )
            }
            .bindings {
                subscribe(
                    viewStore.binding(\.$toFiatExchangeRate),
                    to: blockchain.api.nabu.gateway.price.crypto[viewStore.quote.to.currency.code].fiat.quote.value
                )
            }
            PrimaryNavigationLink(
                destination: pendingTransactionView,
                isActive: viewStore.binding(\.$didConfirm),
                label: EmptyView.init
            )
        }
        .primaryNavigation(
            title: L10n.title,
            trailing: { closeButton }
        )
    }

    @ViewBuilder
    private var pendingTransactionView: some View {
        IfLet(viewStore.binding(\.$pendingTransaction), then: { $state in
            PendingTransactionView(
                state: state,
                dismiss: { presentationMode.wrappedValue.dismiss() }
            )
        })
    }

    @ViewBuilder
    private var closeButton: some View {
        Button(
            action: { presentationMode.wrappedValue.dismiss() },
            label: {
                Icon
                    .closev2
                    .circle(backgroundColor: .semantic.light)
                    .frame(width: 24, height: 24)
            }
        )
    }

    @ViewBuilder
    private func swap() -> some View {
        ZStack {
            VStack {
                target(
                    viewStore.quote.from,
                    exchangeRate: viewStore.fromFiatExchangeRate,
                    balance: viewStore.sourceBalance
                )
                target(
                    viewStore.quote.to,
                    exchangeRate: viewStore.toFiatExchangeRate,
                    balance: viewStore.destinationBalance
                )
            }
            Icon.arrowDown
                .small()
                .color(.semantic.title)
                .circle(backgroundColor: .semantic.background)
                .background(Circle().fill(Color.semantic.light).scaleEffect(1.5))
        }
    }

    @ViewBuilder
    private func target(
        _ target: DexConfirmation.State.Target,
        exchangeRate: MoneyValue?,
        balance: DexBalance?
    ) -> some View {
        TableRow(
            title: {
                Text(target.value.toDisplayString(includeSymbol: false))
                    .typography(.title2.slashedZero())
                    .foregroundColor(.semantic.title)
            },
            byline: {
                if let exchangeRate {
                    Text(target.value.convert(using: exchangeRate).displayString)
                        .typography(.body1)
                        .foregroundColor(.semantic.body)
                }
            },
            trailing: {
                HStack(alignment: .center) {
                    VStack(alignment: .trailing, spacing: 8.pt) {
                        balancePill(target.value.currency)
                        balanceLabel(balance)
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

    @ViewBuilder
    private func balancePill(_ currency: CryptoCurrency) -> some View {
        VStack(spacing: 4) {
            HStack {
                currency.logo(size: 16.pt)
                    .padding(.leading, 8.pt)
                    .padding(.vertical, 8.pt)
                Text(currency.displayCode)
                    .typography(.body1)
                    .foregroundColor(.semantic.title)
                    .padding(.trailing, 8.pt)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.semantic.light)
            )
        }
    }

    @ViewBuilder
    private func balanceLabel(_ balance: DexBalance?) -> some View {
        if let balance {
            HStack(spacing: 4) {
                Text(FeatureDexUI.L10n.Main.balance)
                    .typography(.micro)
                    .foregroundColor(.semantic.body)
                Text(balance.value.displayString)
                    .typography(.micro)
                    .foregroundColor(.semantic.title)
            }
        }
    }

    @ViewBuilder
    private func rows() -> some View {
        DividedVStack {
            TableRow(
                title: {
                    TableRowTitle(L10n.network).foregroundColor(.semantic.body)
                },
                trailing: {
                    TableRowTitle("\(viewStore.quote.from.currency.network()?.nativeAsset.name)")
                }
            )
            TableRow(
                title: {
                    TableRowTitle(L10n.exchangeRate).foregroundColor(.semantic.body)
                },
                trailing: {
                    TableRowTitle("\(viewStore.quote.exchangeRate.base.displayString) = \(viewStore.quote.exchangeRate.quote.displayString)")
                }
            )
            TableRow(
                title: {
                    TableRowTitle(L10n.allowedSlippage).foregroundColor(.semantic.body)
                },
                trailing: {
                    TableRowTitle(formatSlippage(viewStore.quote.slippage))
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
                    valueWithQuote(
                        viewStore.quote.minimumReceivedAmount,
                        using: viewStore.toFiatExchangeRate,
                        isEstimated: false
                    )
                }
            )
            .onTapGesture {
                showTooltip(title: L10n.minAmount, message: L10n.minAmountDescription)
            }
            TableRow(
                title: {
                    HStack {
                        TableRowTitle(L10n.networkFee).foregroundColor(.semantic.body)
                        Icon.questionCircle.micro().color(.semantic.muted)
                    }
                },
                trailing: {
                    valueWithQuote(
                        viewStore.quote.networkFee,
                        using: viewStore.fromFiatExchangeRate
                    )
                }
            )
            .onTapGesture {
                showTooltip(
                    title: L10n.networkFee,
                    message: L10n.networkFeeDescription.interpolating(viewStore.quote.networkFee.displayCode)
                )
            }
            TableRow(
                title: {
                    HStack {
                        TableRowTitle(L10n.blockchainFee).foregroundColor(.semantic.body)
                        Icon.questionCircle.micro().color(.semantic.muted)
                    }
                },
                trailing: {
                    valueWithQuote(
                        viewStore.quote.productFee,
                        using: viewStore.toFiatExchangeRate
                    )
                }
            )
            .onTapGesture {
                showTooltip(
                    title: L10n.blockchainFee,
                    message: L10n.blockchainFeeDescription
                )
            }
        }
        .padding(.vertical, 6.pt)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.semantic.background)
        )
    }

    @ViewBuilder
    private func valueWithQuote(
        _ cryptoValue: CryptoValue,
        using exchangeRate: MoneyValue?,
        isEstimated: Bool = true
    ) -> some View {
        VStack(alignment: .trailing) {
            TableRowTitle(valueWithQuoteTitle(cryptoValue, isEstimated: isEstimated))
            if let byline = valueWithQuoteByline(cryptoValue, using: exchangeRate, isEstimated: isEstimated) {
                TableRowByline(byline)
            }
        }
    }

    private func valueWithQuoteTitle(
        _ cryptoValue: CryptoValue,
        isEstimated: Bool
    ) -> String {
        isEstimated ? "~ \(cryptoValue.displayString)" : cryptoValue.displayString
    }

    private func valueWithQuoteByline(
        _ cryptoValue: CryptoValue,
        using exchangeRate: MoneyValue?,
        isEstimated: Bool
    ) -> String? {
        guard let exchangeRate else {
            return nil
        }
        let string = cryptoValue.convert(using: exchangeRate).displayString
        return isEstimated ? "~ \(string)" : string
    }

    @ViewBuilder
    private func disclaimer() -> some View {
        Text(L10n.disclaimer.interpolating(viewStore.quote.minimumReceivedAmount.displayString))
            .typography(.caption1)
            .foregroundColor(.semantic.body)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private func footer() -> some View {
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
                if viewStore.quote.enoughBalance {
                    PrimaryButton(title: L10n.swap) {
                        viewStore.send(.confirm)
                    }
                    .disabled(viewStore.priceUpdated)
                } else {
                    Text(L10n.notEnoughBalance.interpolating(viewStore.quote.from.currency.displayCode))
                        .typography(.caption1)
                        .foregroundColor(.semantic.warning)
                    AlertButton(
                        title: L10n.notEnoughBalanceButton.interpolating(viewStore.quote.from.currency.displayCode),
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
        .batch {
            set(blockchain.ux.tooltip.entry.paragraph.button.minimal.tap.then.enter.into, to: blockchain.ux.tooltip)
        }
    }

    func showTooltip(title: String, message: String) {
        $app.post(
            event: blockchain.ux.tooltip.entry.paragraph.button.minimal.tap,
            context: [
                blockchain.ux.tooltip.title: title,
                blockchain.ux.tooltip.body: message,
                blockchain.ui.type.action.then.enter.into.detents: [
                    blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                ]
            ])
    }
}

struct DexConfirmationView_Previews: PreviewProvider {

    static var app: AppProtocol = App.preview.withPreviewData()

    @ViewBuilder
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
                    state.newQuote = DexConfirmation.State.Quote.preview
                },
                reducer: DexConfirmation(app: app)
            )
        )
        .app(app)
        .previewDisplayName("Price updated")

        DexConfirmationView(
            store: .init(
                initialState: .preview.setup { state in
                    state.quote.enoughBalance = false
                },
                reducer: DexConfirmation(app: app)
            )
        )
        .app(app)
        .previewDisplayName("Not enough balance")
    }
}
