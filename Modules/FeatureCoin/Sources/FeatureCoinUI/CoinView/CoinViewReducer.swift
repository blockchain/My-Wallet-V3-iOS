// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import FeatureCoinDomain
import Localization
import SwiftUI
import ToolKit

public struct CoinViewReducer: Reducer {

    public typealias State = CoinViewState
    public typealias Action = CoinViewAction

    let environment: CoinViewEnvironment

    public init(environment: CoinViewEnvironment) {
        self.environment = environment
    }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Scope(state: \.graph, action: /Action.graph) {
            GraphViewReducer(historicalPriceService: environment.historicalPriceService)
        }
        BlockchainNamespaceReducer(
            app: environment.app,
            events: [
                blockchain.ux.asset.recurring.buy.summary.cancel.was.successful,
                blockchain.ux.asset.account.sheet,
                blockchain.ux.asset.account.explainer,
                blockchain.ux.asset.account.explainer.accept
            ]
        )
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appMode = environment.app.currentMode

                return .merge(
                    Effect.send(.observation(.start)),

                    Effect.send(.setRefresh),

                    Effect.publisher {
                        environment.assetInformationService
                            .fetch()
                            .map { info in
                                CoinViewAction.fetchedAssetInformation(.success(info))
                            }
                            .receive(on: environment.mainQueue)
                    },

                    Effect.publisher {
                        environment.app.publisher(
                            for: blockchain.app.configuration.recurring.buy.is.enabled,
                            as: Bool.self
                        )
                        .compactMap(\.value)
                        .receive(on: environment.mainQueue)
                        .map(CoinViewAction.isRecurringBuyEnabled)
                    },

                    Effect.publisher {
                        environment.app.publisher(
                            for: blockchain.api.nabu.gateway.products["DEX"].is.eligible,
                            as: Bool.self
                        )
                        .compactMap(\.value)
                        .receive(on: environment.mainQueue)
                        .map {
                            .binding(.set(\.$isDexEnabled, $0))
                        }
                    },

                    Effect.publisher {
                        environment.app.publisher(
                            for: blockchain.app.is.external.brokerage,
                            as: Bool.self
                        )
                        .compactMap(\.value)
                        .receive(on: environment.mainQueue)
                        .map {
                            .binding(.set(\.$isExternalBrokerageEnabled, $0))
                        }
                    },

                    Effect.publisher { [code = state.currency.code] in
                        environment.app.publisher(
                            for: blockchain.ux.asset[code].watchlist.is.on,
                            as: Bool.self
                        )
                        .compactMap(\.value)
                        .receive(on: environment.mainQueue)
                        .map(CoinViewAction.isOnWatchlist)
                    }
                )

            case .setRefresh:
                return .merge(
                    Effect.send(.refresh),

                    Effect.publisher {
                        NotificationCenter.default
                            .publisher(for: .transaction)
                            .receive(on: environment.mainQueue)
                            .map { _ in .refresh }
                    },

                    Effect.publisher { [code = state.currency.code] in
                        environment.app.on(blockchain.ux.asset[code].refresh)
                            .receive(on: environment.mainQueue)
                            .map { _ in .refresh }
                    }
                )

            case .onDisappear:
                return Effect.send(.observation(.stop))

            case .refresh:
                return .publisher {
                    environment
                        .kycStatusProvider()
                        .setFailureType(to: Error.self)
                        .combineLatest(
                            environment.accountsProvider().flatMap(\.snapshot)
                        )
                        .receive(on: environment.mainQueue.animation(.spring()))
                        .map {
                            CoinViewAction.update(.success($0))
                        }
                        .catch {
                            CoinViewAction.update(.failure($0))
                        }
                }

            case .isRecurringBuyEnabled(let isRecurringBuyEnabled):
                state.isRecurringBuyEnabled = isRecurringBuyEnabled
                guard isRecurringBuyEnabled else { return .none }
                return .publisher {
                    environment.recurringBuyProvider()
                        .receive(on: environment.mainQueue)
                        .map { CoinViewAction.fetchedRecurringBuys(.success($0)) }
                        .catch { CoinViewAction.fetchedRecurringBuys(.failure($0)) }
                }

            case .fetchedRecurringBuys(let result):
                state.recurringBuys = try? result.get()
                return .none

