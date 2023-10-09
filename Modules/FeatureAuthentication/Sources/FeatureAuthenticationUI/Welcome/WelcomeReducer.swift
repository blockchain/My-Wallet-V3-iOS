// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableNavigation
import DIKit
import FeatureAuthenticationDomain
import ToolKit
import WalletPayloadKit

// MARK: - Type

public enum WelcomeAction: Equatable, NavigationAction {

    // MARK: - Start Up

    case start

    // MARK: - Deep link

    case deeplinkReceived(URL)

    // MARK: - Wallet

    case requestedToCreateWallet(String, String)
    case requestedToDecryptWallet(String)
    case requestedToRestoreWallet(WalletRecovery)

    // MARK: - Navigation

    case route(RouteIntent<WelcomeRoute>?)

    // MARK: - Local Action

    case createWallet(CreateAccountStepOneAction)
    case emailLogin(EmailLoginAction)
    case restoreWallet(SeedPhraseAction)
    case setManualPairingEnabled // should only be on internal build
    case manualPairing(CredentialsAction) // should only be on internal build
    case informSecondPasswordDetected
    case informForWalletInitialization
    case informWalletFetched(WalletFetchedContext)

    // MARK: - Utils

    case none
}

// MARK: - Properties

/// The `master` `State` for the Single Sign On (SSO) Flow
public struct WelcomeState: Equatable, NavigationState {
    public var buildVersion: String
    public var route: RouteIntent<WelcomeRoute>?
    public var createWalletState: CreateAccountStepOneState?
    public var emailLoginState: EmailLoginState? {
      get { _emailLoginState?.first }
      set { _emailLoginState = newValue.map { [$0] } }
    }
    private var _emailLoginState: [EmailLoginState]?
    public var restoreWalletState: SeedPhraseState?
    public var manualPairingEnabled: Bool
    public var manualCredentialsState: CredentialsState?

    public init() {
        self.buildVersion = ""
        self.route = nil
        self.createWalletState = nil
        self.restoreWalletState = nil
        self._emailLoginState = nil
        self.manualPairingEnabled = false
        self.manualCredentialsState = nil
    }
}

public struct WelcomeReducer: ReducerProtocol {

    public typealias State = WelcomeState
    public typealias Action = WelcomeAction

    let app: AppProtocol
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let passwordValidator: PasswordValidatorAPI
    let sessionTokenService: SessionTokenServiceAPI
    let deviceVerificationService: DeviceVerificationServiceAPI
    let buildVersionProvider: () -> String
    let errorRecorder: ErrorRecording
    let externalAppOpener: ExternalAppOpener
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let accountRecoveryService: AccountRecoveryServiceAPI
    let signUpCountriesService: SignUpCountriesServiceAPI
    let recaptchaService: GoogleRecaptchaServiceAPI
    let checkReferralClient: CheckReferralClientAPI
    let emailAuthorizationService: EmailAuthorizationServiceAPI
    let smsService: SMSServiceAPI
    let loginService: LoginServiceAPI
    let seedPhraseValidator: SeedPhraseValidatorAPI
    let appStoreInformationRepository: AppStoreInformationRepositoryAPI

    public init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        passwordValidator: PasswordValidatorAPI = resolve(),
        sessionTokenService: SessionTokenServiceAPI = resolve(),
        deviceVerificationService: DeviceVerificationServiceAPI,
        recaptchaService: GoogleRecaptchaServiceAPI,
        buildVersionProvider: @escaping () -> String,
        errorRecorder: ErrorRecording = resolve(),
        externalAppOpener: ExternalAppOpener = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        walletRecoveryService: WalletRecoveryService = DIKit.resolve(),
        walletCreationService: WalletCreationService = DIKit.resolve(),
        walletFetcherService: WalletFetcherService = DIKit.resolve(),
        signUpCountriesService: SignUpCountriesServiceAPI = DIKit.resolve(),
        accountRecoveryService: AccountRecoveryServiceAPI = DIKit.resolve(),
        checkReferralClient: CheckReferralClientAPI = DIKit.resolve(),
        emailAuthorizationService: EmailAuthorizationServiceAPI = DIKit.resolve(),
        smsService: SMSServiceAPI = DIKit.resolve(),
        loginService: LoginServiceAPI = DIKit.resolve(),
        seedPhraseValidator: SeedPhraseValidatorAPI = DIKit.resolve(),
        appStoreInformationRepository: AppStoreInformationRepositoryAPI = DIKit.resolve()
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.passwordValidator = passwordValidator
        self.sessionTokenService = sessionTokenService
        self.deviceVerificationService = deviceVerificationService
        self.buildVersionProvider = buildVersionProvider
        self.errorRecorder = errorRecorder
        self.externalAppOpener = externalAppOpener
        self.analyticsRecorder = analyticsRecorder
        self.walletRecoveryService = walletRecoveryService
        self.walletCreationService = walletCreationService
        self.walletFetcherService = walletFetcherService
        self.signUpCountriesService = signUpCountriesService
        self.accountRecoveryService = accountRecoveryService
        self.checkReferralClient = checkReferralClient
        self.recaptchaService = recaptchaService
        self.emailAuthorizationService = emailAuthorizationService
        self.smsService = smsService
        self.loginService = loginService
        self.seedPhraseValidator = seedPhraseValidator
        self.appStoreInformationRepository = appStoreInformationRepository
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .route(let route):
                guard let routeValue = route?.route else {
                    state.createWalletState = nil
                    state.emailLoginState = nil
                    state.restoreWalletState = nil
                    state.manualCredentialsState = nil
                    state.route = route
                    return .none
                }
                switch routeValue {
                case .createWallet:
                    state.createWalletState = .init(context: .createWallet)
                case .emailLogin:
                    state.emailLoginState = .init()
                case .restoreWallet:
                    state.restoreWalletState = .init(context: .restoreWallet)
                case .manualLogin:
                    state.manualCredentialsState = .init()
                }
                state.route = route
                return .none

