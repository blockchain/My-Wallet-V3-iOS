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

                        .run { send in
                            do {
                                let assetInfo = try await environment.assetInformationService
                                    .fetch()
                                    .receive(on: environment.mainQueue)
                                    .await()
                                await send(.fetchedAssetInformation(.success(assetInfo)))
                            } catch {
                                await send(.fetchedAssetInformation(.failure(error as! Never)))
                            }
                        },

                        .run { send in
                            do {
                                let isEnabled = try await environment.app.publisher(
                                    for: blockchain.app.configuration.recurring.buy.is.enabled,
                                    as: Bool.self
                                )
                                    .compactMap(\.value)
                                    .receive(on: environment.mainQueue)
                                    .await()
                                await send(.isRecurringBuyEnabled(isEnabled))
                            } catch {
                                await send(.isRecurringBuyEnabled(false))
                            }
                        },

                        .run { send in
                            do {
                                let isDexEnabled = try await environment.app.publisher(
                                    for: blockchain.api.nabu.gateway.products["DEX"].is.eligible,
                                    as: Bool.self
                                )
                                    .compactMap(\.value)
                                    .receive(on: environment.mainQueue)
                                    .await()

                                await send(.binding(.set(\.$isDexEnabled, isDexEnabled)))
                            } catch {
                                await send(.binding(.set(\.$isDexEnabled, false)))
                            }
                        },

                        .run { send in
                            do {
                                let isExternalBrokerageEnabled = try await environment.app.publisher(
                                    for: blockchain.app.is.external.brokerage,
                                    as: Bool.self
                                )
                                    .compactMap(\.value)
                                    .receive(on: environment.mainQueue)
                                    .await()

                                await send(.binding(.set(\.$isExternalBrokerageEnabled, isExternalBrokerageEnabled)))
                            } catch {
                                await send(.binding(.set(\.$isExternalBrokerageEnabled, false)))
                            }
                        },

                        .run { [currency = state.currency] send in
                            do {
                                let isOnWatchlist = try await environment.app.publisher(
                                    for: blockchain.ux.asset[currency.code].watchlist.is.on,
                                    as: Bool.self
                                )
                                    .compactMap(\.value)
                                    .receive(on: environment.mainQueue)
                                    .await()

                                await send(.isOnWatchlist(isOnWatchlist))
                            } catch {
                                await send(.isOnWatchlist(false))
                            }
                        },
                    .run { [currency = state.currency] send in
                        if let migrationInfo = try? await environment.app.get(blockchain.app.configuration.coinview.migration.tickers, as: [CoinMigrationInfo].self)
                            .filter({ $0.old.code == currency.code })
                            .first
                        {
                            await send(.isMigrated(migrationInfo))
                        }
                    }
                )

            case .setRefresh:
                return .merge(
                    Effect.send(.refresh),

                        .publisher {
                            NotificationCenter.default
                                .publisher(for: .transaction)
                                .receive(on: environment.mainQueue)
                                .map { _ in .refresh }
                        },

                        .publisher { [currency = state.currency] in
                            environment.app.on(blockchain.ux.asset[currency.code].refresh)
                                .receive(on: environment.mainQueue)
                                .map { _ in .refresh }
                        }
                )

            case .onDisappear:
                return Effect.send(.observation(.stop))

            case .refresh:
                return .run { send in
                    do {
                        let result = try await environment.kycStatusProvider()
                            .setFailureType(to: Error.self)
                            .combineLatest(
                                environment.accountsProvider().flatMap(\.snapshot)
                            )
                            .receive(on: environment.mainQueue.animation(.spring()))
                            .await()
                        await send(.update(.success(result)))
                    } catch {
                        await send(.update(.failure(error)))
                    }
                }

            case .isRecurringBuyEnabled(let isRecurringBuyEnabled):
                state.isRecurringBuyEnabled = isRecurringBuyEnabled
                guard isRecurringBuyEnabled else { return .none }
                return .run { send in
                    do {
                        let recurringBuys = try await environment
                            .recurringBuyProvider()
                            .receive(on: environment.mainQueue)
                            .await()
                        await send(.fetchedRecurringBuys(.success(recurringBuys)))
                    } catch {
                        await send(.fetchedRecurringBuys(.failure(error)))
                    }
                }

            case .fetchedRecurringBuys(let result):
                state.recurringBuys = try? result.get()
                return .none

            case .fetchInterestRate:
                return .publisher { [currency = state.currency] in
                    environment.earnRatesRepository
                        .fetchEarnRates(code: currency.code)
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
                return .run { [state] _ in
                    environment.app.post(
                        event: blockchain.ux.asset[state.currency.code].watchlist.add
                    )
                }

            case .removeFromWatchlist:
                state.isFavorite = nil
                return .run { [state] _ in
                    environment.app.post(
                        event: blockchain.ux.asset[state.currency.code].watchlist.remove
                    )
                }

            case .update(let update):
                switch update {
                case .success(let result):
                    let (kycStatus, accounts) = result
                    state.kycStatus = kycStatus
                    state.accounts = accounts
                    if let account = state.account {
                        state.account = state.accounts.first(where: { snapshot in snapshot.id == account.id })
                    }
                    let update = Effect<CoinViewAction>.run { _ in
                        environment.app.state.transaction { state in
                            for account in accounts {
                                state.set(blockchain.ux.asset.account[account.id].is.trading, to: account.accountType == .trading)
                                state.set(blockchain.ux.asset.account[account.id].is.private_key, to: account.accountType == .privateKey)
                                state.set(blockchain.ux.asset.account[account.id].is.rewards, to: account.accountType == .interest)
                            }
                        }
                    }
                    if accounts.contains(where: \.accountType.supportRates) {
                        return .merge(update, Effect.send(.fetchInterestRate))
                    } else {
                        return update
                    }
                case .failure:
                    state.error = .failedToLoad
                    return .none
                }

            case .reset:
                return .run { _ in
                    environment.explainerService.resetAll()
                }

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
                            return .run { _ in
                                environment.app.post(
                                    event: account.action(with: ref.context),
                                    context: cxt
                                )
                            }
                        case .exchange, .privateKey, .trading:
                            state.account = account
                            return .none
                        }
                    } else {
                        return .run { _ in
                            environment.app.post(
                                event: blockchain.ux.asset.account.explainer[].ref(to: ref.context),
                                context: cxt
                            )
                        }
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
                    return .run { _ in
                        environment.explainerService.accept(account)
                        environment.app.post(
                            event: account.action(with: ref.context),
                            context: cxt
                        )
                    }
                default:
                    return .none
                }
            case .dismiss:
                return .merge(
                    .run { _ in environment.dismiss() },
                    .run { [state] _ in
                        environment.app.post(
                            event: blockchain.ux.asset[state.currency.code].article.plain.navigation.bar.button.close
                        )
                    }
                )
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
            return blockchain.ux.asset.account.staking.summary[].ref(to: context)
        case .activeRewards:
            return blockchain.ux.asset.account.active.rewards.summary[].ref(to: context)
        case .interest:
            return blockchain.ux.asset.account.rewards.summary[].ref(to: context)
        default:
            return blockchain.ux.asset.account.sheet[].ref(to: context)
        }
    }
}
