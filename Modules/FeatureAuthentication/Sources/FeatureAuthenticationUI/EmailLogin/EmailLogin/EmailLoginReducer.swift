// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import ComposableArchitecture
import ComposableNavigation
import FeatureAuthenticationDomain
import Localization
import ToolKit

// MARK: - Type

public enum EmailLoginAction: Equatable, NavigationAction {

    // MARK: - Alert

    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    case alert(AlertAction)

    // MARK: - Transitions and Navigations

    case onAppear
    case route(RouteIntent<EmailLoginRoute>?)
    case continueButtonTapped

    // MARK: - Email

    case didChangeEmailAddress(String)

    // MARK: - Device Verification

    case sendDeviceVerificationEmail
    case didSendDeviceVerificationEmail(Result<EmptyValue, DeviceVerificationServiceError>)
    case setupSessionToken
    case setupSessionTokenReceived(Result<EmptyValue, SessionTokenServiceError>)

    // MARK: - Local Actions

    case verifyDevice(VerifyDeviceAction)

    // MARK: - Utils

    case none
}

private typealias EmailLoginLocalization = LocalizationConstants.FeatureAuthentication.EmailLogin

// MARK: - Properties

public struct EmailLoginState: Equatable, NavigationState {

    // MARK: - Navigation State

    public var route: RouteIntent<EmailLoginRoute>?

    // MARK: - Local States

    public var verifyDeviceState: VerifyDeviceState?

    // MARK: - Alert State

    var alert: AlertState<EmailLoginAction>?

    // MARK: - Email

    var emailAddress: String
    var isEmailValid: Bool

    // MARK: - Loading State

    var isLoading: Bool

    init() {
        self.route = nil
        self.emailAddress = ""
        self.isEmailValid = false
        self.isLoading = false
        self.verifyDeviceState = nil
    }
}

struct EmailLoginReducer: ReducerProtocol {

    typealias State = EmailLoginState
    typealias Action = EmailLoginAction

    let app: AppProtocol
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let sessionTokenService: SessionTokenServiceAPI
    let deviceVerificationService: DeviceVerificationServiceAPI
    let errorRecorder: ErrorRecording
    let externalAppOpener: ExternalAppOpener
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let accountRecoveryService: AccountRecoveryServiceAPI
    let recaptchaService: GoogleRecaptchaServiceAPI
    let validateEmail: (String) -> Bool
    let emailAuthorizationService: EmailAuthorizationServiceAPI
    let smsService: SMSServiceAPI
    let loginService: LoginServiceAPI
    let seedPhraseValidator: SeedPhraseValidatorAPI
    let passwordValidator: PasswordValidatorAPI
    let signUpCountriesService: SignUpCountriesServiceAPI
    let appStoreInformationRepository: AppStoreInformationRepositoryAPI

