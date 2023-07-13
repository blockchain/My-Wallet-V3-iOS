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
                    viewStore.binding(\.$networkFiatExchangeRate),
                    to: blockchain.api.nabu.gateway.price.crypto[viewStore.quote.networkFee.currency.code].fiat.quote.value
                )
            }
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
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
            },
            byline: {
                if let exchangeRate {
                    Text(target.value.convert(using: exchangeRate).displayString)
                        .typography(.body1)
                        .foregroundColor(.semantic.body)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
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
            tableRow(
                title: L10n.network,
                value: {
                    tableRowTitle(viewStore.quote.from.currency.network()?.networkConfig.name ?? "")
                },
                tooltip: nil
            )
            tableRow(
                title: L10n.exchangeRate,
                value: {
                    tableRowTitle("\(viewStore.quote.exchangeRate.base.displayString) = \(viewStore.quote.exchangeRate.quote.displayString)")
                },
                tooltip: nil
            )
            tableRow(
                title: L10n.allowedSlippage,
                value: {
                    tableRowTitle(formatSlippage(viewStore.quote.slippage))
                },
                tooltip: (L10n.allowedSlippage, FeatureDexUI.L10n.Settings.body)
            )
            if let minimumReceivedAmount = viewStore.quote.minimumReceivedAmount {
                tableRow(
                    title: L10n.minAmount,
                    value: {
                        valueWithQuote(
                            minimumReceivedAmount,
                            using: viewStore.toFiatExchangeRate,
                            isEstimated: false
                        )
                    },
                    tooltip: (title: L10n.minAmount, message: L10n.minAmountDescription)
                )
            }
            tableRow(
                title: L10n.networkFee,
                value: {
                    valueWithQuote(
                        viewStore.quote.networkFee,
                        using: viewStore.networkFiatExchangeRate
                    )
                },
                tooltip: (L10n.networkFee, L10n.networkFeeDescription.interpolating(viewStore.quote.networkFee.displayCode))
            )
            tableRow(
                title: L10n.blockchainFee,
                value: {
                    valueWithQuote(
                        viewStore.quote.productFee,
                        using: viewStore.toFiatExchangeRate
                    )
                },
                tooltip: (L10n.blockchainFee, L10n.blockchainFeeDescription)
            )
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
        if let minimumReceivedAmount = viewStore.quote.minimumReceivedAmount {
            Text(L10n.disclaimer.interpolating(minimumReceivedAmount.displayString))
                .typography(.caption1)
                .foregroundColor(.semantic.body)
                .multilineTextAlignment(.center)
        }
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

    @ViewBuilder
    private func tableRowTitle(_ string: String) -> some View {
        TableRowTitle(string)
            .lineLimit(1)
            .minimumScaleFactor(0.1)
    }

    @ViewBuilder
    private func tableRow(
        title: String,
        value: () -> some View,
        tooltip: (title: String, message: String)?
    ) -> some View {
        TableRow(
            title: {
                HStack {
                    TableRowTitle(title)
                        .foregroundColor(.semantic.body)
                    if tooltip != nil {
                        Icon.questionCircle
                            .micro()
                            .color(.semantic.muted)
                    }
                }
            },
            trailing: value
        )
        .onTapGesture {
            if let (title, body) = tooltip {
                $app.post(
                    event: blockchain.ux.tooltip.entry.paragraph.button.minimal.tap,
                    context: [
                        blockchain.ux.tooltip.title: title,
                        blockchain.ux.tooltip.body: body,
                        blockchain.ui.type.action.then.enter.into.detents: [
                            blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                        ]
                    ]
                )
            }
        }
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
                    state.newQuote = DexConfirmation.State.Quote.preview()
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