            case .start:
                state.buildVersion = buildVersionProvider()
                if BuildFlag.isInternal {
                    return app
                        .publisher(for: blockchain.app.configuration.manual.login.is.enabled, as: Bool.self)
                        .prefix(1)
                        .replaceError(with: false)
                        .flatMap { isEnabled -> EffectTask<WelcomeAction> in
                            guard isEnabled else {
                                return .none
                            }
                            return EffectTask(value: .setManualPairingEnabled)
                        }
                        .eraseToEffect()
                }
                return .none

            case .setManualPairingEnabled:
                state.manualPairingEnabled = true
                return .none

            case .deeplinkReceived(let url):
                // handle deeplink if we've entered verify device flow
                guard let loginState = state.emailLoginState,
                      loginState.verifyDeviceState != nil
                else {
                    return .none
                }
                return EffectTask(value: .emailLogin(.verifyDevice(.didReceiveWalletInfoDeeplink(url))))

            case .requestedToCreateWallet,
                 .requestedToDecryptWallet,
                 .requestedToRestoreWallet:
                // handled in core coordinator
                return .none

            case .createWallet(.triggerAuthenticate):
                return .none

            case .createWallet(.informWalletFetched(let context)):
                return EffectTask(value: .informWalletFetched(context))

            case .emailLogin(.verifyDevice(.credentials(.seedPhrase(.informWalletFetched(let context))))):
                return EffectTask(value: .informWalletFetched(context))

            case .emailLogin(.verifyDevice(.credentials(.onForgotPasswordTapped))):
                state.route = nil
                return .none

            // TODO: refactor this by not relying on access lower level reducers
            case .emailLogin(.verifyDevice(.credentials(.walletPairing(.decryptWalletWithPassword(let password))))),
                 .emailLogin(.verifyDevice(.upgradeAccount(.skipUpgrade(.credentials(.walletPairing(.decryptWalletWithPassword(let password))))))):
                return EffectTask(value: .requestedToDecryptWallet(password))

            case .emailLogin(.verifyDevice(.credentials(.seedPhrase(.restoreWallet(let walletRecovery))))):
                return EffectTask(value: .requestedToRestoreWallet(walletRecovery))

            case .restoreWallet(.restoreWallet(let walletRecovery)):
                return EffectTask(value: .requestedToRestoreWallet(walletRecovery))

            case .restoreWallet(.importWallet(.createAccount(.importAccount))):
                return EffectTask(value: .requestedToRestoreWallet(.importRecovery))

            case .manualPairing(.walletPairing(.decryptWalletWithPassword(let password))):
                return EffectTask(value: .requestedToDecryptWallet(password))

            case .emailLogin(.verifyDevice(.credentials(.secondPasswordNotice(.returnTapped)))),
                 .manualPairing(.secondPasswordNotice(.returnTapped)):
                return .dismiss()

            case .manualPairing(.seedPhrase(.informWalletFetched(let context))):
                return EffectTask(value: .informWalletFetched(context))

            case .manualPairing(.seedPhrase(.importWallet(.createAccount(.walletFetched(.success(.right(let context))))))):
                return EffectTask(value: .informWalletFetched(context))

            case .manualPairing:
                return .none

            case .restoreWallet(.triggerAuthenticate):
                return .none

            case .emailLogin(.verifyDevice(.credentials(.seedPhrase(.triggerAuthenticate)))):
                return .none

