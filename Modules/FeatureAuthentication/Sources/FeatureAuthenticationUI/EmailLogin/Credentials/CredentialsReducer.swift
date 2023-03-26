// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import ComposableNavigation
import DIKit
import FeatureAuthenticationDomain
import Localization
import ToolKit

// MARK: - Type

public enum CredentialsAction: Equatable, NavigationAction, BindableAction {
    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    case binding(BindingAction<CredentialsState>)
    case route(RouteIntent<CredentialsRoute>?)
    case alert(AlertAction)
    case continueButtonTapped
    case didAppear(context: CredentialsContext)
    case onWillDisappear
    case didChangeWalletIdentifier(String)
    case walletPairing(WalletPairingAction)
    case password(PasswordAction)
    case twoFA(TwoFAAction)
    case seedPhrase(SeedPhraseAction)
    case secondPasswordNotice(SecondPasswordNotice.Action)
    case customerSupport(SupportViewAction)
    case showAccountLockedError(Bool)
    case openExternalLink(URL)
    case onForgotPasswordTapped
    case none
}

public enum CredentialsContext: Equatable {
    case walletInfo(WalletInfo)
    /// pre-fill guid if present (from the deeplink)
    case walletIdentifier(guid: String?)
    case manualPairing
    case none
}

private typealias CredentialsLocalization = LocalizationConstants.FeatureAuthentication.EmailLogin

// MARK: - Properties

public struct CredentialsState: Equatable, NavigationState {
    public var route: RouteIntent<CredentialsRoute>?
    @BindableState var supportSheetShown: Bool = false
    var walletPairingState: WalletPairingState
    var passwordState: PasswordState
    var twoFAState: TwoFAState?
    var seedPhraseState: SeedPhraseState?
    var secondPasswordNoticeState: SecondPasswordNotice.State?
    var customerSupportState: SupportViewState?
    var nabuInfo: WalletInfo.Nabu?
    var isManualPairing: Bool
    var isTwoFactorOTPVerified: Bool
    var isWalletIdentifierIncorrect: Bool
    var isAccountLocked: Bool
    var credentialsFailureAlert: AlertState<CredentialsAction>?
    var isLoading: Bool

    /// when the screen appears for the first time we would like to prepare for 2FA (if needed)
    /// however, we don't want to prepare twice when the screen is appeared again (e.g. swipe back)
    /// this flag is to decide whether the preparation is done already
    var isTwoFAPrepared: Bool

    init(
        route: RouteIntent<CredentialsRoute>? = nil,
        walletPairingState: WalletPairingState = .init(),
        passwordState: PasswordState = .init(),
        twoFAState: TwoFAState? = nil,
        seedPhraseState: SeedPhraseState? = nil,
        secondPasswordNoticeState: SecondPasswordNotice.State? = nil,
        customerSupportState: SupportViewState? = nil,
        nabuInfo: WalletInfo.Nabu? = nil,
        isManualPairing: Bool = false,
        isTwoFactorOTPVerified: Bool = false,
        isWalletIdentifierIncorrect: Bool = false,
        isAccountLocked: Bool = false,
        credentialsFailureAlert: AlertState<CredentialsAction>? = nil,
        isLoading: Bool = false,
        isTwoFAPrepared: Bool = false
    ) {
        self.route = route
        self.walletPairingState = walletPairingState
        self.passwordState = passwordState
        self.twoFAState = twoFAState
        self.seedPhraseState = seedPhraseState
        self.secondPasswordNoticeState = secondPasswordNoticeState
        self.customerSupportState = customerSupportState
        self.nabuInfo = nabuInfo
        self.isManualPairing = isManualPairing
        self.isTwoFactorOTPVerified = isTwoFactorOTPVerified
        self.isWalletIdentifierIncorrect = isWalletIdentifierIncorrect
        self.isAccountLocked = isAccountLocked
        self.credentialsFailureAlert = credentialsFailureAlert
        self.isLoading = isLoading
        self.isTwoFAPrepared = isTwoFAPrepared
    }
}

