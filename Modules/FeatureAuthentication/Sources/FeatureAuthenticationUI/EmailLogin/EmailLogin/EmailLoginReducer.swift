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

    case alert(PresentationAction<AlertAction>)

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

    @PresentationState var alert: AlertState<EmailLoginAction.AlertAction>?

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

struct EmailLoginReducer: Reducer {

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

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            // MARK: - Alert

            case .alert(.presented(.show(let title, let message))):
                state.alert = AlertState(
                    title: TextState(verbatim: title),
                    message: TextState(verbatim: message),
                    dismissButton: .default(
                        TextState(LocalizationConstants.continueString),
                        action: .send(.dismiss)
                    )
                )
                return .none

            case .alert(.dismiss), .alert(.presented(.dismiss)):
                state.alert = nil
                return .none

            // MARK: - Transitions and Navigations

            case .onAppear:
                return .run { _ in
                    analyticsRecorder.record(
                        event: .loginViewed
                    )
                    app.post(event: blockchain.ux.user.authentication.sign.in)
                }

            case .route(let route):
                if route?.route != nil {
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
                    Effect.send(.setupSessionToken),
                    .run { _ in
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
                return .run { [emailAddress = state.emailAddress] send in
                    do {
                        try await deviceVerificationService
                            .sendDeviceVerificationEmail(to: emailAddress)
                            .receive(on: mainQueue)
                            .await()
                        await send(.didSendDeviceVerificationEmail(.success(.noValue)))
                    } catch {
                        await send(.didSendDeviceVerificationEmail(.failure(error as! DeviceVerificationServiceError)))
                    }
                }

            case .didSendDeviceVerificationEmail(let response):
                state.isLoading = false
                state.verifyDeviceState?.sendEmailButtonIsLoading = false
                if case .failure(let error) = response {
                    switch error {
                    case .recaptchaError,
                         .missingSessionToken:
                        return Effect.send(
                            .alert(
                                .presented(
                                    .show(
                                        title: EmailLoginLocalization.Alerts.SignInError.title,
                                        message: EmailLoginLocalization.Alerts.SignInError.message
                                    )
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
                return Effect.send(.navigate(to: .verifyDevice))

            case .setupSessionToken:
                return .run { send in
                    do {
                        let token = try await sessionTokenService
                            .setupSessionToken()
                            .map { _ in EmptyValue.noValue }
                            .receive(on: mainQueue)
                            .await()
                        await send(EmailLoginAction.setupSessionTokenReceived(.success(token)))
                    } catch {
                        await send(.setupSessionTokenReceived(.failure(error as! SessionTokenServiceError)))
                    }
                }

            case .setupSessionTokenReceived(.success):
                return Effect.send(.sendDeviceVerificationEmail)

            case .setupSessionTokenReceived(.failure(let error)):
                state.isLoading = false
                errorRecorder.error(error)
                return Effect.send(
                    .alert(
                        .presented(
                            .show(
                                title: EmailLoginLocalization.Alerts.GenericNetworkError.title,
                                message: EmailLoginLocalization.Alerts.GenericNetworkError.message
                            )
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

struct EmailLoginAnalytics: Reducer {

    typealias Action = EmailLoginAction
    typealias State = EmailLoginState

    let analyticsRecorder: AnalyticsEventRecorderAPI

    var body: some Reducer<State, Action> {
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
