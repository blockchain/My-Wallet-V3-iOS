// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import DIKit
import FeatureAuthenticationDomain
import ToolKit

// MARK: - Type

public enum WalletPairingAction: Equatable {
    case approveEmailAuthorization
    case authenticate(String, autoTrigger: Bool = false)
    case authenticateDidFail(LoginServiceError)
    case authenticateWithTwoFactorOTP(String)
    case authenticateWithTwoFactorOTPDidFail(LoginServiceError)
    case decryptWalletWithPassword(String)
    case didResendSMSCode(Result<EmptyValue, SMSServiceError>)
    case didSetupSessionToken(Result<EmptyValue, SessionTokenServiceError>)
    case handleSMS
    case needsEmailAuthorization
    case pollWalletIdentifier
    case resendSMSCode
    case setupSessionToken
    case startPolling
    case twoFactorOTPDidVerified
    case none
}

enum WalletPairingCancelations {
    struct WalletIdentifierPollingTimerId: Hashable {}
    struct WalletIdentifierPollingId: Hashable {}
}

// MARK: - Properties

struct WalletPairingState: Equatable {
    var emailAddress: String
    var emailCode: String?
    var walletGuid: String
    var password: String

    init(
        emailAddress: String = "",
        emailCode: String? = nil,
        walletGuid: String = "",
        password: String = ""
    ) {
        self.emailAddress = emailAddress
        self.emailCode = emailCode
        self.walletGuid = walletGuid
        self.password = password
    }
}

struct WalletPairingEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let pollingQueue: AnySchedulerOf<DispatchQueue>
    let sessionTokenService: SessionTokenServiceAPI
    let deviceVerificationService: DeviceVerificationServiceAPI
    let emailAuthorizationService: EmailAuthorizationServiceAPI
    let smsService: SMSServiceAPI
    let loginService: LoginServiceAPI
    let errorRecorder: ErrorRecording

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        pollingQueue: AnySchedulerOf<DispatchQueue>,
        sessionTokenService: SessionTokenServiceAPI,
        deviceVerificationService: DeviceVerificationServiceAPI,
        emailAuthorizationService: EmailAuthorizationServiceAPI,
        smsService: SMSServiceAPI,
        loginService: LoginServiceAPI,
        errorRecorder: ErrorRecording
    ) {
        self.mainQueue = mainQueue
        self.pollingQueue = pollingQueue
        self.sessionTokenService = sessionTokenService
        self.deviceVerificationService = deviceVerificationService
        self.emailAuthorizationService = emailAuthorizationService
        self.smsService = smsService
        self.loginService = loginService
        self.errorRecorder = errorRecorder
    }
}

let walletPairingReducer = Reducer<
    WalletPairingState,
    WalletPairingAction,
    WalletPairingEnvironment
> { state, action, environment in
    switch action {

    case .approveEmailAuthorization:
        return approveEmailAuthorization(state, environment)

    case .authenticate(let password, let autoTrigger):
        // credentials reducer will set password here
        state.password = password
        return authenticate(password, state, environment, isAutoTrigger: autoTrigger)

    case .authenticateWithTwoFactorOTP(let code):
        return authenticateWithTwoFactorOTP(code, state, environment)

    case .needsEmailAuthorization:
        return needsEmailAuthorization()

    case .pollWalletIdentifier:
        return pollWalletIdentifier(state, environment)

    case .resendSMSCode:
        return resendSMSCode(environment)

    case .setupSessionToken:
        return setupSessionToken(environment)

    case .startPolling:
        return startPolling(environment)

    case .authenticateDidFail,
         .authenticateWithTwoFactorOTPDidFail,
         .decryptWalletWithPassword,
         .didResendSMSCode,
         .didSetupSessionToken,
         .handleSMS,
         .twoFactorOTPDidVerified,
         .none:
        // handled in credentials reducer
        return .none
    }
}

// MARK: - Private Methods

