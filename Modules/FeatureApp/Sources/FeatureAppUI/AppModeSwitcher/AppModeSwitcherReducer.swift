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
                return .concatenate(
                    .fireAndForget {
                        environment.app.post(value: AppMode.pkw.rawValue, of: blockchain.app.mode)
                    },
                    EffectTask(value: .dismiss)
                )

            case .onTradingTapped:
                return .concatenate(
                    .fireAndForget {
                        environment.app.post(value: AppMode.trading.rawValue, of: blockchain.app.mode)
                    },
                    EffectTask(value: .dismiss)
                )

            case .dismiss:
                return .none

            case .binding:
                return .none
            }
        }
        .binding()
    }
}
