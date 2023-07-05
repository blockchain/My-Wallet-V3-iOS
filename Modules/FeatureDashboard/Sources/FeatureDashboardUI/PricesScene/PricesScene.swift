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

public struct PricesScene: ReducerProtocol {

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

    public enum Filter: Hashable {
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

        @BindingState var filter: Filter
        @BindingState var searchText: String
        @BindingState var isSearching: Bool

        var searchResults: [PricesRowData]? {
            guard let data else { return nil }
            guard searchText.isNotEmpty else {
                return data.filtered(by: filter, favourites: favourites)
            }
            return data.filtered(by: searchText, filter: filter, favourites: favourites)
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
            self.filter = filterOverride ?? appMode.defaultFilter
            self.unsortedData = data
            self.searchText = searchText
            self.isSearching = isSearching
            self.topMoversState = topMoversState
        }
    }

    public var body: some ReducerProtocol<State, Action> {
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
                return .fireAndForget {
                    app.post(
                        action: blockchain.ux.asset[asset.currency.code].select.then.enter.into,
                        value: blockchain.ux.asset[asset.currency.code],
                        context: [blockchain.ux.asset.select.origin: "PRICES"]
                    )
                }

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
            return .tradable
        case .pkw:
            return .all
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
            return self
        case .favorites:
            return self.filter { price in favourites.contains(price.currency.code) }
        case .tradable:
            return self.filter(\.isTradable)
        }
    }

    func filtered(
        by searchText: String,
        using algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: true)
    ) -> [PricesRowData] {
        filter {
            $0.currency.filter(by: searchText, using: algorithm)
        }
    }

    func filtered(
        by searchText: String,
        filter: PricesScene.Filter,
        favourites: Set<String>,
        using algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: true)
    ) -> [PricesRowData] {
        switch filter {
        case .all:
            return filtered(by: searchText)
        case .favorites:
            return self.filter {
                favourites.contains($0.currency.code) && $0.currency.filter(by: searchText, using: algorithm)
            }
        case .tradable:
            return self.filter {
                $0.isTradable && $0.currency.filter(by: searchText, using: algorithm)
            }
        }
    }
}
