import BlockchainNamespace
import ComposableArchitecture
import FeatureBackupRecoveryPhraseDomain
import UIKit

public struct ManualBackupSeedPhrase: ReducerProtocol {

    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let onNext: () -> Void
    public let recoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        onNext: @escaping () -> Void,
        recoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI
    ) {
        self.mainQueue = mainQueue
        self.onNext = onNext
        self.recoveryPhraseVerifyingService = recoveryPhraseVerifyingService
    }

    public typealias State = ManualBackupSeedPhraseState
    public typealias Action = ManualBackupSeedPhraseAction

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return recoveryPhraseVerifyingService
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
                        UIPasteboard.general.string = availableWords.recoveryPhrase
                    },
                    EffectTask(value: .onCopyReturn)
                        .delay(
                            for: 20,
                            scheduler: mainQueue
                        )
                        .eraseToEffect()
                )
            case .onCopyReturn:
                state.recoveryPhraseCopied = false
                return .fireAndForget {
                    UIPasteboard.general.clear()
                }

            case .onNextTap:
                onNext()
                return .fireAndForget {
                    UIPasteboard.general.clear()
                }
            }
        }
    }
}
