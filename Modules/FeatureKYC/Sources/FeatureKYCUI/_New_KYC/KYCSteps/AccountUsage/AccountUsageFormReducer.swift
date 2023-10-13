// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import Errors
import FeatureFormDomain
import Localization

extension AccountUsage {

    enum Form {

        struct State: Equatable {
            @BindingState var form: FeatureFormDomain.Form
            @PresentationState var alert: AlertState<Action.AlertAction>?
            var submissionState: LoadingState<Empty, Empty> = .idle
        }

        enum Action: Equatable, BindableAction {
            enum AlertAction {
                case dismiss
                case submit
            }
            case binding(BindingAction<State>)
            case onComplete
            case submit
            case submissionDidComplete(Result<Empty, NabuNetworkError>)
            case alert(PresentationAction<AlertAction>)
        }

        struct FormReducer: Reducer {

            typealias State = AccountUsage.Form.State
            typealias Action = AccountUsage.Form.Action

            let submitForm: (FeatureFormDomain.Form) -> AnyPublisher<Void, NabuNetworkError>
            let mainQueue: AnySchedulerOf<DispatchQueue>

            var body: some ReducerOf<Self> {
                BindingReducer()
                Reduce { state, action in
                    switch action {
                    case .binding:
                        return .none

                    case .onComplete:
                        // handled in parent reducer
                        return .none

                    case .submit, .alert(.presented(.submit)):
                        state.submissionState = .loading
                        return .publisher { [form = state.form] in
                            submitForm(form)
                                .receive(on: mainQueue)
                                .map { .submissionDidComplete(.success(Empty())) }
                                .catch { .submissionDidComplete(.failure($0)) }
                        }

                    case .submissionDidComplete(let result):
                        switch result {
                        case .success:
                            state.submissionState = .success(Empty())
                            return Effect.send(.onComplete)

                        case .failure(let error):
                            state.submissionState = .failure(Empty())
                            state.alert = AlertState(
                                title: TextState(LocalizationConstants.NewKYC.GenericError.title),
                                message: TextState(String(describing: error)),
                                primaryButton: .default(
                                    TextState(LocalizationConstants.NewKYC.GenericError.retryButtonTitle),
                                    action: .send(.submit)
                                ),
                                secondaryButton: .cancel(
                                    TextState(LocalizationConstants.NewKYC.GenericError.cancelButtonTitle),
                                    action: .send(.dismiss)
                                )
                            )
                        }
                        return .none

                    case .alert(.dismiss), .alert(.presented(.dismiss)):
                        state.submissionState = .idle
                        state.alert = nil
                        return .none
                    }
                }
            }
        }
    }
}
