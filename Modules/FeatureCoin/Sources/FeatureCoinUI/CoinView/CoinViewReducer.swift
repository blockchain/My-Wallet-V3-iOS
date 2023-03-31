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

public let coinViewReducer = Reducer<
    CoinViewState,
    CoinViewAction,
    CoinViewEnvironment
>.combine(
    graphViewReducer
        .pullback(
            state: \.graph,
            action: /CoinViewAction.graph,
            environment: { $0 }
        ),
    .init { state, action, environment in
        switch action {

        case .onAppear:
            state.appMode = environment.app.currentMode

            return .merge(
                EffectTask(value: .observation(.start)),

                EffectTask(value: .refresh),

                environment.assetInformationService
                    .fetch()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(CoinViewAction.fetchedAssetInformation),

                environment.app.publisher(
                    for: blockchain.app.configuration.recurring.buy.is.enabled,
                    as: Bool.self
                )
                .compactMap(\.value)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(CoinViewAction.isRecurringBuyEnabled),

                environment.app.publisher(
                    for: blockchain.ux.asset[state.currency.code].watchlist.is.on,
                    as: Bool.self
                )
                .compactMap(\.value)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(CoinViewAction.isOnWatchlist),

                NotificationCenter.default
                    .publisher(for: .transaction)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .map { _ in .refresh },

                environment.app.on(blockchain.ux.asset[state.currency.code].refresh)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .map { _ in .refresh }
            )

        case .onDisappear:
            return EffectTask(value: .observation(.stop))

        case .refresh:
            return environment.kycStatusProvider()
                .setFailureType(to: Error.self)
                .combineLatest(
                    environment.accountsProvider().flatMap(\.snapshot)
                )
                .receive(on: environment.mainQueue.animation(.spring()))
                .catchToEffect()
                .map(CoinViewAction.update)

        case .isRecurringBuyEnabled(let isRecurringBuyEnabled):
            state.isRecurringBuyEnabled = isRecurringBuyEnabled
            state.recurringBuy = nil
            guard isRecurringBuyEnabled else { return .none }
            return environment.recurringBuyProvider()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(CoinViewAction.fetchedRecurringBuys)

        case .fetchedRecurringBuys(let result):
            state.recurringBuys = try? result.get()
            return .none

        case .fetchInterestRate:
            return environment.earnRatesRepository
                .fetchEarnRates(code: state.currency.code)
                .result()
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(CoinViewAction.fetchedInterestRate)

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
            return .fireAndForget { [state] in
                environment.app.post(
                    event: blockchain.ux.asset[state.currency.code].watchlist.add
                )
            }

        case .removeFromWatchlist:
            state.isFavorite = nil
            return .fireAndForget { [state] in
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
                let update = EffectTask<CoinViewAction>.fireAndForget {
                    environment.app.state.transaction { state in
                        for account in accounts {
                            state.set(blockchain.ux.asset.account[account.id].is.trading, to: account.accountType == .trading)
                            state.set(blockchain.ux.asset.account[account.id].is.private_key, to: account.accountType == .privateKey)
                            state.set(blockchain.ux.asset.account[account.id].is.rewards, to: account.accountType == .interest)
                        }
                    }
                }
                if accounts.contains(where: \.accountType.supportRates) {
                    return .merge(update, EffectTask(value: .fetchInterestRate))
                } else {
                    return update
                }
            case .failure:
                state.error = .failedToLoad
                return .none
            }

        case .reset:
            return .fireAndForget {
                environment.explainerService.resetAll()
            }

        case .observation(.event(let ref, context: let cxt)):
            switch ref.tag {
            case blockchain.ux.asset.recurring.buy.summary.cancel.tapped:
                let isRecurringBuyEnabled = state.isRecurringBuyEnabled
                if let recurringBuyId = state.recurringBuy?.id {
                    return environment
                        .cancelRecurringBuyService(recurringBuyId)
                        .receive(on: environment.mainQueue)
                        .catchToEffect()
                        .map { _ in .isRecurringBuyEnabled(isRecurringBuyEnabled) }
                }
                return .none
            case blockchain.ux.asset.recurring.buy.summary:
                if let recurringBuyId = cxt[blockchain.ux.asset.recurring.buy.summary.id] as? String {
                    state.recurringBuy = (state.recurringBuys ?? []).first(where: { $0.id == recurringBuyId })
                    return .none
                }
            case blockchain.ux.asset.account.sheet:
                guard let account = cxt[blockchain.ux.asset.account] as? Account.Snapshot else {
                    return .none
                }
                if environment.explainerService.isAccepted(account) {
                    switch account.accountType {
                    case .interest, .activeRewards, .staking:
                        return .fireAndForget {
                            environment.app.post(
                                event: account.action(with: ref.context),
                                context: cxt
                            )
                        }
                    default:
                        state.account = account
                    }
                } else {
                    return .fireAndForget {
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
                return .fireAndForget {
                    environment.explainerService.accept(account)
                    environment.app.post(
                        event: account.action(with: ref.context),
                        context: cxt
                    )
                }
            case blockchain.ux.asset.recurring.buy.onboarding:
                state.recurringBuyOnboarding = true
                return .none
            case blockchain.ux.asset.recurring.buy.onboarding.article.plain.navigation.bar.button.close.tap:
                state.recurringBuyOnboarding = false
                return .none
            default:
                break
            }
            return .none
        case .dismiss:
            return .merge(
                .fireAndForget(environment.dismiss),
                .fireAndForget { [state] in
                    environment.app.post(
                        event: blockchain.ux.asset[state.currency.code].article.plain.navigation.bar.button.close
                    )
                }
            )
        case .graph, .binding, .observation:
            return .none
        }
    }
)
.on(blockchain.ux.asset.recurring.buy.summary, blockchain.ux.asset.recurring.buy.summary.cancel.tapped)
.on(blockchain.ux.asset.account.sheet)
.on(blockchain.ux.asset.account.explainer, blockchain.ux.asset.account.explainer.accept)
.on(blockchain.ux.asset.recurring.buy.onboarding, blockchain.ux.asset.recurring.buy.onboarding.article.plain.navigation.bar.button.close.tap)
.binding()

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
