import ComposableArchitecture

public struct BackupSkipConfirm: ReducerProtocol {

    public let onConfirm: () -> Void

    public init(
        onConfirm: @escaping () -> Void
    ) {
        self.onConfirm = onConfirm
    }

    public typealias State = BackupSkipConfirmState
    public typealias Action = BackupSkipConfirmAction

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onConfirmTapped:
                onConfirm()
                return .none
            }
        }
    }
}
