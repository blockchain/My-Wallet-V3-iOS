// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import Errors
import FeatureFormDomain
import Localization
import ToolKit

enum AccountUsage {

    typealias State = LoadingState<AccountUsage.Form.State, FailureState<AccountUsage.Action>>
    private typealias Events = AnalyticsEvents.New.KYC

    enum Action: Equatable {
        case onAppear
        case onComplete
        case loadForm
        case dismiss
        case formDidLoad(Result<FeatureFormDomain.Form, NabuNetworkError>)
        case form(AccountUsage.Form.Action)
    }

    struct Environment {
        let onComplete: () -> Void
        let dismiss: () -> Void
        let loadForm: () -> AnyPublisher<FeatureFormDomain.Form, NabuNetworkError>
        let submitForm: (FeatureFormDomain.Form) -> AnyPublisher<Void, NabuNetworkError>
        let analyticsRecorder: AnalyticsEventRecorderAPI
        let mainQueue: AnySchedulerOf<DispatchQueue> = .main
    }

    static let reducer = Reducer.combine(
        Reducer<State, Action, Environment> { state, action, environment in
            switch action {
            case .onAppear:
                environment.analyticsRecorder.record(event: Events.accountInfoScreenViewed)
                return EffectTask(value: .loadForm)

            case .onComplete:
                return .fireAndForget(environment.onComplete)

            case .dismiss:
                return .fireAndForget(environment.dismiss)

            case .loadForm:
                state = .loading
                return environment.loadForm()
                    .catchToEffect()
                    .map(Action.formDidLoad)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()

            case .formDidLoad(let result):
                switch result {
                case .success(let form) where form.isEmpty:
                    return EffectTask(value: .onComplete)
                case .success(let form):
                    state = .success(AccountUsage.Form.State(form: form))
                case .failure(let error):
                    let ux = UX.Error(nabu: error)
                    state = .failure(
                        FailureState(
                            title: ux.title,
                            message: ux.message,
                            buttons: [
                                .primary(
                                    title: LocalizationConstants.NewKYC.GenericError.retryButtonTitle,
                                    action: .loadForm
                                ),
                                .destructive(
                                    title: LocalizationConstants.NewKYC.GenericError.retryButtonTitle,
                                    action: .dismiss
                                )
                            ]
                        )
                    )
                }
                return .none

            case .form(let action):
                switch action {
                case .submit:
                    return .fireAndForget {
                        environment.analyticsRecorder.record(event: Events.accountInfoSubmitted)
                    }

                case .onComplete:
                    return EffectTask(value: .onComplete)

                default:
                    return .none
                }
            }
        },
        AccountUsage.Form.reducer.pullback(
            state: /AccountUsage.State.success,
            action: /AccountUsage.Action.form,
            environment: {
                AccountUsage.Form.Environment(
                    submitForm: $0.submitForm,
                    mainQueue: $0.mainQueue
                )
            }
        )
    )
}

// MARK: SwiftUI Preview Helpers

extension AccountUsage.Environment {

    static let preview = AccountUsage.Environment(
        onComplete: {},
        dismiss: {},
        loadForm: { .empty() },
        submitForm: { _ in .empty() },
        analyticsRecorder: NoOpAnalyticsRecorder()
    )
}
