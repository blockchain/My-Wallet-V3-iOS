// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Blockchain
import ComposableArchitecture
import ComposableNavigation
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
    case alert(PresentationAction<AlertAction>)
    case continueButtonTapped
    case didAppear(context: CredentialsContext)
    case onWillDisappear
    case didChangeWalletIdentifier(String)
    case walletPairing(WalletPairingAction)
    case password(PasswordAction)
    case twoFA(TwoFAAction)
    case seedPhrase(SeedPhraseAction)
    case secondPasswordNotice(SecondPasswordNoticeReducer.Action)
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
    @BindingState var supportSheetShown: Bool = false
    var walletPairingState: WalletPairingState
    var passwordState: PasswordState
    var twoFAState: TwoFAState?
    var seedPhraseState: SeedPhraseState?
    var secondPasswordNoticeState: SecondPasswordNoticeReducer.State?
    var customerSupportState: SupportViewState?
    var nabuInfo: WalletInfo.Nabu?
    var isManualPairing: Bool
    var isTwoFactorOTPVerified: Bool
    var isWalletIdentifierIncorrect: Bool
    var isAccountLocked: Bool
    @PresentationState var credentialsFailureAlert: AlertState<CredentialsAction.AlertAction>?
    var isLoading: Bool

    /// when the screen appears for the first time we would like to prepare for 2FA (if needed)
    /// however, we don't want to prepare twice when the screen is appeared again (e.g. swipe back)
    /// this flag is to decide whether the preparation is done already
    var isTwoFAPrepared: Bool

    var passwordFieldErrorMessage: String? {
        if isAccountLocked {
            return CredentialsLocalization.TextFieldError.accountLocked
        } else if passwordState.isPasswordIncorrect {
            return CredentialsLocalization.TextFieldError.incorrectPassword
        }
        return nil
    }

    init(
        route: RouteIntent<CredentialsRoute>? = nil,
        walletPairingState: WalletPairingState = .init(),
        passwordState: PasswordState = .init(),
        twoFAState: TwoFAState? = nil,
        seedPhraseState: SeedPhraseState? = nil,
        secondPasswordNoticeState: SecondPasswordNoticeReducer.State? = nil,
        customerSupportState: SupportViewState? = nil,
        nabuInfo: WalletInfo.Nabu? = nil,
        isManualPairing: Bool = false,
        isTwoFactorOTPVerified: Bool = false,
        isWalletIdentifierIncorrect: Bool = false,
        isAccountLocked: Bool = false,
        credentialsFailureAlert: AlertState<CredentialsAction.AlertAction>? = nil,
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

struct CredentialsReducer: Reducer {

    typealias State = CredentialsState
    typealias Action = CredentialsAction

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let pollingQueue: AnySchedulerOf<DispatchQueue>
    let sessionTokenService: SessionTokenServiceAPI
    let deviceVerificationService: DeviceVerificationServiceAPI
    let emailAuthorizationService: EmailAuthorizationServiceAPI
    let smsService: SMSServiceAPI
    let loginService: LoginServiceAPI
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let externalAppOpener: ExternalAppOpener
    let errorRecorder: ErrorRecording
    let walletIdentifierValidator: (String) -> Bool
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let accountRecoveryService: AccountRecoveryServiceAPI
    let recaptchaService: GoogleRecaptchaServiceAPI
    let seedPhraseValidator: SeedPhraseValidatorAPI
    let passwordValidator: PasswordValidatorAPI
    let signUpCountriesService: SignUpCountriesServiceAPI
    let app: AppProtocol
    let appStoreInformationRepository: AppStoreInformationRepositoryAPI

    init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        pollingQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue(
            label: "com.blockchain.CredentialsEnvironmentPollingQueue",
            qos: .utility
        ).eraseToAnyScheduler(),
        sessionTokenService: SessionTokenServiceAPI,
        deviceVerificationService: DeviceVerificationServiceAPI,
        emailAuthorizationService: EmailAuthorizationServiceAPI,
        smsService: SMSServiceAPI,
        loginService: LoginServiceAPI,
        errorRecorder: ErrorRecording,
        externalAppOpener: ExternalAppOpener,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        walletIdentifierValidator: @escaping (String) -> Bool = TextValidation.walletIdentifierValidator,
        walletRecoveryService: WalletRecoveryService,
        walletCreationService: WalletCreationService,
        walletFetcherService: WalletFetcherService,
        accountRecoveryService: AccountRecoveryServiceAPI,
        recaptchaService: GoogleRecaptchaServiceAPI,
        seedPhraseValidator: SeedPhraseValidatorAPI,
        passwordValidator: PasswordValidatorAPI,
        signUpCountriesService: SignUpCountriesServiceAPI,
        appStoreInformationRepository: AppStoreInformationRepositoryAPI
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
        self.analyticsRecorder = analyticsRecorder
        self.walletIdentifierValidator = walletIdentifierValidator
        self.walletRecoveryService = walletRecoveryService
        self.walletCreationService = walletCreationService
        self.walletFetcherService = walletFetcherService
        self.accountRecoveryService = accountRecoveryService
        self.recaptchaService = recaptchaService
        self.seedPhraseValidator = seedPhraseValidator
        self.passwordValidator = passwordValidator
        self.signUpCountriesService = signUpCountriesService
        self.app = app
        self.appStoreInformationRepository = appStoreInformationRepository
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Scope(state: \.passwordState, action: /Action.password) {
            PasswordReducer()
        }
        Reduce { state, action in
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

            case .alert(.presented(.show(let title, let message))):
                state.isLoading = false
                state.credentialsFailureAlert = AlertState(
                    title: TextState(verbatim: title),
                    message: TextState(verbatim: message),
                    dismissButton: .default(
                        TextState(LocalizationConstants.okString),
                        action: .send(.dismiss)
                    )
                )
                return .none

            case .alert(.dismiss), .alert(.presented(.dismiss)):
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
                    return Effect.send(
                        .walletPairing(
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
                return Effect.send(.walletPairing(.setupSessionToken))

            case .didAppear:
                return .none

            case .didChangeWalletIdentifier(let guid):
                state.walletPairingState.walletGuid = guid
                guard !guid.isEmpty else {
                    state.isWalletIdentifierIncorrect = false
                    return .none
                }
                state.isWalletIdentifierIncorrect = !walletIdentifierValidator(guid)
                return .none

            case .continueButtonTapped:
                if state.isTwoFactorOTPVerified {
                    return Effect.send(.walletPairing(.decryptWalletWithPassword(state.passwordState.password)))
                }
                if let twoFAState = state.twoFAState, twoFAState.isTwoFACodeFieldVisible {
                    return Effect.send(.walletPairing(.authenticateWithTwoFactorOTP(twoFAState.twoFACode)))
                }
                return Effect.send(.walletPairing(.authenticate(state.passwordState.password)))

            case .walletPairing(.authenticate):
                // Set loading state
                state.isLoading = true
                return .merge(
                    clearErrorStates(state),
                    Effect.send(.alert(.dismiss))
                )

            case .walletPairing(.authenticateDidFail(let error)):
                return authenticateDidFail(error, &state)

            case .walletPairing(.authenticateWithTwoFactorOTP):
                // Set loading state
                state.isLoading = true
                return .merge(
                    clearErrorStates(state),
                    Effect.send(.alert(.dismiss))
                )

            case .walletPairing(.authenticateWithTwoFactorOTPDidFail(let error)):
                return authenticateWithTwoFactorOTPDidFail(error)

            case .walletPairing(.decryptWalletWithPassword):
                // also handled in welcome reducer
                state.isLoading = true
                return .none

            case .walletPairing(.didResendSMSCode(let result)):
                return didResendSMSCode(result)

            case .walletPairing(.didSetupSessionToken(let result)):
                return didSetupSessionToken(result)

            case .walletPairing(.handleSMS):
                return handleSMS()

            case .walletPairing(.needsEmailAuthorization):
                // display authorization required alert
                return needsEmailAuthorization()

            case .walletPairing(.twoFactorOTPDidVerified):
                state.isTwoFactorOTPVerified = true
                state.isLoading = false
                let password = state.passwordState.password
                return Effect.send(.walletPairing(.decryptWalletWithPassword(password)))

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
                externalAppOpener.open(url)
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
                return Effect.send(.openExternalLink(url))

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
        .ifLet(\.twoFAState, action: /Action.twoFA) {
            TwoFAReducer()
        }
        .ifLet(\.seedPhraseState, action: /Action.seedPhrase) {
            SeedPhraseReducer(
                mainQueue: mainQueue,
                externalAppOpener: externalAppOpener,
                analyticsRecorder: analyticsRecorder,
                walletRecoveryService: walletRecoveryService,
                walletCreationService: walletCreationService,
                walletFetcherService: walletFetcherService,
                accountRecoveryService: accountRecoveryService,
                errorRecorder: errorRecorder,
                recaptchaService: recaptchaService,
                validator: seedPhraseValidator,
                passwordValidator: passwordValidator,
                signUpCountriesService: signUpCountriesService,
                app: app
            )
        }
        .ifLet(\.secondPasswordNoticeState, action: /Action.secondPasswordNotice) {
            SecondPasswordNoticeReducer(
                externalAppOpener: externalAppOpener
            )
        }
        .ifLet(\.customerSupportState, action: /Action.customerSupport) {
            SupportViewReducer(
                appStoreInformationRepository: appStoreInformationRepository,
                analyticsRecorder: analyticsRecorder,
                externalAppOpener: externalAppOpener
            )
        }
        .routing()
        Scope(state: \.walletPairingState, action: /Action.walletPairing) {
            WalletPairingReducer(
                mainQueue: mainQueue,
                pollingQueue: pollingQueue,
                sessionTokenService: sessionTokenService,
                deviceVerificationService: deviceVerificationService,
                emailAuthorizationService: emailAuthorizationService,
                smsService: smsService,
                loginService: loginService,
                errorRecorder: errorRecorder
            )
        }
        CredentialsAnalytics(analyticsRecorder: analyticsRecorder)
    }
}

// MARK: - Private Methods

extension CredentialsReducer {
    private func clearErrorStates(
        _ state: CredentialsState
    ) -> Effect<CredentialsAction> {
        var effects: [Effect<CredentialsAction>] = [
            Effect.send(.showAccountLockedError(false)),
            Effect.send(.password(.showIncorrectPasswordError(false)))
        ]
        if state.twoFAState != nil {
            effects.append(Effect.send(.twoFA(.showIncorrectTwoFACodeError(.none))))
        }
        return .merge(effects)
    }

    private func authenticateDidFail(
        _ error: LoginServiceError,
        _ state: inout CredentialsState
    ) -> Effect<CredentialsAction> {
        let isManualPairing = state.isManualPairing
        switch error {
        case .twoFactorOTPRequired(let type):
            switch type {
            case .email:
                switch isManualPairing {
                case true:
                    return Effect.send(.walletPairing(.needsEmailAuthorization))
                case false:
                    return Effect.send(.walletPairing(.approveEmailAuthorization))
                }
            case .sms:
                state.twoFAState = .init(
                    twoFAType: .sms
                )
                return Effect.send(.walletPairing(.handleSMS))
            case .google, .yubiKey, .yubikeyMtGox:
                state.twoFAState = .init(
                    twoFAType: type
                )
                return Effect.send(.twoFA(.showTwoFACodeField(true)))
            default:
                fatalError("Unsupported TwoFA Types")
            }
        case .walletPayloadServiceError(.accountLocked):
            return Effect.send(.showAccountLockedError(true))
        case .walletPayloadServiceError(let error):
            errorRecorder.error(error)
            return Effect.send(
                .alert(
                    .presented(
                        .show(
                            title: CredentialsLocalization.Alerts.GenericNetworkError.title,
                            message: CredentialsLocalization.Alerts.GenericNetworkError.message
                        )
                    )
                )
            )
        case .twoFAWalletServiceError:
            fatalError("Shouldn't receive TwoFAService errors here")
        }
    }

    private func authenticateWithTwoFactorOTPDidFail(
        _ error: LoginServiceError
    ) -> Effect<CredentialsAction> {
        switch error {
        case .twoFAWalletServiceError(let error):
            switch error {
            case .wrongCode(let attemptsLeft):
                Effect.send(.twoFA(.didChangeTwoFACodeAttemptsLeft(attemptsLeft)))
            case .accountLocked:
                Effect.send(.showAccountLockedError(true))
            case .missingCode:
                Effect.send(.twoFA(.showIncorrectTwoFACodeError(.missingCode)))
            case .missingPayload, .missingCredentials, .networkError:
                Effect.send(
                    .alert(
                        .presented(
                            .show(
                                title: CredentialsLocalization.Alerts.GenericNetworkError.title,
                                message: CredentialsLocalization.Alerts.GenericNetworkError.message
                            )
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
        _ result: Result<EmptyValue, SMSServiceError>
    ) -> Effect<CredentialsAction> {
        switch result {
        case .success:
            return Effect.send(
                .alert(
                    .presented(
                        .show(
                            title: CredentialsLocalization.Alerts.SMSCode.Success.title,
                            message: CredentialsLocalization.Alerts.SMSCode.Success.message
                        )
                    )
                )
            )
        case .failure(let error):
            errorRecorder.error(error)
            return Effect.send(
                .alert(
                    .presented(
                        .show(
                            title: CredentialsLocalization.Alerts.SMSCode.Failure.title,
                            message: CredentialsLocalization.Alerts.SMSCode.Failure.message
                        )
                    )
                )
            )
        }
    }

    private func didSetupSessionToken(
        _ result: Result<EmptyValue, SessionTokenServiceError>
    ) -> Effect<CredentialsAction> {
        switch result {
        case .success:
            return .none
        case .failure(let error):
            errorRecorder.error(error)
            return Effect.send(
                .alert(
                    .presented(
                        .show(
                            title: CredentialsLocalization.Alerts.GenericNetworkError.title,
                            message: CredentialsLocalization.Alerts.GenericNetworkError.message
                        )
                    )
                )
            )
        }
    }

    private func handleSMS() -> Effect<CredentialsAction> {
        .merge(
            Effect.send(.twoFA(.showResendSMSButton(true))),
            Effect.send(.twoFA(.showTwoFACodeField(true))),
            Effect.send(
                .alert(
                    .presented(
                        .show(
                            title: CredentialsLocalization.Alerts.SMSCode.Success.title,
                            message: CredentialsLocalization.Alerts.SMSCode.Success.message
                        )
                    )
                )
            )
        )
    }

    private func needsEmailAuthorization() -> Effect<CredentialsAction> {
        Effect.send(
            .alert(
                .presented(
                    .show(
                        title: CredentialsLocalization.Alerts.EmailAuthorizationAlert.title,
                        message: CredentialsLocalization.Alerts.EmailAuthorizationAlert.message
                    )
                )
            )
        )
    }
}

// MARK: - Extension

struct CredentialsAnalytics: Reducer {

    typealias Action = CredentialsAction
    typealias State = CredentialsState

    let analyticsRecorder: AnalyticsEventRecorderAPI

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .continueButtonTapped:
                analyticsRecorder.record(
                    event: .loginPasswordEntered
                )
                return .none
            case .walletPairing(.authenticateWithTwoFactorOTP):
                analyticsRecorder.record(
                    event: .loginTwoStepVerificationEntered
                )
                return .none
            case .twoFA(.didChangeTwoFACodeAttemptsLeft):
                analyticsRecorder.record(
                    event: .loginTwoStepVerificationDenied
                )
                return .none
            case .route(let route):
                if let routeValue = route?.route {
                    switch routeValue {
                    case .seedPhrase:
                        analyticsRecorder.record(
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
    }
}