struct CredentialsEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let pollingQueue: AnySchedulerOf<DispatchQueue>
    let sessionTokenService: SessionTokenServiceAPI
    let deviceVerificationService: DeviceVerificationServiceAPI
    let emailAuthorizationService: EmailAuthorizationServiceAPI
    let smsService: SMSServiceAPI
    let loginService: LoginServiceAPI
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let externalAppOpener: ExternalAppOpener
    let featureFlagsService: FeatureFlagsServiceAPI
    let errorRecorder: ErrorRecording
    let walletIdentifierValidator: (String) -> Bool
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let accountRecoveryService: AccountRecoveryServiceAPI
    let recaptchaService: GoogleRecaptchaServiceAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        pollingQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue(
            label: "com.blockchain.CredentialsEnvironmentPollingQueue",
            qos: .utility
        ).eraseToAnyScheduler(),
        sessionTokenService: SessionTokenServiceAPI = resolve(),
        deviceVerificationService: DeviceVerificationServiceAPI,
        emailAuthorizationService: EmailAuthorizationServiceAPI = resolve(),
        smsService: SMSServiceAPI = resolve(),
        loginService: LoginServiceAPI = resolve(),
        errorRecorder: ErrorRecording,
        externalAppOpener: ExternalAppOpener = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        walletIdentifierValidator: @escaping (String) -> Bool = TextValidation.walletIdentifierValidator,
        walletRecoveryService: WalletRecoveryService,
        walletCreationService: WalletCreationService,
        walletFetcherService: WalletFetcherService,
        accountRecoveryService: AccountRecoveryServiceAPI,
        recaptchaService: GoogleRecaptchaServiceAPI
    ) {
        self.mainQueue = mainQueue
        self.pollingQueue = pollingQueue
        self.sessionTokenService = sessionTokenService
        self.deviceVerificationService = deviceVerificationService
        self.emailAuthorizationService = emailAuthorizationService
        self.smsService = smsService
        self.loginService = loginService
        self.errorRecorder = errorRecorder
        self.externalAppOpener = externalAppOpener
        self.featureFlagsService = featureFlagsService
        self.analyticsRecorder = analyticsRecorder
        self.walletIdentifierValidator = walletIdentifierValidator
        self.walletRecoveryService = walletRecoveryService
        self.walletCreationService = walletCreationService
        self.walletFetcherService = walletFetcherService
        self.accountRecoveryService = accountRecoveryService
        self.recaptchaService = recaptchaService
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
    walletPairingReducer
        .pullback(
            state: \CredentialsState.walletPairingState,
            action: /CredentialsAction.walletPairing,
            environment: {
                WalletPairingEnvironment(
                    mainQueue: $0.mainQueue,
                    pollingQueue: $0.pollingQueue,
                    sessionTokenService: $0.sessionTokenService,
                    deviceVerificationService: $0.deviceVerificationService,
                    emailAuthorizationService: $0.emailAuthorizationService,
                    smsService: $0.smsService,
                    loginService: $0.loginService,
                    errorRecorder: $0.errorRecorder
                )
            }
        ),
    seedPhraseReducer
        .optional()
        .pullback(
            state: \CredentialsState.seedPhraseState,
            action: /CredentialsAction.seedPhrase,
            environment: {
                SeedPhraseEnvironment(
                    mainQueue: $0.mainQueue,
                    externalAppOpener: $0.externalAppOpener,
                    analyticsRecorder: $0.analyticsRecorder,
                    walletRecoveryService: $0.walletRecoveryService,
                    walletCreationService: $0.walletCreationService,
                    walletFetcherService: $0.walletFetcherService,
                    accountRecoveryService: $0.accountRecoveryService,
                    errorRecorder: $0.errorRecorder,
                    recaptchaService: $0.recaptchaService
                )
            }
        ),
    secondPasswordNoticeReducer
        .optional()
        .pullback(
            state: \CredentialsState.secondPasswordNoticeState,
            action: /CredentialsAction.secondPasswordNotice,
            environment: {
                SecondPasswordNotice.Environment(
                    externalAppOpener: $0.externalAppOpener
                )
            }
        ),
    supportViewReducer
        .optional()
        .pullback(
            state: \CredentialsState.customerSupportState,
            action: /CredentialsAction.customerSupport,
            environment: { _ in
                SupportViewEnvironment.default
            }
        ),
    Reducer<
        CredentialsState,
        CredentialsAction,
        CredentialsEnvironment
    > { state, action, environment in
        switch action {
        case .binding(\.$supportSheetShown):
            if state.supportSheetShown {
                state.customerSupportState = .init(
                    applicationVersion: Bundle.applicationVersion ?? "",
                    bundleIdentifier: Bundle.main.bundleIdentifier ?? ""
                )
            }
            return .none

        case .binding:
            return .none

        case .alert(.show(let title, let message)):
            state.isLoading = false
            state.credentialsFailureAlert = AlertState(
                title: TextState(verbatim: title),
                message: TextState(verbatim: message),
                dismissButton: .default(
                    TextState(LocalizationConstants.okString),
                    action: .send(.alert(.dismiss))
                )
            )
            return .none

        case .alert(.dismiss):
            state.credentialsFailureAlert = nil
            return .none

        case .onWillDisappear:
            return .cancel(id: WalletPairingCancelations.WalletIdentifierPollingTimerId())

        case .didAppear(.walletInfo(let info)):
            state.walletPairingState.emailAddress = info.wallet?.email ?? ""
            state.walletPairingState.emailCode = info.wallet?.emailCode
            state.walletPairingState.walletGuid = info.wallet?.guid ?? ""
            if let nabuInfo = info.wallet?.nabu {
                state.nabuInfo = nabuInfo
            }
            if !state.isTwoFAPrepared, let type = info.wallet?.twoFaType, type.isTwoFactor {
                // if we want to send SMS when the view appears we would need to trigger approve authorization and sms error in order to send SMS when appeared
                // also, if we want to show 2FA field when view appears, we need to do the above
                state.isTwoFAPrepared = true
                return Effect(
                    value: .walletPairing(
                        .authenticate(
                            state.passwordState.password,
                            autoTrigger: true
                        )
                    )
                )
            }
            return .none

        case .didAppear(.walletIdentifier(let guid)):
            state.walletPairingState.walletGuid = guid ?? ""
            return .none

        case .didAppear(.manualPairing):
            state.isManualPairing = true
            return Effect(value: .walletPairing(.setupSessionToken))

        case .didAppear:
            return .none

        case .didChangeWalletIdentifier(let guid):
            state.walletPairingState.walletGuid = guid
            guard !guid.isEmpty else {
                state.isWalletIdentifierIncorrect = false
                return .none
            }
            state.isWalletIdentifierIncorrect = !environment.walletIdentifierValidator(guid)
            return .none

        case .continueButtonTapped:
            if state.isTwoFactorOTPVerified {
                return Effect(value: .walletPairing(.decryptWalletWithPassword(state.passwordState.password)))
            }
            if let twoFAState = state.twoFAState, twoFAState.isTwoFACodeFieldVisible {
                return Effect(value: .walletPairing(.authenticateWithTwoFactorOTP(twoFAState.twoFACode)))
            }
            return Effect(value: .walletPairing(.authenticate(state.passwordState.password)))

        case .walletPairing(.authenticate):
            // Set loading state
            state.isLoading = true
            return .merge(
                clearErrorStates(state),
                Effect(value: .alert(.dismiss))
            )

        case .walletPairing(.authenticateDidFail(let error)):
            return authenticateDidFail(error, &state, environment)

        case .walletPairing(.authenticateWithTwoFactorOTP):
            // Set loading state
            state.isLoading = true
            return .merge(
                clearErrorStates(state),
                Effect(value: .alert(.dismiss))
            )

        case .walletPairing(.authenticateWithTwoFactorOTPDidFail(let error)):
            return authenticateWithTwoFactorOTPDidFail(error, environment)

        case .walletPairing(.decryptWalletWithPassword):
            // also handled in welcome reducer
            state.isLoading = true
            return .none

        case .walletPairing(.didResendSMSCode(let result)):
            return didResendSMSCode(result, environment)

        case .walletPairing(.didSetupSessionToken(let result)):
            return didSetupSessionToken(result, environment)

        case .walletPairing(.handleSMS):
            return handleSMS()

        case .walletPairing(.needsEmailAuthorization):
            // display authorization required alert
            return needsEmailAuthorization()

        case .walletPairing(.twoFactorOTPDidVerified):
            state.isTwoFactorOTPVerified = true
            state.isLoading = false
            let password = state.passwordState.password
            return Effect(value: .walletPairing(.decryptWalletWithPassword(password)))

        case .walletPairing(.approveEmailAuthorization),
             .walletPairing(.pollWalletIdentifier),
             .walletPairing(.resendSMSCode),
             .walletPairing(.setupSessionToken),
             .walletPairing(.startPolling),
             .walletPairing(.none):
            // handled in wallet pairing reducer
            return .none

        case .showAccountLockedError(let shouldShow):
            state.isAccountLocked = shouldShow
            state.isLoading = shouldShow ? false : state.isLoading
            return .none

        case .openExternalLink(let url):
            environment.externalAppOpener.open(url)
            return .none

        case .twoFA(.showTwoFACodeField(let visible)):
            state.isLoading = visible ? false : state.isLoading
            return .none

        case .twoFA(.showIncorrectTwoFACodeError(let context)):
            state.isLoading = context.hasError ? false : state.isLoading
            return .none

        case .password(.showIncorrectPasswordError(true)):
            state.isLoading = false
            // reset state
            state.twoFAState = .init()
            return .none

        case .password(.showIncorrectPasswordError(false)):
            state.isLoading = true
            return .none

        case .onForgotPasswordTapped:
            guard let url = URL(string: Constants.HostURL.recoverPassword) else {
                return .none
            }
            return Effect(value: .openExternalLink(url))

        case .route(let route):
            if let routeValue = route?.route {
                switch routeValue {
                case .seedPhrase:
                    state.seedPhraseState = .init(
                        context: .troubleLoggingIn,
                        emailAddress: state.walletPairingState.emailAddress,
                        nabuInfo: state.nabuInfo
                    )
                case .secondPasswordDetected:
                    state.secondPasswordNoticeState = .init()
                }
            }
            return .none

        case .twoFA,
             .password,
             .seedPhrase,
             .secondPasswordNotice,
             .customerSupport,
             .none:
            return .none
        }
    }
)
.binding()
.routing()
.analytics()

