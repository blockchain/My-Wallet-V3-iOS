// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import FeatureDexDomain
import MoneyKit
import SwiftExtensions
import SwiftUI

public struct AssetPicker: ReducerProtocol {

    public enum Action: Equatable, BindableAction {
        case onAppear
        case onDismiss
        case binding(BindingAction<State>)
        case onAssetTapped(AssetRowData)
    }

    public struct State: Equatable {
        let balances: [AssetRowData]
        let tokens: [AssetRowData]
        let allData: [AssetRowData]

        var searchResults: [AssetRowData]
        @BindingState var searchText: String
        @BindingState var isSearching: Bool

        init(
            balances: [AssetRowData],
            tokens: [AssetRowData],
            searchText: String,
            isSearching: Bool
        ) {
            self.balances = balances
            self.tokens = tokens
            self.searchText = searchText
            self.isSearching = isSearching
            self.allData = balances + tokens
            self.searchResults = balances + tokens
        }

        init(
            balances: [DexBalance],
            tokens: [CryptoCurrency],
            denylist: [CryptoCurrency],
            currentNetwork: Chain?,
            searchText: String = "",
            isSearching: Bool = false
        ) {
            let balances = balances
                .filter { !denylist.contains($0.currency) }
                .filter({ balance in
                    guard let network = balance.network else {
                        return false
                    }
                    return network.networkConfig.chainID.i64 == currentNetwork?.chainId
                })
                .map(AssetRowData.Content.balance)
                .map(AssetRowData.init(content:))
            let tokens = tokens
                .filter { !denylist.contains($0) }
                .filter({ currency in
                    guard let network = currency.network() else {
                        return false
                    }
                    return network.networkConfig.chainID.i64 == currentNetwork?.chainId
                })
                .map(AssetRowData.Content.token)
                .map(AssetRowData.init(content:))
            self.init(balances: balances, tokens: tokens, searchText: searchText, isSearching: isSearching)
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.$searchText):
                state.searchResults = state.allData.filtered(by: state.searchText)
                return .none
            case .onAppear:
                return .none
            case .onDismiss:
                return .none
            case .onAssetTapped:
                return .none
            case .binding:
                return .none
            }
        }
    }
}

public struct AssetRowData: Equatable, Identifiable, Hashable {

    public enum Content: Equatable, Identifiable, Hashable {
        case balance(DexBalance)
        case token(CryptoCurrency)

        public var currency: CryptoCurrency {
            switch self {
            case .balance(let balance):
                return balance.currency
            case .token(let currency):
                return currency
            }
        }

        public var id: String {
            switch self {
            case .balance(let balance):
                return "balance-\(balance.currency.code)"
            case .token(let currency):
                return "token-\(currency.code)"
            }
        }
    }

    public var id: String { content.id }
    public let content: Content

    public var currency: CryptoCurrency {
        content.currency
    }
}

extension [AssetRowData] {

    func filtered(
        by searchText: String,
        using algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: true)
    ) -> Self {
        filter {
            $0.currency.filter(by: searchText, using: algorithm)
        }
    }
}
