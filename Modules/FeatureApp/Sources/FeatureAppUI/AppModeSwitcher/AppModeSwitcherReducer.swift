import AnalyticsKit
import BlockchainNamespace
import ComposableArchitecture
import ToolKit

public enum AppModeSwitcherModule {}

extension AppModeSwitcherModule {
    public static var reducer: Reducer<AppModeSwitcherState, AppModeSwitcherAction, AppModeSwitcherEnvironment> {
        .init { state, action, environment in
            switch action {
            case .onInit:
                return .merge(
                    environment
                        .recoveryPhraseStatusProviding
                        .isRecoveryPhraseVerified
                        .combineLatest(environment.app.publisher(for: blockchain.user.skipped.seed_phrase.backup, as: Bool.self)
                            .replaceError(with: false)
                        )
                        .receive(on: DispatchQueue.main)
                        .eraseToEffect()
                        .map(AppModeSwitcherAction.onRecoveryPhraseStatusFetched),

                    environment
                        .app
                        .publisher(for: blockchain.app.mode.has.been.force.defaulted.to.mode, as: AppMode.self)
                        .map(\.value)
                        .map { $0 == AppMode.pkw }
                        .replaceNil(with: false)
                        .receive(on: DispatchQueue.main)
                        .eraseToEffect()
                        .map { AppModeSwitcherAction.binding(.set(\.$userHasBeenDefaultedToPKW, $0)) }
                )

            case .onRecoveryPhraseStatusFetched(let isBackedUp, let isSkipped):
                state.recoveryPhraseBackedUp = isBackedUp
                state.recoveryPhraseSkipped = isSkipped
                return .none

            case .onDefiTapped:
                if let defiAccountBalance = state.defiAccountBalance,
                   defiAccountBalance.isZero, state.shouldShowDefiModeIntro
                {
                    return EffectTask(value: .binding(.set(\.$isDefiIntroPresented, true)))
                } else if state.shouldShowRecoveryFlow {
                    return EffectTask(value: .defiWalletIntro(.onEnableDefiTap))
                } else {
                    return .concatenate(
                        .fireAndForget {
                            environment.app.post(value: AppMode.pkw.rawValue, of: blockchain.app.mode)
                        },
                        EffectTask(value: .dismiss)
                    )
                }

            case .onTradingTapped:
                return .concatenate(
                    .fireAndForget {
                        environment.app.post(value: AppMode.trading.rawValue, of: blockchain.app.mode)
                    },
                    EffectTask(value: .dismiss)
                )

            case .defiWalletIntro(let action):
                switch action {
                case .onBackupSeedPhraseSkip:
                    state.recoveryPhraseSkipped = true
                    return .concatenate(
                        .fireAndForget {
                            environment.app.state.set(blockchain.user.skipped.seed_phrase.backup, to: true)
                        },
                        EffectTask(value: .binding(.set(\.$isDefiIntroPresented, false))),
                        EffectTask(value: .onDefiTapped)
                    )

                case .onBackupSeedPhraseComplete:
                    state.recoveryPhraseBackedUp = true
                    state.isDefiIntroPresented = false
                    return .concatenate(
                        EffectTask(value: .binding(.set(\.$isDefiIntroPresented, false))),
                        EffectTask(value: .onDefiTapped)
                    )

                case .onEnableDefiTap:
                    return .merge(
                        .fireAndForget {
                            environment
                                .backupFundsRouter
                                .presentFlow()
                        },
                        environment
                            .backupFundsRouter
                            .skipSubject
                            .eraseToEffect()
                            .map { _ in
                                AppModeSwitcherAction.defiWalletIntro(DefiWalletIntro.Action.onBackupSeedPhraseSkip)
                            },
                        environment
                            .backupFundsRouter
                            .completionSubject
                            .eraseToEffect()
                            .map { _ in
                                AppModeSwitcherAction.defiWalletIntro(DefiWalletIntro.Action.onBackupSeedPhraseComplete)
                            }
                    )

                case .onCloseTapped:
                    return EffectTask(value: .binding(.set(\.$isDefiIntroPresented, false)))
                case .onAppear:
                    return .none
                }

            case .dismiss:
                return .none

            case .binding:
                return .none
            }
        }
        .binding()
    }
}
