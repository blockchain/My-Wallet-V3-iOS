// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import Foundation
import MoneyKit
import PlatformKit
import SwiftExtensions
import ToolKit

public struct SwapAccountSelect: ReducerProtocol {
    private var app: AppProtocol

    public enum SelectionType {
        case source
        case target
    }

    public struct State: Equatable {
        var isLoading: Bool = false
        var selectionType: SelectionType
        var isSearchable: Bool {
            selectionType == .target
        }

        var selectedSourceCrypto: CryptoCurrency?
        var hasAccountSegmentedControl = false
        var tradingPairs: [TradingPair] = []
        var appMode: AppMode?
        @BindingState var availableAccounts: [String] = []
        @BindingState var searchText: String = ""
        @BindingState var isSearching: Bool = false
        @BindingState var controlSelection: Tag = blockchain.ux.asset.account.swap.segment.filter.defi[]

        var filterDefiAccountsOnly: Bool {
            controlSelection == blockchain.ux.asset.account.swap.segment.filter.defi
        }

        var swapAccountRows: IdentifiedArrayOf<SwapAccountRow.State> = []
        var searchResults: IdentifiedArrayOf<SwapAccountRow.State> {
            if searchText.isEmpty {
                return swapAccountRows
            }

            return swapAccountRows.filtered(by: searchText)
        }
    }

    public enum Action: BindableAction {
        case accountRow(
            id: SwapAccountRow.State.ID,
            action: SwapAccountRow.Action
        )
        case onAppear
        case binding(BindingAction<SwapAccountSelect.State>)
        case onAvailableAccountsFetched([String])
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
                state.hasAccountSegmentedControl = state.selectionType == .target && app.currentMode == .pkw
                state.isLoading = true
                return .run { [
                    selectionType = state.selectionType,
                    appMode = state.appMode,
                    sourceCurrency = state.selectedSourceCrypto?.code ?? ""
                ] send in
                    do {
                        if appMode == .pkw {
                            if selectionType == .source {
                                let availableAccounts = try await app.get(blockchain.coin.core.accounts.DeFi.with.balance, as: [String].self)
                                await send(.onAvailableAccountsFetched(availableAccounts))
                            }

                            if selectionType == .target {
                                let pairs = try await app.get(blockchain.api.nabu.gateway.trading.swap.pairs, as: [String].self)
                                let availableAccounts = try await app.get(blockchain.coin.core.accounts.DeFi.all, as: [String].self)
                                await send(.onTradingPairsFetched(pairs.compactMap { TradingPair(rawValue: $0) }))

                                let filteredAccounts = await filter(sourceCurrency: sourceCurrency, accounts: availableAccounts, pairs: (pairs.compactMap { TradingPair(rawValue: $0) }))
                                await send(.onAvailableAccountsFetched(filteredAccounts))
                            }
                        } else {
                            if selectionType == .source {
                                let availableAccounts = try await app.get(blockchain.coin.core.accounts.custodial.crypto.with.balance, as: [String].self)
                                await send(.onAvailableAccountsFetched(availableAccounts))
                            }

                            if selectionType == .target {
                                let pairs = try await app.get(blockchain.api.nabu.gateway.trading.swap.pairs, as: [TradingPair].self)
                                let availableAccounts = try await app.get(blockchain.coin.core.accounts.custodial.crypto.all, as: [String].self)
                                let filteredAccounts = await filter(sourceCurrency: sourceCurrency, accounts: availableAccounts, pairs: pairs)
                                await send(.onAvailableAccountsFetched(filteredAccounts))
                            }
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
                            let availableAccounts = try await app.get(blockchain.coin.core.accounts.custodial.all, as: [String].self)
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
                        SwapAccountRow.State(
                            type: state.selectionType,
                            isLastRow: $0 == accounts.last,
                            assetCode: $0
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
            SwapAccountRow(app: app)
        }
    }

    func filter(
        sourceCurrency: String,
        accounts: [String],
        pairs: [TradingPair]
    ) async -> [String] {
        let filteredAccounts: [String] = await accounts
            .async
            .filter {
                do {
                    let currency: String = try await app.get(blockchain.coin.core.account[$0].currency, as: String.self)
                    guard currency != sourceCurrency else {
                        return false
                    }

                    return pairs.contains { pair in
                        pair.sourceCurrencyType.code == sourceCurrency && pair.destinationCurrencyType.code == currency
                    }
                } catch {
                    return false
                }
            }
            .reduce(into: []) { availableAccounts, account in
                availableAccounts.append(account)
            }
        return filteredAccounts
    }
}

extension IdentifiedArrayOf<SwapAccountRow.State> {
    func filtered(
        by searchText: String,
        using algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: true)
    ) -> IdentifiedArrayOf<SwapAccountRow.State> {
        filter {
            guard let currency = $0.currency, let fiatBalance = $0.balance else {
                return false
            }

            return currency.filter(by: searchText, using: algorithm) ||
            (fiatBalance.displayString.distance(between: searchText, using: algorithm)) < 0.3
        }
    }
}
