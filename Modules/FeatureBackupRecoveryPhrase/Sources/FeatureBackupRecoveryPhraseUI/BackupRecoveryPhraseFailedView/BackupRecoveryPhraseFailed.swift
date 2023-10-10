import ComposableArchitecture

public struct BackupRecoveryPhraseFailed: Reducer {

    public let onConfirm: () -> Void

    public init(
        onConfirm: @escaping () -> Void
    ) {
        self.onConfirm = onConfirm
    }

    public typealias State = BackupRecoveryPhraseFailedState
    public typealias Action = BackupRecoveryPhraseFailedAction

    public var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .onOkTapped:
                onConfirm()
                return .none
            case .onReportABugTapped:
                return .none
            }
        }
    }
}