// MARK: - Private Methods

private func clearErrorStates(
    _ state: CredentialsState
) -> Effect<CredentialsAction, Never> {
    var effects: [Effect<CredentialsAction, Never>] = [
        Effect(value: .showAccountLockedError(false)),
        Effect(value: .password(.showIncorrectPasswordError(false)))
    ]
    if state.twoFAState != nil {
        effects.append(Effect(value: .twoFA(.showIncorrectTwoFACodeError(.none))))
    }
    return .merge(effects)
}

private func authenticateDidFail(
    _ error: LoginServiceError,
    _ state: inout CredentialsState,
    _ environment: CredentialsEnvironment
) -> Effect<CredentialsAction, Never> {
    let isManualPairing = state.isManualPairing
    switch error {
    case .twoFactorOTPRequired(let type):
        switch type {
        case .email:
            switch isManualPairing {
            case true:
                return Effect(value: .walletPairing(.needsEmailAuthorization))
            case false:
                return Effect(value: .walletPairing(.approveEmailAuthorization))
            }
        case .sms:
            state.twoFAState = .init(
                twoFAType: .sms
            )
            return Effect(value: .walletPairing(.handleSMS))
        case .google, .yubiKey, .yubikeyMtGox:
            state.twoFAState = .init(
                twoFAType: type
            )
            return Effect(value: .twoFA(.showTwoFACodeField(true)))
        default:
            fatalError("Unsupported TwoFA Types")
        }
    case .walletPayloadServiceError(.accountLocked):
        return Effect(value: .showAccountLockedError(true))
    case .walletPayloadServiceError(let error):
        environment.errorRecorder.error(error)
        return Effect(
            value: .alert(
                .show(
                    title: CredentialsLocalization.Alerts.GenericNetworkError.title,
                    message: CredentialsLocalization.Alerts.GenericNetworkError.message
                )
            )
        )
    case .twoFAWalletServiceError:
        fatalError("Shouldn't receive TwoFAService errors here")
    }
}