    init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        sessionTokenService: SessionTokenServiceAPI,
        deviceVerificationService: DeviceVerificationServiceAPI,
        errorRecorder: ErrorRecording,
        externalAppOpener: ExternalAppOpener,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        walletRecoveryService: WalletRecoveryService,
        walletCreationService: WalletCreationService,
        walletFetcherService: WalletFetcherService,
        accountRecoveryService: AccountRecoveryServiceAPI,
        recaptchaService: GoogleRecaptchaServiceAPI,
        emailAuthorizationService: EmailAuthorizationServiceAPI,
        smsService: SMSServiceAPI,
        loginService: LoginServiceAPI,
        seedPhraseValidator: SeedPhraseValidatorAPI,
        passwordValidator: PasswordValidatorAPI,
        signUpCountriesService: SignUpCountriesServiceAPI,
        appStoreInformationRepository: AppStoreInformationRepositoryAPI,
        validateEmail: @escaping (String) -> Bool = { $0.isEmail }
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.sessionTokenService = sessionTokenService
        self.deviceVerificationService = deviceVerificationService
        self.errorRecorder = errorRecorder
        self.externalAppOpener = externalAppOpener
        self.analyticsRecorder = analyticsRecorder
        self.walletRecoveryService = walletRecoveryService
        self.walletCreationService = walletCreationService
        self.walletFetcherService = walletFetcherService
        self.accountRecoveryService = accountRecoveryService
        self.recaptchaService = recaptchaService
        self.validateEmail = validateEmail
        self.emailAuthorizationService = emailAuthorizationService
        self.smsService = smsService
        self.loginService = loginService
        self.seedPhraseValidator = seedPhraseValidator
        self.passwordValidator = passwordValidator
        self.signUpCountriesService = signUpCountriesService
        self.appStoreInformationRepository = appStoreInformationRepository
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {

            // MARK: - Alert

            case .alert(.show(let title, let message)):
                state.alert = AlertState(
                    title: TextState(verbatim: title),
                    message: TextState(verbatim: message),
                    dismissButton: .default(
                        TextState(LocalizationConstants.continueString),
                        action: .send(.alert(.dismiss))
                    )
                )
                return .none

            case .alert(.dismiss):
                state.alert = nil
                return .none

            // MARK: - Transitions and Navigations

            case .onAppear:
                return .fireAndForget {
                    analyticsRecorder.record(
                        event: .loginViewed
                    )
                    app.post(event: blockchain.ux.user.authentication.sign.in)
                }

            case .route(let route):
                if let routeValue = route?.route {
                    state.verifyDeviceState = .init(emailAddress: state.emailAddress)
                    state.route = route
                    return .none
                } else {
                    state.verifyDeviceState = nil
                    state.route = route
                    return .none
                }

            case .continueButtonTapped:
                state.isLoading = true
                return .merge(
                    EffectTask(value: .setupSessionToken),
                    .fireAndForget {
                        app.post(event: blockchain.ux.user.authentication.sign.in.continue.tap)
                    }
                )

            // MARK: - Email

            case .didChangeEmailAddress(let emailAddress):
                state.emailAddress = emailAddress
                state.isEmailValid = validateEmail(emailAddress)
                return .none

            // MARK: - Device Verification

            case .sendDeviceVerificationEmail,
                 .verifyDevice(.sendDeviceVerificationEmail):
                guard state.isEmailValid else {
                    state.isLoading = false
                    return .none
                }
                state.isLoading = true
                state.verifyDeviceState?.sendEmailButtonIsLoading = true
                return deviceVerificationService
                    .sendDeviceVerificationEmail(to: state.emailAddress)
                    .receive(on: mainQueue)
                    .catchToEffect()
                    .map { result -> EmailLoginAction in
                        switch result {
                        case .success:
                            return .didSendDeviceVerificationEmail(.success(.noValue))
                        case .failure(let error):
                            return .didSendDeviceVerificationEmail(.failure(error))
                        }
                    }

            case .didSendDeviceVerificationEmail(let response):
                state.isLoading = false
                state.verifyDeviceState?.sendEmailButtonIsLoading = false
                if case .failure(let error) = response {
                    switch error {
                    case .recaptchaError,
                         .missingSessionToken:
                        return EffectTask(
                            value: .alert(
                                .show(
                                    title: EmailLoginLocalization.Alerts.SignInError.title,
                                    message: EmailLoginLocalization.Alerts.SignInError.message
                                )
                            )
                        )
                    case .networkError, .timeout:
                        // still go to verify device screen if there is network error
                        break
                    case .expiredEmailCode, .missingWalletInfo:
                        // not errors related to send verification email
                        break
                    }
                }
                return EffectTask(value: .navigate(to: .verifyDevice))

            case .setupSessionToken:
                return sessionTokenService
                    .setupSessionToken()
                    .map { _ in EmptyValue.noValue }
                    .receive(on: mainQueue)
                    .catchToEffect()
                    .map(EmailLoginAction.setupSessionTokenReceived)

            case .setupSessionTokenReceived(.success):
                return EffectTask(value: .sendDeviceVerificationEmail)

            case .setupSessionTokenReceived(.failure(let error)):
                state.isLoading = false
                errorRecorder.error(error)
                return EffectTask(
                    value:
                    .alert(
                        .show(
                            title: EmailLoginLocalization.Alerts.GenericNetworkError.title,
                            message: EmailLoginLocalization.Alerts.GenericNetworkError.message
                        )
                    )
                )

            // MARK: - Local Reducers

            case .verifyDevice(.deviceRejected):
                return .dismiss()

            case .verifyDevice:
                // handled in verify device reducer
                return .none

            // MARK: - Utils

            case .none:
                return .none
            }
        }
        .ifLet(\.verifyDeviceState, action: /Action.verifyDevice) {
            VerifyDeviceReducer(
                app: app,
                mainQueue: mainQueue,
                deviceVerificationService: deviceVerificationService,
                errorRecorder: errorRecorder,
                externalAppOpener: externalAppOpener,
                analyticsRecorder: analyticsRecorder,
                walletRecoveryService: walletRecoveryService,
                walletCreationService: walletCreationService,
                walletFetcherService: walletFetcherService,
                accountRecoveryService: accountRecoveryService,
                recaptchaService: recaptchaService,
                sessionTokenService: sessionTokenService,
                emailAuthorizationService: emailAuthorizationService,
                smsService: smsService,
                loginService: loginService,
                seedPhraseValidator: seedPhraseValidator,
                passwordValidator: passwordValidator,
                signUpCountriesService: signUpCountriesService,
                appStoreInformationRepository: appStoreInformationRepository
            )
        }
        EmailLoginAnalytics(analyticsRecorder: analyticsRecorder)
    }
}


// MARK: - Private

struct EmailLoginAnalytics: ReducerProtocol {

    typealias Action = EmailLoginAction
    typealias State = EmailLoginState

    let analyticsRecorder: AnalyticsEventRecorderAPI

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .sendDeviceVerificationEmail:
                analyticsRecorder.record(
                    event: .loginClicked(
                        origin: .navigation
                    )
                )
                return .none
            case .didSendDeviceVerificationEmail(.success):
                analyticsRecorder.record(
                    event: .loginIdentifierEntered(
                        identifierType: .email
                    )
                )
                return .none
            case .didSendDeviceVerificationEmail(.failure(let error)):
                analyticsRecorder.record(
                    event: .loginIdentifierFailed(
                        errorMessage: error.localizedDescription
                    )
                )
                return .none
            default:
                return .none
            }
        }
    }
}
