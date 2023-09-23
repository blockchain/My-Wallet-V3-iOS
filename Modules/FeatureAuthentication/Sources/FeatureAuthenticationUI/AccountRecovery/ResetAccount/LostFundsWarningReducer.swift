// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import FeatureAuthenticationDomain
import ToolKit

public enum LostFundsWarningAction: Equatable {
    case onDisappear
    case resetAccountButtonTapped
    case goBackButtonTapped
    case setResetPasswordScreenVisible(Bool)
    case resetPassword(ResetPasswordAction)
}

struct LostFundsWarningState: Equatable {
    var resetPasswordState: ResetPasswordState?
    var isResetPasswordScreenVisible: Bool = false
}

struct LostFundsWarningReducer: ReducerProtocol {

    typealias State = LostFundsWarningState
    typealias Action = LostFundsWarningAction

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let passwordValidator: PasswordValidatorAPI
    let externalAppOpener: ExternalAppOpener
    let errorRecorder: ErrorRecording

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        passwordValidator: PasswordValidatorAPI,
        externalAppOpener: ExternalAppOpener,
        errorRecorder: ErrorRecording
    ) {
        self.mainQueue = mainQueue
        self.analyticsRecorder = analyticsRecorder
        self.passwordValidator = passwordValidator
        self.externalAppOpener = externalAppOpener
        self.errorRecorder = errorRecorder
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onDisappear:
                analyticsRecorder.record(
                    event: .resetAccountCancelled
                )
                return .none
            case .goBackButtonTapped:
                return .none
            case .resetAccountButtonTapped:
                return EffectTask(value: .setResetPasswordScreenVisible(true))
            case .resetPassword:
                return .none
            case .setResetPasswordScreenVisible(let isVisible):
                state.isResetPasswordScreenVisible = isVisible
                if isVisible {
                    state.resetPasswordState = .init()
                }
                return .none
            }
        }
        .ifLet(\.resetPasswordState, action: /Action.resetPassword) {
            ResetPasswordReducer(
                mainQueue: mainQueue,
                passwordValidator: passwordValidator,
                externalAppOpener: externalAppOpener,
                errorRecorder: errorRecorder
            )
        }
    }
}
