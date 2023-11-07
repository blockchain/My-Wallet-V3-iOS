// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
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

struct WalletPairingReducer: Reducer {

    typealias State = WalletPairingState
    typealias Action = WalletPairingAction

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

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            case .approveEmailAuthorization:
                return approveEmailAuthorization(state)

            case .authenticate(let password, let autoTrigger):
                // credentials reducer will set password here
                state.password = password
                return authenticate(password, state, isAutoTrigger: autoTrigger)

            case .authenticateWithTwoFactorOTP(let code):
                return authenticateWithTwoFactorOTP(code, state)

            case .needsEmailAuthorization:
                return needsEmailAuthorization()

            case .pollWalletIdentifier:
                return pollWalletIdentifier(state)

            case .resendSMSCode:
                return resendSMSCode()

            case .setupSessionToken:
                return setupSessionToken()

            case .startPolling:
                return startPolling()

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
    }

    private func approveEmailAuthorization(
        _ state: WalletPairingState
    ) -> Effect<WalletPairingAction> {
        guard let emailCode = state.emailCode else {
            // we still need to display an alert and poll here,
            // since we might end up here in case of a deeplink failure
            return Effect.send(.needsEmailAuthorization)
        }
        return .publisher {
            deviceVerificationService
                .authorizeLogin(emailCode: emailCode)
                .receive(on: mainQueue)
                .map { .startPolling }
                .catch { error in
                    errorRecorder.error(error)
                    switch error {
                    case .expiredEmailCode:
                        return .needsEmailAuthorization
                    case .missingSessionToken, .networkError, .recaptchaError, .missingWalletInfo, .timeout:
                        break
                    }
                    return .none
                }
        }
    }

    private func authenticate(
        _ password: String,
        _ state: WalletPairingState,
        isAutoTrigger: Bool
    ) -> Effect<WalletPairingAction>
   {
        guard !state.walletGuid.isEmpty else {
            fatalError("GUID should not be empty")
        }

       return .concatenate(
           .cancel(id: WalletPairingCancelations.WalletIdentifierPollingTimerId()),
           .publisher {
               loginService
                    .login(walletIdentifier: state.walletGuid)
                    .receive(on: mainQueue)
                    .map { _ -> Action in
                        guard !isAutoTrigger else {
                            return .none
                        }
                        return .decryptWalletWithPassword(password)
                    }
                    .catch { .authenticateDidFail($0) }
           }
       )
   }

    private func authenticateWithTwoFactorOTP(
        _ code: String,
        _ state: WalletPairingState
    ) -> Effect<WalletPairingAction> {
       guard !state.walletGuid.isEmpty else {
           fatalError("GUID should not be empty")
       }
        return .publisher {
            loginService
                .login(
                    walletIdentifier: state.walletGuid,
                    code: code
                )
                .receive(on: mainQueue)
                .map { .twoFactorOTPDidVerified }
                .catch { .authenticateWithTwoFactorOTPDidFail($0) }
        }
    }

    private func needsEmailAuthorization() -> Effect<WalletPairingAction> {
        Effect.send(.startPolling)
    }

    private func pollWalletIdentifier(
        _ state: WalletPairingState
    ) -> Effect<WalletPairingAction> {
        .concatenate(
            .cancel(id: WalletPairingCancelations.WalletIdentifierPollingId()),
            .publisher {
                emailAuthorizationService
                    .authorizeEmailPublisher()
                    .receive(on: mainQueue)
                    .map { .authenticate(state.password) }
                    .catch { _ in .none }
            }
            .cancellable(id: WalletPairingCancelations.WalletIdentifierPollingId())
        )
    }

    private func resendSMSCode() -> Effect<WalletPairingAction> {
        .publisher {
            smsService
                .request()
                .receive(on: mainQueue)
                .map { .didResendSMSCode(.success(.noValue)) }
                .catch { .didResendSMSCode(.failure($0)) }
        }
    }

    private func setupSessionToken() -> Effect<WalletPairingAction> {
        .publisher {
            sessionTokenService
                .setupSessionToken()
                .receive(on: mainQueue)
                .map { .didSetupSessionToken(.success(.noValue)) }
                .catch { .didSetupSessionToken(.failure($0)) }
        }
    }

    private func startPolling() -> Effect<WalletPairingAction> {
        // Poll the Guid every 2 seconds
        Effect.run { send in
            for await _ in pollingQueue.timer(interval: .seconds(2)) {
                mainQueue.schedule {
                    do {
                        Task { @MainActor in
                            send(.pollWalletIdentifier)
                        }
                    }
                }
            }
        }
        .cancellable(id: WalletPairingCancelations.WalletIdentifierPollingTimerId())
    }
}
