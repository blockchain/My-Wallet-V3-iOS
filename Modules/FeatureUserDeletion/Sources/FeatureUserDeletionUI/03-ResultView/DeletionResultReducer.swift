import AnalyticsKit
import ComposableArchitecture
import Foundation

public struct DeletionResultReducer: ReducerProtocol {

    public typealias State = DeletionResultState
    public typealias Action = DeletionResultAction

    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let analyticsRecorder: AnalyticsEventRecorderAPI
    public let logoutAndForgetWallet: () -> Void
    public let dismissFlow: () -> Void

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        dismissFlow: @escaping () -> Void,
        logoutAndForgetWallet: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.analyticsRecorder = analyticsRecorder
        self.dismissFlow = dismissFlow
        self.logoutAndForgetWallet = logoutAndForgetWallet
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .dismissFlow:
                dismissFlow()
                return .none
            case .logoutAndForgetWallet:
                logoutAndForgetWallet()
                return .none
            default:
                return .none
            }
        }
    }
}

#if DEBUG

extension DeletionResultReducer {
    static let preview = DeletionResultReducer(
        mainQueue: .main,
        analyticsRecorder: AnalyticsEventRecorder(analyticsServiceProviders: []),
        dismissFlow: {},
        logoutAndForgetWallet: {}
    )
}

#endif
