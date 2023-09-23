// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Blockchain
import Combine
import ComposableArchitecture
import ComposableNavigation
import FeatureAuthenticationDomain
import ToolKit

// MARK: - Type

public enum SkipUpgradeAction: Equatable, NavigationAction {

    // MARK: - Transitions and Navigations

    case route(RouteIntent<SkipUpgradeRoute>?)
    case returnToUpgradeButtonTapped

    // MARK: - Local Actions

    case credentials(CredentialsAction)
}

// MARK: - Properties

public struct SkipUpgradeState: Equatable, NavigationState {

    // MARK: - Navigations

    public var route: RouteIntent<SkipUpgradeRoute>?

    // MARK: - WalletInfo

    var walletInfo: WalletInfo

    // MARK: - Local States

    var credentialsState: CredentialsState?

    init(walletInfo: WalletInfo) {
        self.walletInfo = walletInfo
    }
}

struct SkipUpgradeReducer: ReducerProtocol {

    typealias State = SkipUpgradeState
    typealias Action = SkipUpgradeAction

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

            // MARK: - Transitions and Navigations

            case .route(let route):
                if let routeValue = route?.route {
                    switch routeValue {
                    case .credentials:
                        state.credentialsState = .init(
                            walletPairingState: WalletPairingState(
                                emailAddress: state.walletInfo.wallet?.email ?? "",
                                emailCode: state.walletInfo.wallet?.emailCode,
                                walletGuid: state.walletInfo.wallet?.guid ?? ""
                            )
                        )
                    }
                } else {
                    state.credentialsState = nil
                }
                state.route = route
                return .none

            case .returnToUpgradeButtonTapped:
                return .none

            // MARK: - Local Reducers

            case .credentials:
                return .none
            }
        }
        .ifLet(\.credentialsState, action: /Action.credentials) {
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
    }
}
