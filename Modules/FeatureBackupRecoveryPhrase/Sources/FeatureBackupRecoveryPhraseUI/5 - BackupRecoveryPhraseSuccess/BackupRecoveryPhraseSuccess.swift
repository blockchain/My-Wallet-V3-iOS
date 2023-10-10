import BlockchainNamespace
import ComposableArchitecture

public struct BackupRecoveryPhraseSuccess: Reducer {
    public let onNext: () -> Void

    public init(
        onNext: @escaping () -> Void
    ) {
        self.onNext = onNext
    }

    public typealias State = BackupRecoveryPhraseSuccessState
    public typealias Action = BackupRecoveryPhraseSuccessAction

    public var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .onDoneTapped:
                onNext()
                return .none
            }
        }
    }
}
