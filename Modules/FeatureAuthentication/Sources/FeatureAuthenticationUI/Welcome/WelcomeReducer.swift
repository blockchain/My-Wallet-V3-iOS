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
    public var emailLoginState: EmailLoginState?
    public var restoreWalletState: SeedPhraseState?
    public var manualPairingEnabled: Bool
    public var manualCredentialsState: CredentialsState?

    public init() {
        self.buildVersion = ""
        self.route = nil
        self.createWalletState = nil
        self.restoreWalletState = nil
        self.emailLoginState = nil
        self.manualPairingEnabled = false
        self.manualCredentialsState = nil
    }
}

public struct WelcomeEnvironment {
    let app: AppProtocol
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let passwordValidator: PasswordValidatorAPI
    let sessionTokenService: SessionTokenServiceAPI
    let deviceVerificationService: DeviceVerificationServiceAPI
    let buildVersionProvider: () -> String
    let featureFlagsService: FeatureFlagsServiceAPI
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

    public init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        passwordValidator: PasswordValidatorAPI = resolve(),
        sessionTokenService: SessionTokenServiceAPI = resolve(),
        deviceVerificationService: DeviceVerificationServiceAPI,
        featureFlagsService: FeatureFlagsServiceAPI,
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
        checkReferralClient: CheckReferralClientAPI = DIKit.resolve()
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.passwordValidator = passwordValidator
        self.sessionTokenService = sessionTokenService
        self.deviceVerificationService = deviceVerificationService
        self.buildVersionProvider = buildVersionProvider
        self.featureFlagsService = featureFlagsService
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
    }
}

public let welcomeReducer = Reducer.combine(
    createAccountStepOneReducer
        .optional()
        .pullback(
            state: \.createWalletState,
            action: /WelcomeAction.createWallet,
            environment: {
                CreateAccountStepOneEnvironment(
                    mainQueue: $0.mainQueue,
                    passwordValidator: $0.passwordValidator,
                    externalAppOpener: $0.externalAppOpener,
                    analyticsRecorder: $0.analyticsRecorder,
                    walletRecoveryService: $0.walletRecoveryService,
                    walletCreationService: $0.walletCreationService,
                    walletFetcherService: $0.walletFetcherService,
                    signUpCountriesService: $0.signUpCountriesService,
                    featureFlagsService: $0.featureFlagsService,
                    recaptchaService: $0.recaptchaService,
                    checkReferralClient: $0.checkReferralClient,
                    app: $0.app
                )
            }
        ),
    emailLoginReducer
        .optional()
        .pullback(
            state: \.emailLoginState,
            action: /WelcomeAction.emailLogin,
            environment: {
                EmailLoginEnvironment(
                    app: $0.app,
                    mainQueue: $0.mainQueue,
                    sessionTokenService: $0.sessionTokenService,
                    deviceVerificationService: $0.deviceVerificationService,
                    featureFlagsService: $0.featureFlagsService,
                    errorRecorder: $0.errorRecorder,
                    externalAppOpener: $0.externalAppOpener,
                    analyticsRecorder: $0.analyticsRecorder,
                    walletRecoveryService: $0.walletRecoveryService,
                    walletCreationService: $0.walletCreationService,
                    walletFetcherService: $0.walletFetcherService,
                    accountRecoveryService: $0.accountRecoveryService,
                    recaptchaService: $0.recaptchaService
                )
            }
        ),
    seedPhraseReducer
        .optional()
        .pullback(
            state: \.restoreWalletState,
            action: /WelcomeAction.restoreWallet,
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
                    recaptchaService: $0.recaptchaService,
                    featureFlagsService: $0.featureFlagsService
                )
            }
        ),
    credentialsReducer
        .optional()
        .pullback(
            state: \.manualCredentialsState,
            action: /WelcomeAction.manualPairing,
            environment: {
                CredentialsEnvironment(
                    mainQueue: $0.mainQueue,
                    deviceVerificationService: $0.deviceVerificationService,
                    errorRecorder: $0.errorRecorder,
                    featureFlagsService: $0.featureFlagsService,
                    analyticsRecorder: $0.analyticsRecorder,
                    walletRecoveryService: $0.walletRecoveryService,
                    walletCreationService: $0.walletCreationService,
                    walletFetcherService: $0.walletFetcherService,
                    accountRecoveryService: $0.accountRecoveryService,
                    recaptchaService: $0.recaptchaService
                )
            }
        ),
    Reducer<
        WelcomeState,
        WelcomeAction,
        WelcomeEnvironment
    > { state, action, environment in
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
            state.buildVersion = environment.buildVersionProvider()
            if BuildFlag.isInternal {
                return environment.app
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
)
.analytics()

extension Reducer where
    Action == WelcomeAction,
    State == WelcomeState,
    Environment == WelcomeEnvironment
{
    func analytics() -> Self {
        combined(
            with: Reducer<
                WelcomeState,
                WelcomeAction,
                WelcomeEnvironment
            > { _, action, environment in
                switch action {
                case .route(let route):
                    guard let routeValue = route?.route else {
                        return .none
                    }
                    switch routeValue {
                    case .emailLogin:
                        environment.analyticsRecorder.record(
                            event: .loginClicked()
                        )
                    case .restoreWallet:
                        environment.analyticsRecorder.record(
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
        )
    }
}
