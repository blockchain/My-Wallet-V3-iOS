// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureDexDomain
import MoneyKit

extension AssetPicker {

    public struct State: Equatable {
        let balances: [RowData]
        let tokens: [RowData]
        let allData: [RowData]

        var networkTransactionInProgressCard: Bool = false
        var searchResults: [RowData]
        let currentNetwork: EVMNetwork
        @BindingState var searchText: String
        @BindingState var isSearching: Bool

        init(
            balances: [RowData],
            tokens: [RowData],
            currentNetwork: EVMNetwork,
            searchText: String,
            isSearching: Bool
        ) {
            self.balances = balances
            self.tokens = tokens
            self.searchText = searchText
            self.isSearching = isSearching
            self.allData = balances + tokens
            self.searchResults = balances + tokens
            self.currentNetwork = currentNetwork
        }

        init(
            balances: [DexBalance],
            tokens: [CryptoCurrency],
            denylist: [CryptoCurrency],
            currentNetwork: EVMNetwork,
            searchText: String = "",
            isSearching: Bool = false
        ) {
            let balances = balances
                .filter { !denylist.contains($0.currency) }
                .filter { $0.network == currentNetwork }
                .map(RowData.Content.balance)
                .map(RowData.init(content:))
            let denylist = denylist + balances.map(\.currency)
            let tokens = tokens
                .filter { !denylist.contains($0) }
                .filter { $0.network() == currentNetwork }
                .sorted(by: { $0.displayCode < $1.displayCode })
                .map(RowData.Content.token)
                .map(RowData.init(content:))
            self.init(
                balances: balances,
                tokens: tokens,
                currentNetwork: currentNetwork,
                searchText: searchText,
                isSearching: isSearching
            )
        }
    }
}
