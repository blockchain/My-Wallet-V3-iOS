import BlockchainNamespace
import ComposableArchitecture
import Extensions
import FeatureBackupRecoveryPhraseDomain
import WalletPayloadKit

public struct VerifyRecoveryPhrase: ReducerProtocol {

    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let recoveryPhraseRepository: RecoveryPhraseRepositoryAPI
    public let recoveryPhraseService: RecoveryPhraseVerifyingServiceAPI
    public let onNext: () -> Void
    public var generator = NonRandomNumberGenerator(
        [
            16864412655522353077
        ]
    )

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        recoveryPhraseRepository: RecoveryPhraseRepositoryAPI,
        recoveryPhraseService: RecoveryPhraseVerifyingServiceAPI,
        onNext: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.recoveryPhraseService = recoveryPhraseService
        self.recoveryPhraseRepository = recoveryPhraseRepository
        self.onNext = onNext
    }

    public typealias State = VerifyRecoveryPhraseState
    public typealias Action = VerifyRecoveryPhraseAction

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return recoveryPhraseService
                    .recoveryPhraseComponents()
                    .receive(on: mainQueue)
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
                var generator = generator
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
                return recoveryPhraseService
                    .markBackupVerified()
                    .map { _ in
                        recoveryPhraseRepository.updateMnemonicBackup()
                    }
                    .receive(on: mainQueue)
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
                    onNext()
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
    }
}
