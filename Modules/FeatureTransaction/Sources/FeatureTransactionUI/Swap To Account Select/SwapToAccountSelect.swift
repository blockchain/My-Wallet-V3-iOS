// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import Foundation
import MoneyKit
import PlatformKit
import SwiftExtensions
import ToolKit

public struct SwapToAccountSelect: ReducerProtocol {
    private var app: AppProtocol

    public struct State: Equatable {
        var isLoading: Bool = false
        var selectedSourceCrypto: CryptoCurrency?
        var hasAccountSegmentedControl = false
        var tradingPairs: [TradingPair] = []
        var appMode: AppMode?
        @BindingState var availableAccounts: [String] = []
        @BindingState var searchText: String = ""
        @BindingState var isSearching: Bool = false
        @BindingState var controlSelection: Tag = blockchain.ux.asset.account.swap.segment.filter.defi[]

        var filterDefiAccountsOnly: Bool {
            guard hasAccountSegmentedControl == true else {
                return false
            }
            return controlSelection == blockchain.ux.asset.account.swap.segment.filter.defi
        }

        var swapAccountRows: IdentifiedArrayOf<SwapToAccountRow.State> = []
        var searchResults: IdentifiedArrayOf<SwapToAccountRow.State> {
            if searchText.isEmpty {
                return swapAccountRows
            }

            return swapAccountRows.filtered(by: searchText)
        }
    }

    public enum Action: BindableAction, Equatable {
        case accountRow(
            id: SwapToAccountRow.State.ID,
            action: SwapToAccountRow.Action
        )
        case onAppear
        case binding(BindingAction<SwapToAccountSelect.State>)
        case onAvailableCurrenciesFetched([CryptoCurrency])
        case onTradingPairsFetched([TradingPair])
        case onCloseTapped
    }

    public init(app: AppProtocol) {
        self.app = app
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .accountRow:
                return .none

            case .onAppear:
                state.appMode = app.currentMode
                state.hasAccountSegmentedControl = app.currentMode == .pkw
                state.isLoading = true
                return .run { [
                    appMode = state.appMode,
                    sourceCurrency = state.selectedSourceCrypto?.code ?? ""
                ] send in
                    do {
                        if appMode == .pkw {
                            let pairs = try await app.get(blockchain.api.nabu.gateway.trading.swap.pairs, as: [String].self)

                            let nonCustodialCurrencies = try await app.get(blockchain.coin.core.accounts.DeFi.all.currencies,
                                                                           as: [CryptoCurrency].self)
                                .sorted(like: [.ethereum, .bitcoinCash])
                            await send(.onTradingPairsFetched(pairs.compactMap { TradingPair(rawValue: $0) }))
                            let filteredCurrencies = await filter(sourceCurrency: sourceCurrency,
                                                                  availableCurrencies: nonCustodialCurrencies,
                                                                  pairs: (pairs.compactMap { TradingPair(rawValue: $0) }))
                            await send(.onAvailableCurrenciesFetched(filteredCurrencies))
                        } else {
                            let pairs = try await app.get(blockchain.api.nabu.gateway.trading.swap.pairs, as: [TradingPair].self)

                            let custodialCurrencies = try await app.get(blockchain.coin.core.accounts.custodial.crypto.all.currencies,
                                                                        as: [CryptoCurrency].self)
                                .sorted(like: [.ethereum, .bitcoinCash])

                            let filteredCurrencies = await filter(sourceCurrency: sourceCurrency,
                                                                  availableCurrencies: custodialCurrencies,
                                                                  pairs: pairs)
                            await send(.onAvailableCurrenciesFetched(filteredCurrencies))
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }

            case .binding(\.$controlSelection):
                state.isLoading = true
                return .run { [
                    filterDefiAccountsOnly = state.filterDefiAccountsOnly,
                    tradingPairs = state.tradingPairs,
                    sourceCurrency = state.selectedSourceCrypto?.code ?? ""
                ] send in
                    if filterDefiAccountsOnly {
                        let nonCustodialCurrencies = try await app.get(blockchain.coin.core.accounts.DeFi.all.currencies,
                                                                       as: [CryptoCurrency].self)
                            .sorted(like: [.ethereum, .bitcoinCash])

                        let filteredCurrencies = await filter(
                            sourceCurrency: sourceCurrency,
                            availableCurrencies: nonCustodialCurrencies,
                            pairs: tradingPairs
                        )
                        await send(.onAvailableCurrenciesFetched(filteredCurrencies))
                    } else {
                        let custodialCurrencies = try await app.get(blockchain.coin.core.accounts.custodial.crypto.all.currencies,
                                                                    as: [CryptoCurrency].self)
                            .sorted(like: [.ethereum, .bitcoinCash])

                        let filteredCurrencies = await filter(
                            sourceCurrency: sourceCurrency,
                            availableCurrencies: custodialCurrencies,
                            pairs: tradingPairs
                        )
                        await send(.onAvailableCurrenciesFetched(filteredCurrencies))
                    }

                }

            case .onTradingPairsFetched(let pairs):
                state.tradingPairs = pairs
                return .none

            case .onAvailableCurrenciesFetched(let accounts):
                state.isLoading = false
                let elements = accounts
                    .map {
                        SwapToAccountRow.State(
                            isLastRow: $0 == accounts.last,
                            currency: $0,
                            isCustodial: state.filterDefiAccountsOnly == false
                        )
                    }
                state.swapAccountRows = IdentifiedArrayOf(uniqueElements: elements)
                return .none

            case .binding:
                return .none

            case .onCloseTapped:
                return .none
            }
        }
        .forEach(\.swapAccountRows, action: /Action.accountRow(id:action:)) {
            SwapToAccountRow(app: app)
        }
    }

    func filter(
        sourceCurrency: String,
        availableCurrencies: [CryptoCurrency],
        pairs: [TradingPair]
    ) async -> [CryptoCurrency] {
        let filteredCryptoCurrencies: [CryptoCurrency] = await availableCurrencies
            .async
            .compactMap { currency in
                guard currency.code != sourceCurrency else {
                    return nil
                }

                if(pairs.contains { pair in
                    pair.sourceCurrencyType.code == sourceCurrency && pair.destinationCurrencyType.code == currency.code
                }) {
                    return currency
                }

                return nil

            }
            .reduce(into: []) { availableCryptoCurrencies, account in
                availableCryptoCurrencies.append(account)
            }
            .uniqued(on: { $0.code })
        return filteredCryptoCurrencies
    }
}

extension IdentifiedArrayOf<SwapToAccountRow.State> {
    func filtered(
        by searchText: String,
        using algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: true)
    ) -> IdentifiedArrayOf<SwapToAccountRow.State> {
        filter {
            guard let price = $0.price else {
                return false
            }

            return $0.currency.filter(by: searchText, using: algorithm) ||
            (price.displayString.distance(between: searchText, using: algorithm)) < 0.3
        }
    }
}
