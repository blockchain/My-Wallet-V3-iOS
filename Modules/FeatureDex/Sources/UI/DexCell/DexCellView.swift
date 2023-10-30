// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureDexDomain

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
        VStack(alignment: .center, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                networkPill
                    .frame(maxWidth: .infinity)
                currencyPill
                    .frame(maxWidth: .infinity)
            }
            amountView
            HStack(alignment: .center, spacing: 0) {
                fiatAmountView
                Spacer()
                balanceView
            }
        }
        .padding([.leading, .trailing], 16)
        .padding([.top, .bottom], 18)
        .foregroundColor(.semantic.title)
        .background(Color.semantic.background)
        .cornerRadius(Spacing.padding2)
        .onAppear {
            viewStore.send(.onAppear)
        }
        .onChange(of: viewStore.availableBalances) { _ in
            viewStore.send(.onAvailableBalancesChanged)
        }
        .onChange(of: viewStore.parentNetwork) { value in
            viewStore.send(.onCurrentNetworkChanged(value))
        }
        .bindings {
            subscribe(
                viewStore.$defaultFiatCurrency,
                to: blockchain.user.currency.preferred.fiat.trading.currency
            )
        }
        .bindings {
            subscribe(
                viewStore.$quoteByOutputEnabled,
                to: blockchain.ux.currency.exchange.dex.config.quote.by.output.is.enabled
            )
        }
        .bindings {
            subscribe(
                viewStore.$crossChainEnabled,
                to: blockchain.ux.currency.exchange.dex.config.cross.chain.is.enabled
            )
        }
        .sheet(isPresented: viewStore.$showAssetPicker, content: { assetPickerView })
        .sheet(isPresented: viewStore.$showNetworkPicker, content: { networkPickerView })
    }
}

extension DexCellView {

    @ViewBuilder
    private var assetPickerView: some View {
        IfLetStore(
            store.scope(state: \.assetPicker, action: DexCell.Action.assetPicker),
            then: { store in AssetPickerView(store: store) }
        )
    }

    @ViewBuilder
    private var networkPickerView: some View {
        IfLetStore(
            store.scope(state: \.networkPicker, action: DexCell.Action.networkPicker),
            then: { store in NetworkPickerView(store: store) }
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
            .focused($textFieldIsFocused)
            .textInputAutocapitalization(.never)
            .synchronize(viewStore.$textFieldIsFocused, $textFieldIsFocused)
            .disabled(viewStore.textFieldDisabled)
    }

    private var amountViewText: Binding<String> {
        if viewStore.isCurrentInput {
            return viewStore.$inputText.removeDuplicates()
        } else {
            return .constant(viewStore.amount?.toDisplayString(includeSymbol: false) ?? "")
        }
    }

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

    @ViewBuilder
    private var balanceView: some View {
        if viewStore.isMaxEnabled {
            Button(
                action: { viewStore.send(.onTapBalance) },
                label: {
                    balanceBody
                        .padding(Spacing.textSpacing)
                }
            )
        } else {
            balanceBody
                .padding(Spacing.textSpacing)
        }
    }

    @ViewBuilder
    private var balanceBody: some View {
        if let balance = viewStore.balance {
            balanceBodyLabel(balance.value)
        } else if viewStore.amount == nil {
            Text(" ").typography(.micro)
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

    @ViewBuilder
    private var networkPill: some View {
        Button(
            action: { viewStore.send(.onTapNetworkSelector) },
            label: {
                if let value = viewStore.currentNetwork {
                    pillButton(imageURL: value.logoURL, label: value.networkConfig.shortName)
                } else {
                    pillButtonPlaceholder
                }
            }
        )
        .disabled(viewStore.networkPickerDisabled)
    }

    @ViewBuilder
    private var currencyPill: some View {
        Button(
            action: { viewStore.send(.onTapCurrencySelector) },
            label: {
                if let value = viewStore.currency {
                    pillButton(imageURL: value.logoURL, label: value.displayCode)
                } else {
                    pillButtonPlaceholder
                }
            }
        )
    }

    @ViewBuilder
    private func pillButton(
        imageURL: URL?,
        label: String
    ) -> some View {
        HStack(spacing: 8) {
            AsyncMedia(
                url: imageURL,
                placeholder: EmptyView.init
            )
            .frame(width: 24, height: 24)
            .padding(.leading, Spacing.padding1)
            .padding(.vertical, Spacing.textSpacing)
            Text(label)
                .typography(.caption2)
                .foregroundColor(.semantic.title)
            Spacer()
            Icon.chevronRight
                .with(length: 12.pt)
                .color(.semantic.muted)
                .padding(.trailing, Spacing.padding1)
        }
        .background(Color.semantic.light)
        .cornerRadius(Spacing.padding3)
    }

    @ViewBuilder
    private var pillButtonPlaceholder: some View {
        HStack(spacing: 8) {
            Icon.coins
                .small()
                .color(.white)
                .padding(.leading, Spacing.padding1)
                .padding(.vertical, Spacing.textSpacing)
            Text(L10n.Main.select)
                .typography(.caption2)
                .foregroundColor(.white)
            Spacer()
            Icon.chevronRight
                .with(length: 12.pt)
                .color(.white)
                .padding(.trailing, Spacing.padding1)
        }
        .background(Color.semantic.primary)
        .cornerRadius(Spacing.padding3)
    }
}

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

    static var previews: some View {
        VStack {
            ForEach(states.indexed(), id: \.index) { _, state in
                DexCellView(
                    store: Store(
                        initialState: state,
                        reducer: { DexCell() }
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
