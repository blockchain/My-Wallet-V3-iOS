import ComposableArchitecture

public struct BackupSkipConfirm: Reducer {

    public let onConfirm: () -> Void

    public init(
        onConfirm: @escaping () -> Void
    ) {
        self.onConfirm = onConfirm
    }

    public typealias State = BackupSkipConfirmState
    public typealias Action = BackupSkipConfirmAction

    public var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .onConfirmTapped:
                onConfirm()
                return .none
            }
        }
    }
}
