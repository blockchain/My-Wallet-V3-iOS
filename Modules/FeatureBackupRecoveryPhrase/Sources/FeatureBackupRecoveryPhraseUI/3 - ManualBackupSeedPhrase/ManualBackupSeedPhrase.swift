import BlockchainNamespace
import ComposableArchitecture
import FeatureBackupRecoveryPhraseDomain
import UIKit

public struct ManualBackupSeedPhrase: Reducer {

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

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    do {
                        let words = try await recoveryPhraseVerifyingService
                            .recoveryPhraseComponents()
                            .await()
                        await send(.onRecoveryPhraseComponentsFetchSuccess(words))
                    } catch {
                        await send(.onRecoveryPhraseComponentsFetchedFailed)
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
                    .run { [availableWords = state.availableWords] _ in
                        UIPasteboard.general.string = availableWords.recoveryPhrase
                    },
                    .run { send in
                        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 20)
                        await send(.onCopyReturn)
                    }
                )
            case .onCopyReturn:
                state.recoveryPhraseCopied = false
                UIPasteboard.general.clear()
                return .none

            case .onNextTap:
                onNext()
                UIPasteboard.general.clear()
                return .none
            }
        }
    }
}
