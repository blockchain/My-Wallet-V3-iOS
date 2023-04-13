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
            var submissionState: LoadingState<Empty, AlertState<Action>> = .idle
        }

        enum Action: Equatable, BindableAction {
            case binding(BindingAction<State>)
            case onComplete
            case submit
            case submissionDidComplete(Result<Empty, NabuNetworkError>)
            case dismissSubmissionError
        }

        struct Environment {
            let submitForm: (FeatureFormDomain.Form) -> AnyPublisher<Void, NabuNetworkError>
            let mainQueue: AnySchedulerOf<DispatchQueue>
        }

        static let reducer = Reducer<State, Action, Environment> { state, action, environment in
            switch action {
            case .binding:
                return .none

            case .onComplete:
                // handled in parent reducer
                return .none

            case .submit:
                state.submissionState = .loading
                return environment.submitForm(state.form)
                    .catchToEffect()
                    .map { result in
                        result.map(Empty.init)
                    }
                    .map(Action.submissionDidComplete)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()

            case .submissionDidComplete(let result):
                switch result {
                case .success:
                    state.submissionState = .success(Empty())
                    return EffectTask(value: .onComplete)

                case .failure(let error):
                    state.submissionState = .failure(
                        AlertState(
                            title: TextState(LocalizationConstants.NewKYC.GenericError.title),
                            message: TextState(String(describing: error)),
                            primaryButton: .default(
                                TextState(LocalizationConstants.NewKYC.GenericError.retryButtonTitle),
                                action: .send(.submit)
                            ),
                            secondaryButton: .cancel(
                                TextState(LocalizationConstants.NewKYC.GenericError.cancelButtonTitle)
                            )
                        )
                    )
                }
                return .none

            case .dismissSubmissionError:
                state.submissionState = .idle
                return .none
            }
        }
        .binding()
    }
}
