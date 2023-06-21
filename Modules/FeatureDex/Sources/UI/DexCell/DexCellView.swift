// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureDexDomain

@available(iOS 15.0, *)
@MainActor
public struct DexCellView: View {

    @BlockchainApp var app
    let store: Store<DexCell.State, DexCell.Action>
    @ObservedObject var viewStore: ViewStore<DexCell.State, DexCell.Action>
    @FocusState var textFieldIsFocused: Bool

    init(store: Store<DexCell.State, DexCell.Action>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        TableRow(
            title: { amountView },
            byline: { fiatAmountView },
            trailing: {
                VStack(alignment: .trailing) {
                    currencyPill
                    balanceView
                }
            }
        )
        .background(Color.semantic.background)
        .cornerRadius(Spacing.padding2)
        .onAppear {
            viewStore.send(.onAppear)
        }
        .onChange(of: viewStore.currentNetwork) { _ in
            viewStore.send(.onCurrentNetworkChanged)
        }
        .bindings {
            if let currency = viewStore.balance?.currency.code {
                subscribe(
                    viewStore.binding(\.$price),
                    to: blockchain.api.nabu.gateway.price.crypto[currency].fiat.quote.value
                )
            }
        }
        .bindings {
            subscribe(
                viewStore.binding(\.$defaultFiatCurrency),
                to: blockchain.user.currency.preferred.fiat.trading.currency
            )
        }
        .sheet(isPresented: viewStore.binding(\.$showAssetPicker), content: { assetPickerView })
    }
}

@available(iOS 15.0, *)
extension DexCellView {

    @ViewBuilder
    private var assetPickerView: some View {
        IfLetStore(
            store.scope(state: \.assetPicker, action: DexCell.Action.assetPicker),
            then: { store in AssetPickerView(store: store) }
        )
    }

    @ViewBuilder
    private var amountView: some View {
        TextField("0", text: amountViewText)
            .textFieldStyle(.plain)
            .padding(.bottom, 2)
            .keyboardType(.decimalPad)
            .disableAutocorrection(true)
            .typography(.title2.slashedZero())
            .foregroundColor(.semantic.title)
            .disabled(viewStore.style.isDestination)
            .focused($textFieldIsFocused)
            .textInputAutocapitalization(.never)
            .synchronize(viewStore.binding(\.$textFieldIsFocused), $textFieldIsFocused)
    }

    private var amountViewText: Binding<String> {
        switch viewStore.style {
        case .source:
            return viewStore.binding(\.$inputText).removeDuplicates()
        case .destination:
            return .constant(viewStore.amount?.toDisplayString(includeSymbol: false) ?? "")
        }
    }
}

@available(iOS 15.0, *)
extension DexCellView {

    @ViewBuilder
    private var fiatAmountView: some View {
        if let amountFiat = viewStore.amountFiat {
            Text(amountFiat.displayString)
                .typography(.body1)
                .foregroundColor(.semantic.text)
        } else {
            ProgressView()
        }
    }
}

@available(iOS 15.0, *)
extension DexCellView {

    @ViewBuilder
    private var balanceView: some View {
        if viewStore.isMaxEnabled {
            Button(
                action: { viewStore.send(.onTapBalance) },
                label: { balanceBody }
            )
        } else {
            balanceBody
        }
    }

    @ViewBuilder
    private var balanceBody: some View {
        if let balance = viewStore.balance {
            balanceBodyLabel(balance.value)
        } else if viewStore.amount == nil {
            Text(" ")
        } else {
            ProgressView()
        }
    }

    @ViewBuilder
    private func balanceBodyLabel(_ value: CryptoValue) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.textSpacing) {
            Text(viewStore.isMaxEnabled ? L10n.Main.max : L10n.Main.balance)
                .typography(.micro)
                .foregroundColor(.semantic.text)
            Text(value.displayString)
                .typography(.micro)
                .foregroundColor(viewStore.isMaxEnabled ? .semantic.primary : .semantic.title)
        }
    }
}

@available(iOS 15.0, *)
extension DexCellView {

    @ViewBuilder
    private var currencyPill: some View {
        Button(
            action: { viewStore.send(.onTapCurrencySelector) },
            label: {
                if let value = viewStore.currency {
                    currencyPillBody(value)
                } else {
                    currencyPillPlaceholder
                }
            }
        )
    }

    @ViewBuilder
    private func currencyPillBody(_ value: CryptoCurrency) -> some View {
        HStack {
            AsyncMedia(
                url: value.logoURL,
                placeholder: EmptyView.init
            )
            .frame(width: 16, height: 16)
            Text(value.displayCode)
                .typography(.body1)
                .foregroundColor(.semantic.title)
            Icon.chevronRight
                .color(.semantic.muted)
                .frame(width: 12, height: 12)
        }
        .padding(.all, Spacing.padding1)
        .background(Color.semantic.light)
        .cornerRadius(Spacing.padding2)
    }

    @ViewBuilder
    private var currencyPillPlaceholder: some View {
        HStack {
            Icon.coins
                .color(.white)
                .frame(width: 16, height: 16)
            Text(L10n.Main.select)
                .typography(.body1)
                .foregroundColor(.white)
            Icon.chevronRight
                .color(.white)
                .frame(width: 12, height: 12)
        }
        .padding(.all, Spacing.padding1)
        .background(Color.semantic.primary)
        .cornerRadius(Spacing.padding2)
    }
}

@available(iOS 15.0, *)
struct DexCellView_Previews: PreviewProvider {

    static let app: AppProtocol = App.preview.withPreviewData()

    static var availableBalances: [DexBalance] {
        supportedTokens
            .map(CryptoValue.one(currency:))
            .map(DexBalance.init(value:))
    }

    static var supportedTokens: [CryptoCurrency] {
        [.ethereum, .bitcoin]
    }

    static var states: [DexCell.State] {
        [
            DexCell.State(
                style: .source,
                availableBalances: availableBalances,
                supportedTokens: supportedTokens
            ),
            DexCell.State(
                style: .source
            )
        ]
    }

    @ViewBuilder
    static var previews: some View {
        VStack {
            ForEach(states.indexed(), id: \.index) { _, state in
                DexCellView(
                    store: Store(
                        initialState: state,
                        reducer: DexCell()
                    )
                )
                .app(app)
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.padding2)
        .background(Color.semantic.light.ignoresSafeArea())
    }
}
