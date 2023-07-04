// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureDexDomain
import MoneyKit

public struct AssetPickerView: View {

    let store: StoreOf<AssetPicker>
    @ObservedObject var viewStore: ViewStoreOf<AssetPicker>

    init(store: StoreOf<AssetPicker>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    @ViewBuilder
    public var body: some View {
        VStack(spacing: Spacing.padding3) {
            searchBarSection
            transactionInProgressCard
            ScrollView {
                assetsSection
            }
        }
        .padding(.horizontal, Spacing.padding2)
        .background(Color.semantic.light.ignoresSafeArea())
        .superAppNavigationBar(
            leading: { EmptyView() },
            title: {
                Text(L10n.AssetPicker.selectToken)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
            },
            trailing: {
                IconButton(
                    icon: .closeCirclev3.color(.black),
                    action: { viewStore.send(.onDismiss) }
                )
                .frame(width: 20, height: 20)
            },
            scrollOffset: nil
        )
        .onAppear {
            viewStore.send(.onAppear)
        }
    }

    @ViewBuilder
    private var searchBarSection: some View {
        SearchBar(
            text: viewStore.binding(\.$searchText),
            isFirstResponder: viewStore.binding(\.$isSearching),
            cancelButtonText: L10n.AssetPicker.cancel,
            placeholder: L10n.AssetPicker.search
        )
        .frame(height: 48)
        .padding(.top, Spacing.padding3)
    }

    @ViewBuilder
    private var assetsSection: some View {
        if viewStore.isSearching, viewStore.searchText.isNotEmpty {
            section(
                data: viewStore.searchResults,
                sectionTitle: nil,
                showEmptyState: true
            )
        } else {
            VStack(spacing: Spacing.padding1) {
                section(
                    data: viewStore.balances,
                    sectionTitle: L10n.AssetPicker.yourAssets,
                    showEmptyState: false
                )
                section(
                    data: viewStore.tokens,
                    sectionTitle: L10n.AssetPicker.allTokens,
                    showEmptyState: false
                )
            }
        }
    }

    @ViewBuilder
    private func section(
        data: [AssetPicker.RowData],
        sectionTitle: String?,
        showEmptyState: Bool
    ) -> some View {
        if data.isNotEmpty {
            VStack(spacing: 0) {
                if let sectionTitle {
                    HStack {
                        Text(sectionTitle)
                            .typography(.body2)
                            .foregroundColor(.semantic.body)
                        Spacer()
                    }
                    .padding(.bottom, Spacing.padding1)
                }
                LazyVStack(spacing: 0) {
                    ForEach(data) { rowData in
                        row(data: rowData)
                        if rowData.id != data.last?.id {
                            PrimaryDivider()
                        }
                    }
                }
                .cornerRadius(16, corners: .allCorners)
            }
        } else if showEmptyState {
            noResultsView
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func row(
        data: AssetPicker.RowData
    ) -> some View {
        Group {
            switch data.content {
            case .balance(let balance):
                balance.value.moneyValue
                    .rowView(
                        .quote,
                        byline: { MoneyValueCodeNetworkView(balance.value.currencyType) }
                    )
            case .token(let token):
                MoneyValue
                    .one(currency: .crypto(token))
                    .rowView(
                        .delta,
                        byline: {
                            HStack(spacing: Spacing.padding1) {
                                Text(token.displayCode)
                                    .typography(.caption1.slashedZero())
                                    .foregroundColor(.semantic.text)
                            }
                        }
                    )
            }
        }
        .onTapGesture {
            viewStore.send(.set(\.$isSearching, false))
            viewStore.send(.onAssetTapped(data))
        }
    }

    @ViewBuilder
    private var noResultsView: some View {
        HStack(alignment: .center, content: {
            Text(L10n.AssetPicker.noResults)
                .padding(.vertical, Spacing.padding2)
        })
        .frame(maxWidth: .infinity)
        .background(Color.semantic.background)
        .cornerRadius(16, corners: .allCorners)
    }

    @ViewBuilder
    private var transactionInProgressCard: some View {
        if viewStore.networkTransactionInProgressCard {
            AlertCard(
                title: L10n.TransactionInProgress.title,
                message: L10n.TransactionInProgress.body
                    .interpolating(viewStore.currentNetwork.networkConfig.name),
                variant: .default,
                isBordered: false,
                backgroundColor: .semantic.background,
                onCloseTapped: {
                    viewStore.send(.didTapCloseInProgressCard)
                }
            )
        }
    }
}

struct AssetPickerView_Previews: PreviewProvider {

    private static var app = App.preview.withPreviewData()

    private static var usdt: CryptoCurrency! {
        _ = app
        return EnabledCurrenciesService.default
            .allEnabledCryptoCurrencies
            .first(where: { $0.code == "USDT" })
    }

    private static var currencies: [CryptoCurrency] {
        [usdt, .bitcoin, .ethereum, .bitcoinCash, .stellar]
    }

    private static var balances: [AssetPicker.RowData] = currencies
        .map { CryptoValue.create(major: Decimal(2), currency: $0) }
        .map(DexBalance.init(value:))
        .map(AssetPicker.RowData.Content.balance)
        .map(AssetPicker.RowData.init(content:))

    private static var tokens: [AssetPicker.RowData] = currencies
        .map(AssetPicker.RowData.Content.token)
        .map(AssetPicker.RowData.init(content:))

    static var previews: some View {
        AssetPickerView(
            store: Store(
                initialState: AssetPicker.State(
                    balances: balances,
                    tokens: tokens,
                    currentNetwork: .init(networkConfig: .ethereum, nativeAsset: .ethereum),
                    searchText: "",
                    isSearching: false
                ),
                reducer: AssetPicker()
            )
        )
        .app(app)
    }
}
