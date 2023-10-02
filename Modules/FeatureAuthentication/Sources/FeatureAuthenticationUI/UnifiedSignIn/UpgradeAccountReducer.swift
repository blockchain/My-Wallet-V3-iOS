// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Blockchain
import Combine
import ComposableArchitecture
import ComposableNavigation
import FeatureAuthenticationDomain
import ToolKit

// MARK: - Type

public enum UpgradeAccountAction: Equatable, NavigationAction {

    // MARK: - Navigations

    case route(RouteIntent<UpgradeAccountRoute>?)

    // MARK: - Local Actions

    case skipUpgrade(SkipUpgradeAction)

    // MARK: Web Account Upgrade

    case setCurrentMessage(String)
}

// MARK: - Properties

public struct UpgradeAccountState: NavigationState {

    // MARK: - Navigation State

    public var route: RouteIntent<UpgradeAccountRoute>?

    // MARK: - Wallet Info

    var walletInfo: WalletInfo
    var base64Str: String

    // MARK: - Local States

    var skipUpgradeState: SkipUpgradeState?

    // MARK: - Web Account Upgrade Messaging

    var currentMessage: String

    init(
        walletInfo: WalletInfo,
        base64Str: String
    ) {
        self.walletInfo = walletInfo
        self.base64Str = base64Str
        self.currentMessage = ""
    }
}

struct UpgradeAccountReducer: ReducerProtocol {

    typealias State = UpgradeAccountState
    typealias Action = UpgradeAccountAction

    let app: AppProtocol
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI
    let errorRecorder: ErrorRecording
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let accountRecoveryService: AccountRecoveryServiceAPI
    let recaptchaService: GoogleRecaptchaServiceAPI
    let sessionTokenService: SessionTokenServiceAPI
    let emailAuthorizationService: EmailAuthorizationServiceAPI
    let smsService: SMSServiceAPI
    let loginService: LoginServiceAPI
    let externalAppOpener: ExternalAppOpener
    let seedPhraseValidator: SeedPhraseValidatorAPI
    let passwordValidator: PasswordValidatorAPI
    let signUpCountriesService: SignUpCountriesServiceAPI
    let appStoreInformationRepository: AppStoreInformationRepositoryAPI

    init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        deviceVerificationService: DeviceVerificationServiceAPI,
        errorRecorder: ErrorRecording,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        walletRecoveryService: WalletRecoveryService,
        walletCreationService: WalletCreationService,
        walletFetcherService: WalletFetcherService,
        accountRecoveryService: AccountRecoveryServiceAPI,
        recaptchaService: GoogleRecaptchaServiceAPI,
        sessionTokenService: SessionTokenServiceAPI,
        emailAuthorizationService: EmailAuthorizationServiceAPI,
        smsService: SMSServiceAPI,
        loginService: LoginServiceAPI,
        externalAppOpener: ExternalAppOpener,
        seedPhraseValidator: SeedPhraseValidatorAPI,
        passwordValidator: PasswordValidatorAPI,
        signUpCountriesService: SignUpCountriesServiceAPI,
        appStoreInformationRepository: AppStoreInformationRepositoryAPI
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.deviceVerificationService = deviceVerificationService
        self.errorRecorder = errorRecorder
        self.analyticsRecorder = analyticsRecorder
        self.walletRecoveryService = walletRecoveryService
        self.walletCreationService = walletCreationService
        self.walletFetcherService = walletFetcherService
        self.accountRecoveryService = accountRecoveryService
        self.recaptchaService = recaptchaService
        self.sessionTokenService = sessionTokenService
        self.emailAuthorizationService = emailAuthorizationService
        self.smsService = smsService
        self.loginService = loginService
        self.externalAppOpener = externalAppOpener
        self.seedPhraseValidator = seedPhraseValidator
        self.passwordValidator = passwordValidator
        self.signUpCountriesService = signUpCountriesService
        self.appStoreInformationRepository = appStoreInformationRepository
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {

            // MARK: - Navigations

            case .route(let route):
                state.route = route
                if let routeValue = route?.route {
                    switch routeValue {
                    case .skipUpgrade:
                        state.skipUpgradeState = .init(
                            walletInfo: state.walletInfo
                        )
                    case .webUpgrade:
                        break
                    }
                } else {
                    state.skipUpgradeState = nil
                }
                return .none

            // MARK: - Local Reducers

            case .skipUpgrade(.returnToUpgradeButtonTapped):
                return .dismiss()

            case .skipUpgrade:
                return .none

            case .setCurrentMessage(let message):
                state.currentMessage = message
                return .none
            }
        }
        .ifLet(\.skipUpgradeState, action: /Action.skipUpgrade) {
            SkipUpgradeReducer(
                app: app,
                mainQueue: mainQueue,
                deviceVerificationService: deviceVerificationService,
                errorRecorder: errorRecorder,
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
                externalAppOpener: externalAppOpener,
                seedPhraseValidator: seedPhraseValidator,
                passwordValidator: passwordValidator,
                signUpCountriesService: signUpCountriesService,
                appStoreInformationRepository: appStoreInformationRepository
            )
        }
    }
}