            case .fetchInterestRate:
                return .publisher { [code = state.currency.code] in
                    environment.earnRatesRepository
                        .fetchEarnRates(code: code)
                        .result()
                        .receive(on: environment.mainQueue)
                        .map(CoinViewAction.fetchedInterestRate)
                }

            case .fetchedInterestRate(let result):
                state.earnRates = try? result.get()
                return .none

            case .fetchedAssetInformation(let result):
                state.assetInformation = try? result.get()
                return .none

            case .isOnWatchlist(let isFavorite):
                state.isFavorite = isFavorite
                return .none

            case .addToWatchlist:
                state.isFavorite = nil
                environment.app.post(
                    event: blockchain.ux.asset[state.currency.code].watchlist.add
                )
                return .none

            case .removeFromWatchlist:
                state.isFavorite = nil
                environment.app.post(
                    event: blockchain.ux.asset[state.currency.code].watchlist.remove
                )
                return .none

            case .update(let update):
                switch update {
                case .success(let result):
                    let (kycStatus, accounts) = result
                    state.kycStatus = kycStatus
                    state.accounts = accounts
                    if let account = state.account {
                        state.account = state.accounts.first(where: { snapshot in snapshot.id == account.id })
                    }
                    environment.app.state.transaction { state in
                        for account in accounts {
                            state.set(blockchain.ux.asset.account[account.id].is.trading, to: account.accountType == .trading)
                            state.set(blockchain.ux.asset.account[account.id].is.private_key, to: account.accountType == .privateKey)
                            state.set(blockchain.ux.asset.account[account.id].is.rewards, to: account.accountType == .interest)
                        }
                    }
                    if accounts.contains(where: \.accountType.supportRates) {
                        return Effect.send(.fetchInterestRate)
                    } else {
                        return .none
                    }
                case .failure:
                    state.error = .failedToLoad
                    return .none
                }

            case .reset:
                environment.explainerService.resetAll()
                return .none

            case .observation(.event(let ref, context: let cxt)):
                switch ref.tag {
                case blockchain.ux.asset.recurring.buy.summary.cancel.was.successful:
                    let isRecurringBuyEnabled = state.isRecurringBuyEnabled
                    return Effect.send(.isRecurringBuyEnabled(isRecurringBuyEnabled))
                case blockchain.ux.asset.account.sheet:
                    guard let account = cxt[blockchain.ux.asset.account] as? Account.Snapshot else {
                        return .none
                    }
                    if environment.explainerService.isAccepted(account) {
                        switch account.accountType {
                        case .interest, .activeRewards, .staking:
                            environment.app.post(
                                event: account.action(with: ref.context),
                                context: cxt
                            )
                            return .none
                        case .exchange, .privateKey, .trading:
                            state.account = account
                            return .none
                        }
                    } else {
                        environment.app.post(
                            event: blockchain.ux.asset.account.explainer[].ref(to: ref.context),
                            context: cxt
                        )
                        return .none
                    }
                case blockchain.ux.asset.account.explainer:
                    guard let account = cxt[blockchain.ux.asset.account] as? Account.Snapshot else {
                        return .none
                    }
                    state.explainer = account
                    return .none
                case blockchain.ux.asset.account.explainer.accept:
                    guard let account = cxt[blockchain.ux.asset.account] as? Account.Snapshot else {
                        return .none
                    }
                    state.explainer = nil
                    environment.explainerService.accept(account)
                    environment.app.post(
                        event: account.action(with: ref.context),
                        context: cxt
                    )
                    return .none
                default:
                    return .none
                }
            case .dismiss:
                environment.dismiss()
                environment.app.post(
                    event: blockchain.ux.asset[state.currency.code].article.plain.navigation.bar.button.close
                )
                return .none
            case .graph, .binding, .observation:
                return .none

            case .isMigrated(let info):
                state.migrationInfo = info
                return .none
            }
        }
    }
}

extension Account.Snapshot {

    func action(with context: Tag.Context) -> Tag.Event {
        switch accountType {
        case .staking:
            blockchain.ux.asset.account.staking.summary[].ref(to: context)
        case .activeRewards:
            blockchain.ux.asset.account.active.rewards.summary[].ref(to: context)
        case .interest:
            blockchain.ux.asset.account.rewards.summary[].ref(to: context)
        default:
            blockchain.ux.asset.account.sheet[].ref(to: context)
        }
    }
}
