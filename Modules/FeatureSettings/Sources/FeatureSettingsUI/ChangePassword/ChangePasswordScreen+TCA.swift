// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import Errors
import FeatureAuthenticationDomain
import Localization
import PlatformUIKit
import SwiftUI
import ToolKit

enum ChangePasswordAction: BindableAction {
    case updatePassword
    case didUpdatePassword(Result<Void, PasswordRepositoryError>)
    case binding(BindingAction<ChangePasswordState>)
}

struct ChangePasswordState: Equatable {

    var isUpdateButtonDisabled: Bool {
        current.isEmpty
        || new != confirmation
        || loading
    }

    enum Field: Equatable {
        case current, new, confirmation
    }

    @BindingState var current = ""
    @BindingState var new = ""
    @BindingState var confirmation = ""
    @BindingState var fatalError: UX.Error?
    @BindingState var passwordFieldTextVisible: Bool = false

    var passwordRulesBreached: [PasswordValidationRule] = []
    var loading: Bool = false
    var error: Nabu.Error?
}

struct ChangePasswordReducer: Reducer {

    private let mainQueue: AnySchedulerOf<DispatchQueue>
    private let passwordRepository: PasswordRepositoryAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let passwordValidator: PasswordValidatorAPI
    private let coordinator: AuthenticationCoordinating
    private let previousAPI: RoutingPreviousStateEmitterAPI
    private let onComplete: (() -> Void)?

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        coordinator: AuthenticationCoordinating,
        passwordRepository: PasswordRepositoryAPI,
        passwordValidator: PasswordValidatorAPI,
        previousAPI: RoutingPreviousStateEmitterAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        onComplete: (() -> Void)? = nil
    ) {
        self.mainQueue = mainQueue
        self.analyticsRecorder = analyticsRecorder
        self.coordinator = coordinator
        self.passwordRepository = passwordRepository
        self.passwordValidator = passwordValidator
        self.previousAPI = previousAPI
        self.onComplete = onComplete
    }

    typealias State = ChangePasswordState
    typealias Action = ChangePasswordAction

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .updatePassword:
                guard state.current.isNotEmpty,
                      state.new == state.confirmation,
                      passwordValidator.validate(password: state.new).isEmpty
                else {
                    return .none
                }
                state.loading = true

                let test = passwordRepository
                    .password
                    .map { [state] password in
                        password == state.current
                    }
                    .eraseToAnyPublisher()

                return .publisher { [new = state.new] in
                    test
                        .flatMap { [passwordRepository] passwordOk -> AnyPublisher<Void, PasswordRepositoryError> in
                            if passwordOk {
                                passwordRepository.changePassword(password: new)
                            } else {
                                .failure(.invalidPassword)
                            }
                        }
                        .receive(on: mainQueue)
                        .map { .didUpdatePassword(.success(())) }
                        .catch { .didUpdatePassword(.failure($0)) }
                }
            case .didUpdatePassword(.failure(let error)):
                state.loading = false
                state.fatalError = UX.Error(error: error)
                return .none
            case .didUpdatePassword(.success):
                analyticsRecorder.record(event: AnalyticsEvents.New.Security.accountPasswordChanged)
                previousAPI.previousRelay.accept(())
                coordinator.changePin()
                return .none
            case .binding(\.$new):
                state.passwordRulesBreached = passwordValidator.validate(password: state.new)
                return .none
            case .binding:
                return .none
            }
        }
    }
}
