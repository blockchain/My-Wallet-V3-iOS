import AnalyticsKit
import Combine
import ComposableArchitecture
import ComposableNavigation
import Errors
import FeatureUserDeletionDomain
import Foundation

public struct DeletionConfirmReducer: Reducer {

    public typealias State = DeletionConfirmState
    public typealias Action = DeletionConfirmAction

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
            case .showResultScreen(let result):
                state.resultViewState = DeletionResultState(success: result.isSuccess)
                state.route = .navigate(to: .showResultScreen)
                return .none
            case .deleteUserAccount:
                guard state.isConfirmationInputValid else {
                    return Effect.send(.validateConfirmationInput)
                }
                state.isLoading = true
                return .publisher {
                    userDeletionRepository
                        .deleteUser(with: nil)
                        .receive(on: mainQueue)
                        .map { .showResultScreen(result: .success(())) }
                        .catch { .showResultScreen(result: .failure($0)) }
                }
            case .validateConfirmationInput:
                state.validateConfirmationInputField()
                return .none
            case .dismissFlow:
                dismissFlow()
                return .none
            case .route(let routeItent):
                state.route = routeItent
                return .none
            case .binding(\.$textFieldText):
                return Effect.send(.validateConfirmationInput)
            case .onConfirmViewChanged:
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.resultViewState, action: /Action.onConfirmViewChanged) {
            DeletionResultReducer(
                mainQueue: .main,
                analyticsRecorder: analyticsRecorder,
                dismissFlow: dismissFlow,
                logoutAndForgetWallet: logoutAndForgetWallet
            )
        }
        DeletionConfirmAnalytics(analyticsRecorder: analyticsRecorder)
    }
}

// MARK: - Private

struct DeletionConfirmAnalytics: Reducer {

    typealias State = DeletionConfirmState
    typealias Action = DeletionConfirmAction

    let analyticsRecorder: AnalyticsEventRecorderAPI

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .showResultScreen(.success):
                analyticsRecorder.record(
                    event: .accountDeletionSuccess
                )
                return .none
            case .showResultScreen(.failure(let error)):
                analyticsRecorder.record(
                    event: .accountDeletionFailure(
                        errorMessage: error.localizedDescription
                    )
                )
                return .none
            default:
                return .none
            }
        }
    }
}

#if DEBUG

extension DeletionConfirmReducer {
    static let preview = DeletionConfirmReducer(
        mainQueue: .main,
        userDeletionRepository: NoOpUserDeletionRepository(),
        analyticsRecorder: AnalyticsEventRecorder(analyticsServiceProviders: []),
        dismissFlow: {},
        logoutAndForgetWallet: {}
    )
}

#endif
