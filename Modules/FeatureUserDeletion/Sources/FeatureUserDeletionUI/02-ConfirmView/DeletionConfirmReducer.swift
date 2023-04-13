import Combine
import ComposableArchitecture
import ComposableNavigation
import FeatureUserDeletionDomain
import Foundation

public enum DeletionConfirmModule {}

extension DeletionConfirmModule {
    public static var reducer = Reducer<DeletionConfirmState, DeletionConfirmAction, DeletionConfirmEnvironment>
        .combine(
            DeletionResultModule
                .reducer
                .optional()
                .pullback(
                    state: \.resultViewState,
                    action: /DeletionConfirmAction.onConfirmViewChanged,
                    environment: { env in
                        DeletionResultEnvironment(
                            mainQueue: .main,
                            analyticsRecorder: env.analyticsRecorder,
                            dismissFlow: env.dismissFlow,
                            logoutAndForgetWallet: env.logoutAndForgetWallet
                        )
                    }
                ),
            deletionConfirmReducer
        )

    public static var deletionConfirmReducer: Reducer<DeletionConfirmState, DeletionConfirmAction, DeletionConfirmEnvironment> {
        .init { state, action, environment in
            switch action {
            case .showResultScreen(let result):
                state.resultViewState = DeletionResultState(success: result.isSuccess)
                state.route = .navigate(to: .showResultScreen)
                return .none
            case .deleteUserAccount:
                guard state.isConfirmationInputValid else {
                    return EffectTask(value: .validateConfirmationInput)
                }
                state.isLoading = true
                return environment
                    .userDeletionRepository
                    .deleteUser(with: nil)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(DeletionConfirmAction.showResultScreen)
            case .validateConfirmationInput:
                state.validateConfirmationInputField()
                return .none
            case .dismissFlow:
                environment.dismissFlow()
                return .none
            case .route(let routeItent):
                state.route = routeItent
                return .none
            case .binding(\.$textFieldText):
                return EffectTask(value: .validateConfirmationInput)
            case .onConfirmViewChanged:
                return .none
            default:
                return .none
            }
        }
        .binding()
        .analytics()
    }
}

// MARK: - Private

extension Reducer where
    Action == DeletionConfirmAction,
    State == DeletionConfirmState,
    Environment == DeletionConfirmEnvironment
{
    /// Helper function for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                DeletionConfirmState,
                DeletionConfirmAction,
                DeletionConfirmEnvironment
            > { _, action, environment in
                switch action {
                case .showResultScreen(.success):
                    environment.analyticsRecorder.record(
                        event: .accountDeletionSuccess
                    )
                    return .none
                case .showResultScreen(.failure(let error)):
                    environment.analyticsRecorder.record(
                        event: .accountDeletionFailure(
                            errorMessage: error.localizedDescription
                        )
                    )
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
