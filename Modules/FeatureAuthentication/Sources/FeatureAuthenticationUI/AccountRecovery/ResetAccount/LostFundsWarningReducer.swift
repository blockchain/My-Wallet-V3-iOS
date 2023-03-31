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

struct LostFundsWarningEnvironment {
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
}

let lostFundsWarningReducer = Reducer.combine(
    resetPasswordReducer
        .optional()
        .pullback(
            state: \LostFundsWarningState.resetPasswordState,
            action: /LostFundsWarningAction.resetPassword,
            environment: {
                ResetPasswordEnvironment(
                    mainQueue: $0.mainQueue,
                    passwordValidator: $0.passwordValidator,
                    externalAppOpener: $0.externalAppOpener,
                    errorRecorder: $0.errorRecorder
                )
            }
        ),
    Reducer<
        LostFundsWarningState,
        LostFundsWarningAction,
        LostFundsWarningEnvironment
    > { state, action, environment in
        switch action {
        case .onDisappear:
            environment.analyticsRecorder.record(
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
)
