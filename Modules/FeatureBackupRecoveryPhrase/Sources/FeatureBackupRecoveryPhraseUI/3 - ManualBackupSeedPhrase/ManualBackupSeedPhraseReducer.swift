import BlockchainNamespace
import ComposableArchitecture
import UIKit

public enum ManualBackupSeedPhraseModule {}

extension ManualBackupSeedPhraseModule {
    public static var reducer: Reducer<ManualBackupSeedPhraseState, ManualBackupSeedPhraseAction, ManualBackupSeedPhraseEnvironment> {
        .init { state, action, environment in
            switch action {
            case .onAppear:
                return environment
                    .recoveryPhraseVerifyingService
                    .recoveryPhraseComponents()
                    .catchToEffect()
                    .map { result in
                        switch result {
                        case .success(let words):
                            return .onRecoveryPhraseComponentsFetchSuccess(words)
                        case .failure:
                            return .onRecoveryPhraseComponentsFetchedFailed
                        }
                    }

            case .onRecoveryPhraseComponentsFetchSuccess(let words):
                state.availableWords = words
                return .none

            case .onRecoveryPhraseComponentsFetchedFailed:
                return .none

            case .onCopyTap:
                state.recoveryPhraseCopied = true

                return .merge(
                    .fireAndForget { [availableWords = state.availableWords] in
                        UIPasteboard.general.string = availableWords
                                                        .map(\.label)
                                                        .joined(separator: " ")
                    },
                    EffectTask(value: .onCopyReturn)
                        .delay(
                            for: 20,
                            scheduler: environment.mainQueue
                        )
                        .eraseToEffect()
                )
            case .onCopyReturn:
                state.recoveryPhraseCopied = false
                return .fireAndForget {
                    UIPasteboard.general.string = nil
                }

            case .onNextTap:
                environment.onNext()
                return .fireAndForget {
                    UIPasteboard.general.string = nil
                }
            }
        }
    }
}