private func approveEmailAuthorization(
    _ state: WalletPairingState,
    _ environment: WalletPairingEnvironment
) -> EffectTask<WalletPairingAction> {
    guard let emailCode = state.emailCode else {
        // we still need to display an alert and poll here,
        // since we might end up here in case of a deeplink failure
        return EffectTask(value: .needsEmailAuthorization)
    }
    return environment
        .deviceVerificationService
        .authorizeLogin(emailCode: emailCode)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map { result -> WalletPairingAction in
            if case .failure(let error) = result {
                // If failed, an `Authorize Log In` will be sent to user for manual authorization
                environment.errorRecorder.error(error)
                // we only want to handle `.expiredEmailCode` case, silent other errors...
                switch error {
                case .expiredEmailCode:
                    return .needsEmailAuthorization
                case .missingSessionToken, .networkError, .recaptchaError, .missingWalletInfo:
                    break
                }
            }
            return .startPolling
        }
}

private func authenticate(
    _ password: String,
    _ state: WalletPairingState,
    _ environment: WalletPairingEnvironment,
    isAutoTrigger: Bool
) -> EffectTask<WalletPairingAction> {
    guard !state.walletGuid.isEmpty else {
        fatalError("GUID should not be empty")
    }
    return .concatenate(
        .cancel(id: WalletPairingCancelations.WalletIdentifierPollingTimerId()),
        environment
            .loginService
            .login(walletIdentifier: state.walletGuid)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result -> WalletPairingAction in
                switch result {
                case .success:
                    if isAutoTrigger {
                        // edge case handling: if auto triggered, we don't want to decrypt wallet
                        return .none
                    }
                    return .decryptWalletWithPassword(password)
                case .failure(let error):
                    return .authenticateDidFail(error)
                }
            }
    )
}

private func authenticateWithTwoFactorOTP(
    _ code: String,
    _ state: WalletPairingState,
    _ environment: WalletPairingEnvironment
) -> EffectTask<WalletPairingAction> {
    guard !state.walletGuid.isEmpty else {
        fatalError("GUID should not be empty")
    }
    return environment
        .loginService
        .login(
            walletIdentifier: state.walletGuid,
            code: code
        )
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map { result -> WalletPairingAction in
            switch result {
            case .success:
                return .twoFactorOTPDidVerified
            case .failure(let error):
                return .authenticateWithTwoFactorOTPDidFail(error)
            }
        }
}

private func needsEmailAuthorization() -> EffectTask<WalletPairingAction> {
    EffectTask(value: .startPolling)
}

private func pollWalletIdentifier(
    _ state: WalletPairingState,
    _ environment: WalletPairingEnvironment
) -> EffectTask<WalletPairingAction> {
    .concatenate(
        .cancel(id: WalletPairingCancelations.WalletIdentifierPollingId()),
        environment
            .emailAuthorizationService
            .authorizeEmailPublisher()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(id: WalletPairingCancelations.WalletIdentifierPollingId())
            .map { result -> WalletPairingAction in
                // Authenticate if the wallet identifier exists in repo
                guard case .success = result else {
                    return .none
                }
                return .authenticate(state.password)
            }
    )
}

private func resendSMSCode(
    _ environment: WalletPairingEnvironment
) -> EffectTask<WalletPairingAction> {
    environment
        .smsService
        .request()
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map { result -> WalletPairingAction in
            switch result {
            case .success:
                return .didResendSMSCode(.success(.noValue))
            case .failure(let error):
                return .didResendSMSCode(.failure(error))
            }
        }
}

private func setupSessionToken(
    _ environment: WalletPairingEnvironment
) -> EffectTask<WalletPairingAction> {
    environment
        .sessionTokenService
        .setupSessionToken()
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map { result -> WalletPairingAction in
            switch result {
            case .success:
                return .didSetupSessionToken(.success(.noValue))
            case .failure(let error):
                return .didSetupSessionToken(.failure(error))
            }
        }
}

private func startPolling(
    _ environment: WalletPairingEnvironment
) -> EffectTask<WalletPairingAction> {
    // Poll the Guid every 2 seconds
    EffectTask
        .timer(
            id: WalletPairingCancelations.WalletIdentifierPollingTimerId(),
            every: 2,
            on: environment.pollingQueue
        )
        .map { _ in
            .pollWalletIdentifier
        }
        .receive(on: environment.mainQueue)
        .eraseToEffect()
}
