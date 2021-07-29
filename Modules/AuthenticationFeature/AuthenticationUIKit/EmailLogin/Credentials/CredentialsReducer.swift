// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import AuthenticationKit
import ComposableArchitecture
import DIKit
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

// MARK: - Type

public enum CredentialsAction: Equatable {
    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    public enum WalletPairingAction: Equatable {
        case approveEmailAuthorization
        case authenticate
        case authenticateWithTwoFAOrHardwareKey
        case decryptWalletWithPassword(String)
        case pollWalletIdentifier
        case requestSMSCode
        case setupSessionToken
    }

    case didAppear(context: CredentialsContext)
    case didDisappear
    case didChangeWalletIdentifier(String)
    case password(PasswordAction)
    case twoFA(TwoFAAction)
    case hardwareKey(HardwareKeyAction)
    case walletPairing(WalletPairingAction)
    case setTwoFAOrHardwareKeyVerified(Bool)
    case accountLockedErrorVisibility(Bool)
    case credentialsFailureAlert(AlertAction)
    case none
}

// MARK: - Properties

enum WalletPairingCancelations {
    struct WalletIdentifierPollingTimerId: Hashable {}
    struct WalletIdentifierPollingId: Hashable {}
}

public enum CredentialsContext: Equatable {
    case walletInfo(WalletInfo)
    case walletIdentifier(email: String)
    case none
}

struct CredentialsState: Equatable {
    var passwordState: PasswordState
    var twoFAState: TwoFAState?
    var hardwareKeyState: HardwareKeyState?
    var emailAddress: String
    var walletGuid: String
    var emailCode: String
    var isTwoFACodeOrHardwareKeyVerified: Bool
    var isAccountLocked: Bool
    var isWalletIdentifierIncorrect: Bool
    var credentialsFailureAlert: AlertState<CredentialsAction>?

    var isLoading: Bool

    init() {
        passwordState = .init()
        twoFAState = .init()
        hardwareKeyState = .init()
        emailAddress = ""
        walletGuid = ""
        emailCode = ""
        isTwoFACodeOrHardwareKeyVerified = false
        isAccountLocked = false
        isWalletIdentifierIncorrect = false
        isLoading = false
    }
}

struct CredentialsEnvironment {
    typealias WalletValidation = (String) -> Bool

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let pollingQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI
    let emailAuthorizationService: EmailAuthorizationServiceAPI
    let sessionTokenService: SessionTokenServiceAPI
    let smsService: SMSServiceAPI
    let loginService: LoginServiceAPI
    let wallet: WalletAuthenticationKitWrapper
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let errorRecorder: ErrorRecording
    let walletIdentifierValidator: WalletValidation

    init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        pollingQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue(
            label: "com.blockchain.AuthenticationEnvironmentPollingQueue",
            qos: .utility
        ).eraseToAnyScheduler(),
        deviceVerificationService: DeviceVerificationServiceAPI,
        emailAuthorizationService: EmailAuthorizationServiceAPI = resolve(),
        sessionTokenService: SessionTokenServiceAPI = resolve(),
        smsService: SMSServiceAPI = resolve(),
        loginService: LoginServiceAPI = resolve(),
        wallet: WalletAuthenticationKitWrapper = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        walletIdentifierValidator: @escaping WalletValidation = identifierValidator,
        errorRecorder: ErrorRecording
    ) {

        self.mainQueue = mainQueue
        self.pollingQueue = pollingQueue
        self.deviceVerificationService = deviceVerificationService
        self.emailAuthorizationService = emailAuthorizationService
        self.sessionTokenService = sessionTokenService
        self.smsService = smsService
        self.loginService = loginService
        self.wallet = wallet
        self.analyticsRecorder = analyticsRecorder
        self.walletIdentifierValidator = walletIdentifierValidator
        self.errorRecorder = errorRecorder
    }
}

