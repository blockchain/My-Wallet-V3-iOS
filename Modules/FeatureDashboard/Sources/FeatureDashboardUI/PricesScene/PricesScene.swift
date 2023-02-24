// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import FeatureDashboardDomain
import Foundation
import MoneyKit
import PlatformKit
import SwiftExtensions
import SwiftUI

public struct PricesScene: ReducerProtocol {
    public let pricesSceneService: PricesSceneServiceAPI
    public let app: AppProtocol

    public init(
        pricesSceneService: PricesSceneServiceAPI,
        app: AppProtocol
    ) {
        self.pricesSceneService = pricesSceneService
        self.app = app
    }

    public enum PricesSceneError: Error, Equatable {
        case failed
    }

    public enum Filter: Hashable {
        case all, favorites, tradable
    }

    public enum Action: Equatable, BindableAction {
        case onAppear
        case onPricesDataFetched(Result<[PricesRowData], PricesSceneError>)
        case binding(BindingAction<State>)
        case onAssetTapped(PricesRowData)
    }

    public struct State: Equatable {
        var pricesData: [PricesRowData]?
        let appMode: AppMode
        @BindableState var filter: Filter
        @BindableState var searchText: String
        @BindableState var isSearching: Bool

        var searchResults: [PricesRowData]? {
            guard let pricesData else {
                return nil
            }
            guard searchText.isNotEmpty else {
                return pricesData.filtered(by: filter)
            }
            return pricesData
                .filtered(by: searchText, filter: filter)
        }

        public init(
            appMode: AppMode,
            filterOverride: Filter? = nil,
            pricesData: [PricesRowData]? = nil,
            searchText: String = "",
            isSearching: Bool = false
        ) {
            self.appMode = appMode
            self.filter = filterOverride ?? appMode.defaultFilter
            self.pricesData = pricesData
            self.searchText = searchText
            self.isSearching = isSearching
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return self.pricesSceneService.pricesRowData(appMode: state.appMode)
                    .receive(on: DispatchQueue.main)
                    .replaceError(with: PricesSceneError.failed)
                    .result()
                    .eraseToEffect(Action.onPricesDataFetched)

            case .onPricesDataFetched(.success(let pricesData)):
                state.pricesData = pricesData
                return .none

            case .onPricesDataFetched(.failure):
                return .none

            case .onAssetTapped(let asset):
                return .fireAndForget {
                    app.post(
                        action: blockchain.ux.asset[asset.currency.code].select.then.enter.into,
                        value: blockchain.ux.asset[asset.currency.code],
                        context: [blockchain.ux.asset.select.origin: "PRICES"]
                    )
                }

            case .binding:
                return .none
            }
        }
    }
}

public struct PricesRowData: Equatable, Identifiable, Hashable {
    public var id: String { currency.code }

    public let currency: CryptoCurrency
    public let delta: Decimal?
    public let isFavorite: Bool
    public let isTradable: Bool
    public let networkName: String?
    public let price: MoneyValue?

    public init(
        currency: CryptoCurrency,
        delta: Decimal?,
        isFavorite: Bool,
        isTradable: Bool,
        networkName: String?,
        price: MoneyValue?
    ) {
        self.currency = currency
        self.delta = delta
        self.isFavorite = isFavorite
        self.isTradable = isTradable
        self.networkName = networkName
        self.price = price
    }
}

extension PricesRowData {
    var priceChangeString: String? {
        guard let delta else {
            return nil
        }
        var arrowString: String {
            if delta.isZero {
                return ""
            }
            if delta.isSignMinus {
                return "↓"
            }

            return "↑"
        }

        if #available(iOS 15.0, *) {
            let deltaFormatted = (delta / 100).formatted(.percent.precision(.fractionLength(2)))
            return "\(arrowString) \(deltaFormatted)"
        } else {
            return "\(arrowString) \(delta) %"
        }
    }

    var priceChangeColor: Color? {
        guard let delta else {
            return nil
        }
        if delta.isSignMinus {
            return Color.WalletSemantic.pink
        } else if delta.isZero {
            return Color.WalletSemantic.body
        } else {
            return Color.WalletSemantic.success
        }
    }
}

extension AppMode {
    fileprivate var defaultFilter: PricesScene.Filter {
        switch self {
        case .trading:
            return .tradable
        case .universal, .pkw:
            return .all
        }
    }
}

extension [PricesRowData] {
    func filtered(
        by filter: PricesScene.Filter
    ) -> [PricesRowData] {
        switch filter {
        case .all:
            return self
        case .favorites:
            return self.filter(\.isFavorite)
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
        using algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: true)
    ) -> [PricesRowData] {
        switch filter {
        case .all:
            return filtered(by: searchText)
        case .favorites:
            return self.filter {
                $0.isFavorite && $0.currency.filter(by: searchText, using: algorithm)
            }
        case .tradable:
            return self.filter {
                $0.isTradable && $0.currency.filter(by: searchText, using: algorithm)
            }
        }
    }
}
