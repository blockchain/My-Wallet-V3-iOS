// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import MoneyKit
import SwiftExtensions
import SwiftUI

@available(iOS 15, *)
public struct AssetPicker: ReducerProtocol {
    public let app: AppProtocol

    public init(
        app: AppProtocol
    ) {
        self.app = app
    }

    public enum Action: Equatable, BindableAction {
        case onAppear
        case onDismiss
        case binding(BindingAction<State>)
        case onAssetTapped(AssetRowData)
    }

    public struct State: Equatable {
        var balances: [AssetRowData] = []
        var tokens: [AssetRowData] = []
        var allData: [AssetRowData] { balances + tokens }
        @BindingState var searchText: String
        @BindingState var isSearching: Bool

        init(
            balances: [AssetRowData],
            tokens: [AssetRowData],
            searchText: String = "",
            isSearching: Bool = false
        ) {
            self.balances = balances
            self.tokens = tokens
            self.searchText = searchText
            self.isSearching = isSearching
        }

        @_disfavoredOverload
        init(
            balances: [DexBalance],
            tokens: [CryptoCurrency],
            searchText: String = "",
            isSearching: Bool = false
        ) {
            self.balances = balances.map(AssetRowData.Content.balance).map(AssetRowData.init(content:))
            self.tokens = tokens.map(AssetRowData.Content.token).map(AssetRowData.init(content:))
            self.searchText = searchText
            self.isSearching = isSearching
        }

        var searchResults: [AssetRowData] {
            guard searchText.isNotEmpty else {
                return allData
            }
            return allData.filtered(by: searchText)
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        EmptyReducer()
    }
}

@available(iOS 15, *)
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

@available(iOS 15, *)
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
