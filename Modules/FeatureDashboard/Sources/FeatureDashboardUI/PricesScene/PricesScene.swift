// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import FeatureDashboardDomain
import FeatureTopMoversCryptoDomain
import FeatureTopMoversCryptoUI
import Foundation
import MoneyKit
import SwiftExtensions
import SwiftUI

public struct PricesScene: Reducer {

    public let app: AppProtocol
    public let enabledCurrencies: EnabledCurrenciesServiceAPI
    public let topMoversService: TopMoversServiceAPI
    public let watchlistService: PricesWatchlistRepositoryAPI

    public init(
        app: AppProtocol,
        enabledCurrencies: EnabledCurrenciesServiceAPI,
        topMoversService: TopMoversServiceAPI,
        watchlistService: PricesWatchlistRepositoryAPI
    ) {
        self.app = app
        self.enabledCurrencies = enabledCurrencies
        self.topMoversService = topMoversService
        self.watchlistService = watchlistService
    }

    public enum PricesSceneError: Error, Equatable {
        case failed
    }

    public enum Filter: Hashable, Equatable {
        case all, favorites, tradable
    }

    public enum Action: Equatable, BindableAction {
        case onAppear
        case onPricesDataFetched([CryptoCurrency])
        case onFavouritesFetched(Set<String>)
        case binding(BindingAction<State>)
        case topMoversAction(TopMoversSection.Action)
        case onAssetTapped(PricesRowData)
    }

    public struct State: Equatable {

        var unsortedData: [PricesRowData]?
        var data: [PricesRowData]? {
            guard let unsortedData else { return nil }
            return unsortedData.sorted(like: sortOrder, my: \.currency.code)
        }

        @BindingState var sortOrder: [String] = []
        var favourites: Set<String> = ["BTC", "ETH", "USDC"]

        @BindingState var searchFilter: Filter
        @BindingState var searchText: String
        @BindingState var isSearching: Bool

        var searchResults: [PricesRowData]? {
            guard let data else { return nil }
            guard searchText.isNotEmpty else {
                return data.filtered(by: searchFilter, favourites: favourites)
            }
            return data.filtered(by: searchText, filter: searchFilter, favourites: favourites)
        }

        public var topMoversState: TopMoversSection.State?

        public init(
            appMode: AppMode,
            filterOverride: Filter? = nil,
            data: [PricesRowData]? = nil,
            favourites: Set<String> = [],
            searchText: String = "",
            isSearching: Bool = false,
            topMoversState: TopMoversSection.State? = nil
        ) {
            self.searchFilter = filterOverride ?? appMode.defaultFilter
            self.unsortedData = data
            self.searchText = searchText
            self.isSearching = isSearching
            self.topMoversState = topMoversState
        }
    }

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .run { send in
                        await send(.onPricesDataFetched(enabledCurrencies.allEnabledCryptoCurrencies))
                    },
                    .run { send in
                        for try await watchlist in watchlistService.watchlist().values {
                            guard let favourites = watchlist.success, let favourites else { continue }
                            await send(.onFavouritesFetched(favourites))
                        }
                    },
                    .run { send in
                        for await result in app.stream(blockchain.ux.prices.asset.sort.order, as: [String].self) {
                            guard let result = result.value else { continue }
                            await send(.binding(.set(\.$sortOrder, result)))
                        }
                    }
                )

            case .onFavouritesFetched(let favourites):
                state.favourites = favourites
                return .none

            case .onPricesDataFetched(let currencies):
                let data = currencies.map { currency in
                    PricesRowData(currency: currency)
                }
                .sorted(by: { lhs, rhs in
                    (lhs.isTradable ? 0 : 1, lhs.currency.code, lhs.currency.name) < (rhs.isTradable ? 0 : 1, rhs.currency.code, rhs.currency.name)
                })
                state.unsortedData = data
                return .none

            case .onAssetTapped(let asset):
                app.post(
                    action: blockchain.ux.asset[asset.currency.code].select.then.enter.into,
                    value: blockchain.ux.asset[asset.currency.code],
                    context: [blockchain.ux.asset.select.origin: "PRICES"]
                )
                return .none

            case .binding, .topMoversAction:
                return .none
            }
        }
        .ifLet(\.topMoversState, action: /Action.topMoversAction) {
            TopMoversSection(
                app: app,
                topMoversService: topMoversService
            )
        }
    }
}

public struct PricesRowData: Equatable, Identifiable, Hashable {

    public var id: String { currency.code }

    public let currency: CryptoCurrency
    public var isTradable: Bool { currency.supports(product: .custodialWalletBalance) }

    public init(currency: CryptoCurrency) {
        self.currency = currency
    }
}

extension AppMode {
    fileprivate var defaultFilter: PricesScene.Filter {
        switch self {
        case .trading:
            .tradable
        case .pkw:
            .all
        }
    }
}

extension [PricesRowData] {
    func filtered(
        by filter: PricesScene.Filter,
        favourites: Set<String>
    ) -> [PricesRowData] {
        switch filter {
        case .all:
            self
        case .favorites:
            self.filter { price in favourites.contains(price.currency.code) }
        case .tradable:
            self.filter(\.isTradable)
        }
    }

    func filtered(
        by searchText: String,
        using algorithm: StringDistanceAlgorithm = StringContainsAlgorithm(caseInsensitive: true)
    ) -> [PricesRowData] {
        filter {
            $0.currency.matchSearch(searchText)
        }
    }

    func filtered(
        by searchText: String,
        filter: PricesScene.Filter,
        favourites: Set<String>,
        using algorithm: StringDistanceAlgorithm = StringContainsAlgorithm(caseInsensitive: true)
    ) -> [PricesRowData] {
        switch filter {
        case .all:
            filtered(by: searchText)
        case .favorites:
            self.filter {
                favourites.contains($0.currency.code) && $0.currency.matchSearch(searchText)
            }
        case .tradable:
            self.filter {
                $0.isTradable && $0.currency.matchSearch(searchText)
            }
        }
    }
}
