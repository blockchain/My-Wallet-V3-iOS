// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import DIKit
import FeatureAuthenticationDomain
import ToolKit

// MARK: - Type

public enum ResetPasswordAction: Equatable {
    public enum URLContent {
        case identifyVerificationOverview

        var url: URL? {
            switch self {
            case .identifyVerificationOverview:
                return URL(string: Constants.SupportURL.ResetPassword.identityVerificationOverview)
            }
        }
    }

    case didChangeNewPassword(String)
    case didChangeConfirmNewPassword(String)
    case didChangePasswordStrength(PasswordValidationScore)
    case reset(password: String)
    case validatePasswordStrength
    case open(urlContent: URLContent)
    case resetAccountFailure(ResetAccountFailureAction)
    case setResetAccountFailureVisible(Bool)
    case none
}

// MARK: - Properties

struct ResetPasswordState: Equatable {
    var newPassword: String
    var confirmNewPassword: String
    var passwordStrength: PasswordValidationScore
    var isResetAccountFailureVisible: Bool
    var resetAccountFailureState: ResetAccountFailureState?
    var isLoading: Bool

    init() {
        self.newPassword = ""
        self.confirmNewPassword = ""
        self.passwordStrength = .none
        self.isResetAccountFailureVisible = false
        self.isLoading = false
    }
}

struct ResetPasswordEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let passwordValidator: PasswordValidatorAPI
    let externalAppOpener: ExternalAppOpener
    let errorRecorder: ErrorRecording

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        passwordValidator: PasswordValidatorAPI,
        externalAppOpener: ExternalAppOpener,
        errorRecorder: ErrorRecording
    ) {
        self.mainQueue = mainQueue
        self.passwordValidator = passwordValidator
        self.externalAppOpener = externalAppOpener
        self.errorRecorder = errorRecorder
    }
}

let resetPasswordReducer = Reducer.combine(
    resetAccountFailureReducer
        .optional()
        .pullback(
            state: \.resetAccountFailureState,
            action: /ResetPasswordAction.resetAccountFailure,
            environment: { _ in ResetAccountFailureEnvironment() }
        ),
    Reducer<
        ResetPasswordState,
        ResetPasswordAction,
        ResetPasswordEnvironment
    > { state, action, environment in
        switch action {

        case .didChangeNewPassword(let password):
            state.newPassword = password
            return EffectTask(value: .validatePasswordStrength)

        case .didChangeConfirmNewPassword(let password):
            state.confirmNewPassword = password
            return .none

        case .didChangePasswordStrength(let score):
            state.passwordStrength = score
            return .none

        case .validatePasswordStrength:
            return environment
                .passwordValidator
                .validate(password: state.newPassword)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> ResetPasswordAction in
                    guard case .success(let score) = result else {
                        return .none
                    }
                    return .didChangePasswordStrength(score)
                }

        case .open(let urlContent):
            guard let url = urlContent.url else {
                return .none
            }
            environment.externalAppOpener.open(url)
            return .none

        case .reset:
            state.isLoading = true
            return .none

        case .setResetAccountFailureVisible(let isVisible):
            state.isResetAccountFailureVisible = isVisible
            if isVisible {
                state.resetAccountFailureState = .init()
            }
            return .none

        case .resetAccountFailure:
            return .none

        case .none:
            return .none
        }
    }
)