private func authenticateWithTwoFactorOTPDidFail(
    _ error: LoginServiceError,
    _ environment: CredentialsEnvironment
) -> Effect<CredentialsAction, Never> {
    switch error {
    case .twoFAWalletServiceError(let error):
        switch error {
        case .wrongCode(let attemptsLeft):
            return Effect(value: .twoFA(.didChangeTwoFACodeAttemptsLeft(attemptsLeft)))
        case .accountLocked:
            return Effect(value: .showAccountLockedError(true))
        case .missingCode:
            return Effect(value: .twoFA(.showIncorrectTwoFACodeError(.missingCode)))
        case .missingPayload, .missingCredentials, .networkError:
            return Effect(
                value:
                .alert(
                    .show(
                        title: CredentialsLocalization.Alerts.GenericNetworkError.title,
                        message: CredentialsLocalization.Alerts.GenericNetworkError.message
                    )
                )
            )
        }
    case .walletPayloadServiceError:
        fatalError("Shouldn't receive WalletPayloadService errors here")
    case .twoFactorOTPRequired:
        fatalError("Shouldn't receive twoFactorOTPRequired error here")
    }
}

private func didResendSMSCode(
    _ result: Result<EmptyValue, SMSServiceError>,
    _ environment: CredentialsEnvironment
) -> Effect<CredentialsAction, Never> {
    switch result {
    case .success:
        return Effect(
            value: .alert(
                .show(
                    title: CredentialsLocalization.Alerts.SMSCode.Success.title,
                    message: CredentialsLocalization.Alerts.SMSCode.Success.message
                )
            )
        )
    case .failure(let error):
        environment.errorRecorder.error(error)
        return Effect(
            value: .alert(
                .show(
                    title: CredentialsLocalization.Alerts.SMSCode.Failure.title,
                    message: CredentialsLocalization.Alerts.SMSCode.Failure.message
                )
            )
        )
    }
}

