// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAuthenticationDomain
import ToolKit

// MARK: - Type

public enum ResetPasswordAction: Equatable {
    public enum URLContent {
        case identifyVerificationOverview

        var url: URL? {
            switch self {
            case .identifyVerificationOverview:
                URL(string: Constants.SupportURL.ResetPassword.identityVerificationOverview)
            }
        }
    }

    case didChangeNewPassword(String)
    case didChangeConfirmNewPassword(String)
    case reset(password: String)
    case open(urlContent: URLContent)
    case resetAccountFailure(ResetAccountFailureAction)
    case setResetAccountFailureVisible(Bool)
    case none
}

// MARK: - Properties

struct ResetPasswordState: Equatable {
    var newPassword: String
    var confirmNewPassword: String
    var isResetAccountFailureVisible: Bool
    var resetAccountFailureState: ResetAccountFailureState?
    var isLoading: Bool
    var passwordRulesBreached: [PasswordValidationRule] = []

    init() {
        self.newPassword = ""
        self.confirmNewPassword = ""
        self.isResetAccountFailureVisible = false
        self.isLoading = false
    }
}

struct ResetPasswordReducer: Reducer {

    typealias State = ResetPasswordState
    typealias Action = ResetPasswordAction

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

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            case .didChangeNewPassword(let password):
                state.newPassword = password
                state.passwordRulesBreached = passwordValidator.validate(password: password)
                return .none

            case .didChangeConfirmNewPassword(let password):
                state.confirmNewPassword = password
                return .none

            case .open(let urlContent):
                guard let url = urlContent.url else {
                    return .none
                }
                externalAppOpener.open(url)
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
        .ifLet(\.resetAccountFailureState, action: /Action.resetAccountFailure) {
            ResetAccountFailureReducer(externalAppOpener: externalAppOpener)
        }
    }
}
