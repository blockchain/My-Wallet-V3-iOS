import BlockchainNamespace
import ComposableArchitecture
public enum VerifyRecoveryPhraseModule {}

extension VerifyRecoveryPhraseModule {
    public static var reducer: Reducer<VerifyRecoveryPhraseState, VerifyRecoveryPhraseAction, VerifyRecoveryPhraseEnvironment> {
        .init { state, action, environment in
            switch action {
            case .onAppear:
                return environment
                    .recoveryPhraseService
                    .recoveryPhraseComponents()
                    .receive(on: environment.mainQueue)
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
                var generator = environment.generator
                state.availableWords = words
                state.shuffledAvailableWords = words.shuffled(using: &generator)
                return .none

            case .onRecoveryPhraseComponentsFetchedFailed:
                return .none

            case .onSelectedWordTap(let word):
                state.backupPhraseStatus = .idle
                state.selectedWords = state.selectedWords.filter { $0 != word }
                return .none

            case .onAvailableWordTap(let word):
                if state.selectedWords.contains(word) == false {
                    state.selectedWords.append(word)
                    if state.selectedWords.count == state.availableWords.count {
                        state.backupPhraseStatus = .readyToVerify
                    }
                }
                return .none

            case .onVerifyTap:
                if state.selectedWords.map(\.label) == state.availableWords.map(\.label) {
                    return EffectTask(value: .onPhraseVerifySuccess)
                }
                return EffectTask(value: .onPhraseVerifyFailed)

            case .onPhraseVerifyFailed:
                state.backupPhraseStatus = .failed
                return .none

            case .onPhraseVerifySuccess:
                state.backupPhraseStatus = .loading
                return environment
                    .recoveryPhraseService
                    .markBackupVerified()
                    .map { _ in
                        environment.recoveryPhraseRepository.updateMnemonicBackup()
                    }
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result in
                        switch result {
                        case .success:
                            return .onPhraseVerifyComplete
                        case .failure:
                            return .onPhraseVerifyBackupFailed
                        }
                    }

            case .onPhraseVerifyComplete:
                state.backupPhraseStatus = .success
                return .fireAndForget {
                    environment
                        .onNext()
                }

            case .onPhraseVerifyBackupFailed:
                state.backupPhraseStatus = .readyToVerify
                state.backupRemoteFailed = true
                return .none

            case .onResetWordsTap:
                state.backupPhraseStatus = .idle
                state.selectedWords = []
                return .none

            case .binding:
                return .none
            }
        }
        .binding()
    }
}