private func didSetupSessionToken(
    _ result: Result<EmptyValue, SessionTokenServiceError>,
    _ environment: CredentialsEnvironment
) -> Effect<CredentialsAction, Never> {
    switch result {
    case .success:
        return .none
    case .failure(let error):
        environment.errorRecorder.error(error)
        return Effect(
            value: .alert(
                .show(
                    title: CredentialsLocalization.Alerts.GenericNetworkError.title,
                    message: CredentialsLocalization.Alerts.GenericNetworkError.message
                )
            )
        )
    }
}

private func handleSMS() -> Effect<CredentialsAction, Never> {
    .merge(
        Effect(value: .twoFA(.showResendSMSButton(true))),
        Effect(value: .twoFA(.showTwoFACodeField(true))),
        Effect(
            value: .alert(
                .show(
                    title: CredentialsLocalization.Alerts.SMSCode.Success.title,
                    message: CredentialsLocalization.Alerts.SMSCode.Success.message
                )
            )
        )
    )
}

private func needsEmailAuthorization() -> Effect<CredentialsAction, Never> {
    Effect(
        value: .alert(
            .show(
                title: CredentialsLocalization.Alerts.EmailAuthorizationAlert.title,
                message: CredentialsLocalization.Alerts.EmailAuthorizationAlert.message
            )
        )
    )
}

// MARK: - Extension

extension Reducer where
    Action == CredentialsAction,
    State == CredentialsState,
    Environment == CredentialsEnvironment
{
    /// Helper reducer for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                CredentialsState,
                CredentialsAction,
                CredentialsEnvironment
            > { _, action, environment in
                switch action {
                case .continueButtonTapped:
                    environment.analyticsRecorder.record(
                        event: .loginPasswordEntered
                    )
                    return .none
                case .walletPairing(.authenticateWithTwoFactorOTP):
                    environment.analyticsRecorder.record(
                        event: .loginTwoStepVerificationEntered
                    )
                    return .none
                case .twoFA(.didChangeTwoFACodeAttemptsLeft):
                    environment.analyticsRecorder.record(
                        event: .loginTwoStepVerificationDenied
                    )
                    return .none
                case .route(let route):
                    if let routeValue = route?.route {
                        switch routeValue {
                        case .seedPhrase:
                            environment.analyticsRecorder.record(
                                event: .recoveryOptionSelected
                            )
                        default:
                            break
                        }
                    }
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