let credentialsReducer = Reducer.combine(
    passwordReducer
        .pullback(
            state: \CredentialsState.passwordState,
            action: /CredentialsAction.password,
            environment: { _ in PasswordEnvironment() }
        ),
    twoFAReducer
        .optional()
        .pullback(
            state: \CredentialsState.twoFAState,
            action: /CredentialsAction.twoFA,
            environment: { $0 }
        ),
    hardwareKeyReducer
        .optional()
        .pullback(
            state: \CredentialsState.hardwareKeyState,
            action: /CredentialsAction.hardwareKey,
            environment: { $0 }
        ),
    Reducer<
        CredentialsState,
        CredentialsAction,
        CredentialsEnvironment
    > { state, action, environment in
        switch action {
        case .didAppear(.walletInfo(let info)):
            state.emailAddress = info.email
            state.walletGuid = info.guid
            state.emailCode = info.emailCode
            return Effect(value: .walletPairing(.setupSessionToken))

        case .didAppear(.walletIdentifier(let email)):
            state.emailAddress = email
            return Effect(value: .walletPairing(.setupSessionToken))

        case .didAppear:
            return .none

        case .didDisappear:
            state.emailAddress = ""
            state.walletGuid = ""
            state.emailCode = ""
            state.isTwoFACodeOrHardwareKeyVerified = false
            state.isAccountLocked = false
            state.twoFAState = nil
            state.hardwareKeyState = nil
            return .cancel(id: WalletPairingCancelations.WalletIdentifierPollingTimerId())

        case .didChangeWalletIdentifier(let guid):
            state.walletGuid = guid
            guard !guid.isEmpty else {
                state.isWalletIdentifierIncorrect = false
                return .none
            }
            state.isWalletIdentifierIncorrect = !environment.walletIdentifierValidator(guid)
            return .none

        case .walletPairing(.approveEmailAuthorization):
            guard !state.emailCode.isEmpty else {
                fatalError("Email code should not be empty")
            }
            return .merge(
                // Poll the Guid every 2 seconds
                Effect
                    .timer(
                        id: WalletPairingCancelations.WalletIdentifierPollingTimerId(),
                        every: 2,
                        on: environment.pollingQueue
                    )
                    .map { _ in .walletPairing(.pollWalletIdentifier) },
                // Immediately authorize the email
                environment
                    .deviceVerificationService
                    .authorizeLogin(emailCode: state.emailCode)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> CredentialsAction in
                        if case .failure(let error) = result {
                            // If failed, an `Authorize Log In` will be sent to user for manual authorization
                            environment.errorRecorder.error(error)
                        }
                        return .none
                    }
            )

        case .walletPairing(.authenticate):
            guard !state.walletGuid.isEmpty else {
                fatalError("GUID should not be empty")
            }
            guard let twoFAState = state.twoFAState,
                  let hardwareKeyState = state.hardwareKeyState
            else {
                fatalError("States should not be nil")
            }
            state.isLoading = true
            let password = state.passwordState.password
            return .merge(
                // Clear error states
                Effect(value: .accountLockedErrorVisibility(false)),
                Effect(value: .password(.incorrectPasswordErrorVisibility(false))),
                .cancel(id: WalletPairingCancelations.WalletIdentifierPollingTimerId()),
                environment
                    .loginService
                    .loginPublisher(walletIdentifier: state.walletGuid)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> CredentialsAction in
                        switch result {
                        case .success:
                            return .walletPairing(.decryptWalletWithPassword(password))
                        case .failure(let error):
                            switch error {
                            case .twoFactorOTPRequired(let type):
                                if twoFAState.isTwoFACodeFieldVisible ||
                                    hardwareKeyState.isHardwareKeyCodeFieldVisible
                                {
                                    return .walletPairing(.authenticateWithTwoFAOrHardwareKey)
                                }
                                switch type {
                                case .email:
                                    return .walletPairing(.approveEmailAuthorization)
                                case .sms:
                                    return .walletPairing(.requestSMSCode)
                                case .google:
                                    return .twoFA(.twoFACodeFieldVisibility(true))
                                case .yubiKey, .yubikeyMtGox:
                                    return .hardwareKey(.hardwareKeyCodeFieldVisibility(true))
                                default:
                                    fatalError("Unsupported TwoFA Types")
                                }
                            case .walletPayloadServiceError(.accountLocked):
                                return .accountLockedErrorVisibility(true)
                            case .walletPayloadServiceError(let error):
                                // TODO: Await design for error state
                                environment.errorRecorder.error(error)
                                return .credentialsFailureAlert(.show(title: "Wallet Payload Error", message: error.localizedDescription))
                            case .twoFAWalletServiceError:
                                fatalError("Shouldn't receive TwoFAService errors here")
                            }
                        }
                    }
            )

        case .walletPairing(.authenticateWithTwoFAOrHardwareKey):
            guard !state.walletGuid.isEmpty else {
                fatalError("GUID should not be empty")
            }
            guard let twoFAState = state.twoFAState,
                  let hardwareKeyState = state.hardwareKeyState
            else {
                fatalError("States should not be nil")
            }
            state.isLoading = true
            return .merge(
                // clear error states
                Effect(value: .hardwareKey(.incorrectHardwareKeyCodeErrorVisibility(false))),
                Effect(value: .twoFA(.incorrectTwoFACodeErrorVisibility(false))),
                environment
                    .loginService
                    .loginPublisher(
                        walletIdentifier: state.walletGuid,
                        code: twoFAState.twoFACode
                    )
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> CredentialsAction in
                        switch result {
                        case .success:
                            return .setTwoFAOrHardwareKeyVerified(true)
                        case .failure(let error):
                            switch error {
                            case .twoFAWalletServiceError(let error):
                                switch error {
                                case .wrongCode(let attemptsLeft):
                                    return .twoFA(.didChangeTwoFACodeAttemptsLeft(attemptsLeft))
                                case .accountLocked:
                                    return .accountLockedErrorVisibility(true)
                                case .missingCode:
                                    return .credentialsFailureAlert(.show(title: "Missing 2FA Code", message: error.localizedDescription))
                                default:
                                    return .credentialsFailureAlert(.show(title: "Two FA Error", message: error.localizedDescription))
                                }
                            case .walletPayloadServiceError:
                                fatalError("Shouldn't receive WalletPayloadService errors here")
                            case .twoFactorOTPRequired:
                                fatalError("Shouldn't receive twoFactorOTPRequired error here")
                            }
                        }
                    }
            )

        case .walletPairing(.decryptWalletWithPassword):
            // also handled in welcome reducer
            state.isLoading = true
            return .none

        case .walletPairing(.pollWalletIdentifier):
            return .concatenate(
                .cancel(id: WalletPairingCancelations.WalletIdentifierPollingId()),
                environment
                    .emailAuthorizationService
                    .authorizeEmailPublisher()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .cancellable(id: WalletPairingCancelations.WalletIdentifierPollingId(), cancelInFlight: true)
                    .map { result -> CredentialsAction in
                        // Authenticate if the wallet identifier exists in repo
                        if case .success = result {
                            return .walletPairing(.authenticate)
                        }
                        return .none
                    }
            )

        case .walletPairing(.requestSMSCode):
            return .merge(
                Effect(value: .twoFA(.resendSMSButtonVisibility(true))),
                Effect(value: .twoFA(.twoFACodeFieldVisibility(true))),
                environment
                    .smsService
                    .requestPublisher()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> CredentialsAction in
                        if case .failure(let error) = result {
                            // TODO: Await design for error state
                            environment.errorRecorder.error(error)
                            return .credentialsFailureAlert(.show(title: "Send SMS Failed", message: error.localizedDescription))
                        }
                        return .none
                    }
            )

        case .walletPairing(.setupSessionToken):
            return environment
                .sessionTokenService
                .setupSessionTokenPublisher()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> CredentialsAction in
                    if case .failure(let error) = result {
                        // TODO: Await design for error state
                        environment.errorRecorder.error(error)
                        return .credentialsFailureAlert(.show(title: "Session Token Error", message: error.localizedDescription))
                    }
                    return .none
                }

        case .setTwoFAOrHardwareKeyVerified(let isVerified):
            state.isTwoFACodeOrHardwareKeyVerified = isVerified
            guard isVerified else {
                return .none
            }
            state.isLoading = false
            let password = state.passwordState.password
            return .merge(
                Effect(value: .walletPairing(.decryptWalletWithPassword(password)))
            )

        case .accountLockedErrorVisibility(let isVisible):
            state.isAccountLocked = isVisible
            state.isLoading = isVisible ? false : state.isLoading
            return .none

        case .credentialsFailureAlert(.show(let title, let message)):
            state.isLoading = false
            state.credentialsFailureAlert = AlertState(
                title: TextState(verbatim: title),
                message: TextState(verbatim: message),
                dismissButton: .default(
                    TextState(LocalizationConstants.okString),
                    send: .credentialsFailureAlert(.dismiss)
                )
            )
            return .none

        case .credentialsFailureAlert(.dismiss):
            state.credentialsFailureAlert = nil
            return .none

        case .twoFA(.twoFACodeFieldVisibility(let visible)),
             .twoFA(.incorrectTwoFACodeErrorVisibility(let visible)):
            state.isLoading = visible ? false : state.isLoading
            return .none
        case .hardwareKey(.hardwareKeyCodeFieldVisibility(let visible)),
             .hardwareKey(.incorrectHardwareKeyCodeErrorVisibility(let visible)):
            state.isLoading = visible ? false : state.isLoading
            return .none

        case .password(.incorrectPasswordErrorVisibility(let visible)):
            state.isLoading = visible ? false : state.isLoading
            return .none

        case .twoFA:
            return .none
        case .hardwareKey:
            return .none
        case .password:
            return .none

        case .none:
            return .none
        }
    }
)

// MARK: - Private

private func identifierValidator(_ value: String) -> Bool {
    value.range(of: TextRegex.walletIdentifier.rawValue, options: .regularExpression) != nil
}