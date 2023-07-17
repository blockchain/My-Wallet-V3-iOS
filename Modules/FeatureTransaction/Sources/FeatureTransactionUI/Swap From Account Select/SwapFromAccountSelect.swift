// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import Foundation
import MoneyKit
import PlatformKit
import SwiftExtensions
import ToolKit

public struct SwapFromAccountSelect: ReducerProtocol {
    private var app: AppProtocol
    private var supportedPairsInteractorService: SupportedPairsInteractorServiceAPI

    public struct State: Equatable {
        var isLoading: Bool = false
        var appMode: AppMode?
        var availableAccounts: [String] = []
        var swapAccountRows: IdentifiedArrayOf<SwapFromAccountRow.State> = []
    }

    public enum Action: Equatable {
        case accountRow(
            id: SwapFromAccountRow.State.ID,
            action: SwapFromAccountRow.Action
        )
        case onAppear
        case onAvailableAccountsFetched([String])
        case onCloseTapped
    }

    public init(
        app: AppProtocol,
        supportedPairsInteractorService: SupportedPairsInteractorServiceAPI
    ) {
        self.app = app
        self.supportedPairsInteractorService = supportedPairsInteractorService
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .accountRow:
                return .none

            case .onAppear:
                state.appMode = app.currentMode
                state.isLoading = true
                return .run { [
                    appMode = state.appMode
                ] send in
                    do {
                        let tradableCurrencies = try await supportedPairsInteractorService
                            .fetchSupportedTradingCryptoCurrencies()
                            .await()
                            .map(\.code)

                        if appMode == .pkw {
                            let availableAccounts = try await app.get(blockchain.coin.core.accounts.DeFi.with.balance, as: [String].self)
                            let filteredAccounts: [String] = try await availableAccounts
                                .async
                                .filter { accountId in
                                    let currency = try await app.get(blockchain.coin.core.account[accountId].currency, as: String.self)
                                    return tradableCurrencies.contains(currency)
                                }
                                .reduce(into: []) { accounts, accountId in
                                    accounts.append(accountId)
                                }

                            await send(.onAvailableAccountsFetched(filteredAccounts))
                        } else {
                            let availableAccounts = try await app.get(blockchain.coin.core.accounts.custodial.crypto.with.balance, as: [String].self)
                            let filteredAccounts = try await availableAccounts
                                .async
                                .filter { accountId in
                                    let currency = try await app.get(blockchain.coin.core.account[accountId].currency, as: String.self)
                                    return tradableCurrencies.contains(currency)
                                }
                                .reduce(into: []) { accounts, accountId in
                                    accounts.append(accountId)
                                }

                            await send(.onAvailableAccountsFetched(filteredAccounts))
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }

            case .onAvailableAccountsFetched(let accounts):
                state.isLoading = false
                let elements = accounts
                    .map {
                        SwapFromAccountRow.State(
                            isLastRow: $0 == accounts.last,
                            assetCode: $0
                        )
                    }
                state.swapAccountRows = IdentifiedArrayOf(uniqueElements: elements)
                return .none

            case .onCloseTapped:
                return .none
            }
        }
        .forEach(\.swapAccountRows, action: /Action.accountRow(id:action:)) {
            SwapFromAccountRow(app: app)
        }
    }
}
