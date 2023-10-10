import ComposableArchitecture
import UIKit

public struct ViewIntroBackup: Reducer {

    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let onNext: () -> Void
    public let onSkip: () -> Void

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        onSkip: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.onSkip = onSkip
        self.onNext = onNext
    }

    public typealias State = ViewIntroBackupState
    public typealias Action = ViewIntroBackupAction

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .onRecoveryPhraseStatusFetched(let isBackedUp):
                state.recoveryPhraseBackedUp = isBackedUp
                return .none
            case .onBackupNow:
                onNext()
                return .none
            case .onSkipTap:
                onSkip()
                return .none
            case .binding:
                return .none
            }
        }
    }
}