            case .restoreWallet(.restored(.success(.right(let context)))),
                 .emailLogin(.verifyDevice(.credentials(.seedPhrase(.restored(.success(.right(let context))))))):
                return EffectTask(value: .informWalletFetched(context))

            case .restoreWallet(.importWallet(.createAccount(.walletFetched(.success(.right(let context)))))):
                return EffectTask(value: .informWalletFetched(context))

            case .restoreWallet(.restored(.success(.left(.noValue)))),
                 .emailLogin(.verifyDevice(.credentials(.seedPhrase(.restored(.success(.left(.noValue))))))):
                return EffectTask(value: .informForWalletInitialization)
            case .restoreWallet(.restored(.failure)),
                 .emailLogin(.verifyDevice(.credentials(.seedPhrase(.restored(.failure))))):
                return .none
            case .createWallet(.accountCreation(.failure)):
                return .none

            case .informSecondPasswordDetected:
                switch state.route?.route {
                case .emailLogin:
                    return EffectTask(value: .emailLogin(.verifyDevice(.credentials(.navigate(to: .secondPasswordDetected)))))
                case .manualLogin:
                    return EffectTask(value: .manualPairing(.navigate(to: .secondPasswordDetected)))
                case .restoreWallet:
                    return EffectTask(value: .restoreWallet(.setSecondPasswordNoticeVisible(true)))
                default:
                    return .none
                }

            case .informForWalletInitialization,
                 .informWalletFetched:
                // handled in core coordinator
                return .none

            case .createWallet,
                 .emailLogin,
                 .restoreWallet:
                return .none

            case .none:
                return .none
            }
        }
        .ifLet(\.createWalletState, action: /Action.createWallet) {
            CreateAccountStepOneReducer(
                mainQueue: mainQueue,
                passwordValidator: passwordValidator,
                externalAppOpener: externalAppOpener,
                analyticsRecorder: analyticsRecorder,
                walletRecoveryService: walletRecoveryService,
                walletCreationService: walletCreationService,
                walletFetcherService: walletFetcherService,
                signUpCountriesService: signUpCountriesService,
                recaptchaService: recaptchaService,
                checkReferralClient: checkReferralClient,
                app: app
            )
        }
        .ifLet(\.emailLoginState, action: /Action.emailLogin) {
            EmailLoginReducer(
                app: app,
                mainQueue: mainQueue,
                sessionTokenService: sessionTokenService,
                deviceVerificationService: deviceVerificationService,
                errorRecorder: errorRecorder,
                externalAppOpener: externalAppOpener,
                analyticsRecorder: analyticsRecorder,
                walletRecoveryService: walletRecoveryService,
                walletCreationService: walletCreationService,
                walletFetcherService: walletFetcherService,
                accountRecoveryService: accountRecoveryService,
                recaptchaService: recaptchaService,
                emailAuthorizationService: emailAuthorizationService,
                smsService: smsService,
                loginService: loginService,
                seedPhraseValidator: seedPhraseValidator,
                passwordValidator: passwordValidator,
                signUpCountriesService: signUpCountriesService,
                appStoreInformationRepository: appStoreInformationRepository
            )
        }
        .ifLet(\.restoreWalletState, action: /Action.restoreWallet) {
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
        .ifLet(\.manualCredentialsState, action: /Action.manualPairing) {
            CredentialsReducer(
                app: app,
                mainQueue: mainQueue,
                sessionTokenService: sessionTokenService,
                deviceVerificationService: deviceVerificationService,
                emailAuthorizationService: emailAuthorizationService,
                smsService: smsService,
                loginService: loginService,
                errorRecorder: errorRecorder,
                externalAppOpener: externalAppOpener,
                analyticsRecorder: analyticsRecorder,
                walletRecoveryService: walletRecoveryService,
                walletCreationService: walletCreationService,
                walletFetcherService: walletFetcherService,
                accountRecoveryService: accountRecoveryService,
                recaptchaService: recaptchaService,
                seedPhraseValidator: seedPhraseValidator,
                passwordValidator: passwordValidator,
                signUpCountriesService: signUpCountriesService,
                appStoreInformationRepository: appStoreInformationRepository
            )
        }
        WelcomeAnalytics(analyticsRecorder: analyticsRecorder)
    }
}

struct WelcomeAnalytics: ReducerProtocol {

    typealias Action = WelcomeAction
    typealias State = WelcomeState

    let analyticsRecorder: AnalyticsEventRecorderAPI

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .route(let route):
                guard let routeValue = route?.route else {
                    return .none
                }
                switch routeValue {
                case .emailLogin:
                    analyticsRecorder.record(
                        event: .loginClicked()
                    )
                case .restoreWallet:
                    analyticsRecorder.record(
                        event: .recoveryOptionSelected
                    )
                default:
                    break
                }
                return .none
            default:
                return .none
            }
        }
    }
}
