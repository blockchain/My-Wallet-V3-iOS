import AnalyticsKit
import Combine
import ComposableArchitecture
import Errors
import FeatureUserDeletionDomain
import Foundation

public struct UserDeletionReducer: Reducer {

    public typealias State = UserDeletionState
    public typealias Action = UserDeletionAction

    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let userDeletionRepository: UserDeletionRepositoryAPI
    public let analyticsRecorder: AnalyticsEventRecorderAPI
    public let logoutAndForgetWallet: () -> Void
    public let dismissFlow: () -> Void

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        userDeletionRepository: UserDeletionRepositoryAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        dismissFlow: @escaping () -> Void,
        logoutAndForgetWallet: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.userDeletionRepository = userDeletionRepository
        self.analyticsRecorder = analyticsRecorder
        self.dismissFlow = dismissFlow
        self.logoutAndForgetWallet = logoutAndForgetWallet
    }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .route(let routeItent):
                state.route = routeItent
                return .none
            case .showConfirmationScreen:
                state.route = .navigate(to: .showConfirmationView)
                return .none
            case .dismissFlow:
                dismissFlow()
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.confirmViewState, action: /Action.onConfirmViewChanged) {
            DeletionConfirmReducer(
                mainQueue: .main,
                userDeletionRepository: userDeletionRepository,
                analyticsRecorder: analyticsRecorder,
                dismissFlow: dismissFlow,
                logoutAndForgetWallet: logoutAndForgetWallet
            )
        }
    }
}

#if DEBUG

extension UserDeletionReducer {
    static let preview = UserDeletionReducer(
        mainQueue: .main,
        userDeletionRepository: NoOpUserDeletionRepository(),
        analyticsRecorder: AnalyticsEventRecorder(analyticsServiceProviders: []),
        dismissFlow: {},
        logoutAndForgetWallet: {}
    )
}

class NoOpUserDeletionRepository: UserDeletionRepositoryAPI {
    func deleteUser(with reason: String?) -> AnyPublisher<Void, Errors.NetworkError> { .empty() }
}

#endif
