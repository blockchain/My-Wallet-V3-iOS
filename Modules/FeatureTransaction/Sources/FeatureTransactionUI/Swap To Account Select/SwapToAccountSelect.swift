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
        case onAvailableAccountsFetched([CryptoCurrency])
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
                            let availableAccounts = try await app.get(blockchain.coin.core.accounts.DeFi.all, as: [String].self)
                            await send(.onTradingPairsFetched(pairs.compactMap { TradingPair(rawValue: $0) }))

                            let filteredAccounts = await filter(sourceCurrency: sourceCurrency, accounts: availableAccounts, pairs: (pairs.compactMap { TradingPair(rawValue: $0) }))
                            await send(.onAvailableAccountsFetched(filteredAccounts))
                        } else {
                            let pairs = try await app.get(blockchain.api.nabu.gateway.trading.swap.pairs, as: [TradingPair].self)
                            let availableAccounts = try await app.get(blockchain.coin.core.accounts.custodial.crypto.all, as: [String].self)
                            let filteredAccounts = await filter(sourceCurrency: sourceCurrency, accounts: availableAccounts, pairs: pairs)
                            await send(.onAvailableAccountsFetched(filteredAccounts))
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
                    do {
                        if filterDefiAccountsOnly {
                            let availableAccounts = try await app.get(blockchain.coin.core.accounts.DeFi.all, as: [String].self)
                            let filteredAccounts = await filter(
                                sourceCurrency: sourceCurrency,
                                accounts: availableAccounts,
                                pairs: tradingPairs
                            )
                            await send(.onAvailableAccountsFetched(filteredAccounts))
                        } else {
                            let availableAccounts = try await app.get(blockchain.coin.core.accounts.custodial.crypto.all, as: [String].self)
                            let filteredAccounts = await filter(
                                sourceCurrency: sourceCurrency,
                                accounts: availableAccounts,
                                pairs: tradingPairs
                            )
                            await send(.onAvailableAccountsFetched(filteredAccounts))
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }

            case .onTradingPairsFetched(let pairs):
                state.tradingPairs = pairs
                return .none

            case .onAvailableAccountsFetched(let accounts):
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
        accounts: [String],
        pairs: [TradingPair]
    ) async -> [CryptoCurrency] {
        let filteredAccounts: [CryptoCurrency] = await accounts
            .async
            .compactMap {
                do {
                    let currency = try await app.get(blockchain.coin.core.account[$0].currency, as: CryptoCurrency.self)
                    guard currency.code != sourceCurrency else {
                        return nil
                    }

                    if(pairs.contains { pair in
                        pair.sourceCurrencyType.code == sourceCurrency && pair.destinationCurrencyType.code == currency.code
                    }) {
                        return currency
                    }

                    return nil
                } catch {
                    return nil
                }
            }
            .reduce(into: []) { availableAccounts, account in
                availableAccounts.append(account)
            }
            .uniqued(on: { $0.code })
        return filteredAccounts
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
