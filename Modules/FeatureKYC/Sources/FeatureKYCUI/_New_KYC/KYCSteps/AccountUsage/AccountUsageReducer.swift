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

    struct AccountUsageReducer: Reducer {

        typealias State = AccountUsage.State
        typealias Action = AccountUsage.Action

        let onComplete: () -> Void
        let dismiss: () -> Void
        let loadForm: () -> AnyPublisher<FeatureFormDomain.Form, NabuNetworkError>
        let submitForm: (FeatureFormDomain.Form) -> AnyPublisher<Void, NabuNetworkError>
        let analyticsRecorder: AnalyticsEventRecorderAPI
        let mainQueue: AnySchedulerOf<DispatchQueue> = .main

        var body: some Reducer<State, Action> {
            Reduce { state, action in
                switch action {
                case .onAppear:
                    analyticsRecorder.record(event: Events.accountInfoScreenViewed)
                    return Effect.send(.loadForm)

                case .onComplete:
                    onComplete()
                    return .none

                case .dismiss:
                    dismiss()
                    return .none

                case .loadForm:
                    state = .loading
                    return .publisher {
                        loadForm()
                            .receive(on: mainQueue)
                            .map { .formDidLoad(.success($0)) }
                            .catch { .formDidLoad(.failure($0)) }
                    }

                case .formDidLoad(let result):
                    switch result {
                    case .success(let form) where form.isEmpty:
                        return Effect.send(.onComplete)
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
                                        title: LocalizationConstants.NewKYC.GenericError.cancelButtonTitle,
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
                        return .run { _ in
                            analyticsRecorder.record(event: Events.accountInfoSubmitted)
                        }

                    case .onComplete:
                        return Effect.send(.onComplete)

                    default:
                        return .none
                    }
                }
            }
            Scope(state: /AccountUsage.State.success, action: /AccountUsage.Action.form) {
                AccountUsage.Form.FormReducer(submitForm: submitForm, mainQueue: mainQueue)
            }
        }
    }
}

// MARK: SwiftUI Preview Helpers

extension AccountUsage.AccountUsageReducer {

    static let preview = AccountUsage.AccountUsageReducer(
        onComplete: {},
        dismiss: {},
        loadForm: { .empty() },
        submitForm: { _ in .empty() },
        analyticsRecorder: NoOpAnalyticsRecorder()
    )
}
