// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableNavigation
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit

// MARK: - Type

public enum VerifyDeviceAction: Equatable, NavigationAction {

    // MARK: - Alert

    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    case alert(PresentationAction<AlertAction>)

    // MARK: - Navigation

    case onAppear
    case onWillDisappear
    case route(RouteIntent<VerifyDeviceRoute>?)

    // MARK: - Deeplink handling

    case didReceiveWalletInfoDeeplink(URL)
    case didExtractWalletInfo(WalletInfo)
    case fallbackToWalletIdentifier
    case checkIfConfirmationRequired(sessionId: String, base64Str: String)

    // MARK: - WalletInfo polling

    case pollWalletInfo
    case didPolledWalletInfo(Result<WalletInfo, WalletInfoPollingError>)
    case deviceRejected

    // MARK: - Device Verification

    case openMailApp
    case sendDeviceVerificationEmail

    // MARK: - Local Actions

    case credentials(CredentialsAction)
    case upgradeAccount(UpgradeAccountAction)

    case navigate(VerifyDeviceRoute)

    // MARK: - Utils

    case none
}

private enum VerifyDeviceCancellations {
    struct WalletInfoPollingId: Hashable {}
}

// MARK: - Properties

public struct VerifyDeviceState: Equatable, NavigationState {

    // MARK: - Navigation State

    public var route: RouteIntent<VerifyDeviceRoute>?

    // MARK: - Alert State

    @PresentationState var alert: AlertState<VerifyDeviceAction.AlertAction>?

    // MARK: - Credentials

    var emailAddress: String
    var credentialsContext: CredentialsContext
    var showOpenMailAppButton: Bool

    // MARK: - Loading State

    var sendEmailButtonIsLoading: Bool

    // MARK: - Local States

    var credentialsState: CredentialsState?
    var upgradeAccountState: UpgradeAccountState?

    init(emailAddress: String) {
        self.emailAddress = emailAddress
        self.credentialsContext = .none
        self.sendEmailButtonIsLoading = false
        self.showOpenMailAppButton = false
    }
}

struct VerifyDeviceReducer: Reducer {

    typealias State = VerifyDeviceState
    typealias Action = VerifyDeviceAction

    let app: AppProtocol
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI
    let errorRecorder: ErrorRecording
    let externalAppOpener: ExternalAppOpener
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let walletInfoBase64Encoder: (WalletInfo) throws -> String
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let accountRecoveryService: AccountRecoveryServiceAPI
    let recaptchaService: GoogleRecaptchaServiceAPI
    let sessionTokenService: SessionTokenServiceAPI
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
        deviceVerificationService: DeviceVerificationServiceAPI,
        errorRecorder: ErrorRecording,
        externalAppOpener: ExternalAppOpener,
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
        seedPhraseValidator: SeedPhraseValidatorAPI,
        passwordValidator: PasswordValidatorAPI,
        signUpCountriesService: SignUpCountriesServiceAPI,
        appStoreInformationRepository: AppStoreInformationRepositoryAPI,
        walletInfoBase64Encoder: @escaping (WalletInfo) throws -> String = {
            try JSONEncoder().encode($0).base64EncodedString()
        }
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.deviceVerificationService = deviceVerificationService
        self.errorRecorder = errorRecorder
        self.externalAppOpener = externalAppOpener
        self.analyticsRecorder = analyticsRecorder
        self.walletRecoveryService = walletRecoveryService
        self.walletCreationService = walletCreationService
        self.walletFetcherService = walletFetcherService
        self.accountRecoveryService = accountRecoveryService
        self.recaptchaService = recaptchaService
        self.sessionTokenService = sessionTokenService
        self.walletInfoBase64Encoder = walletInfoBase64Encoder
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
                        TextState(LocalizationConstants.okString),
                        action: .send(.dismiss)
                    )
                )
                return .none

            case .alert(.dismiss), .alert(.presented(.dismiss)):
                state.alert = nil
                return .none

            // MARK: - Navigations

            case .onAppear:
                let mailAppURL = URL(string: "message://")
                let canOpenURL = mailAppURL != nil ? UIApplication.shared.canOpenURL(mailAppURL!) : false
                state.showOpenMailAppButton = canOpenURL
                return Effect.send(.pollWalletInfo)

            case .onWillDisappear:
                return .cancel(id: VerifyDeviceCancellations.WalletInfoPollingId())

            case .route(let route):
                if let routeValue = route?.route {
                    switch routeValue {
                    case .credentials:
                        switch state.credentialsContext {
                        case .walletInfo(let walletInfo):
                            var twoFAState: TwoFAState?
                            if let twoFAType = walletInfo.wallet?.twoFaType {
                                switch twoFAType {
                                case .sms:
                                    twoFAState = TwoFAState(
                                        twoFAType: .sms,
                                        isTwoFACodeFieldVisible: true,
                                        isResendSMSButtonVisible: true
                                    )
                                case .google:
                                    twoFAState = TwoFAState(
                                        twoFAType: .google,
                                        isTwoFACodeFieldVisible: true
                                    )
                                case .yubiKey:
                                    twoFAState = TwoFAState(
                                        twoFAType: .yubiKey,
                                        isTwoFACodeFieldVisible: true
                                    )
                                case .yubikeyMtGox:
                                    twoFAState = TwoFAState(
                                        twoFAType: .yubikeyMtGox,
                                        isTwoFACodeFieldVisible: true
                                    )
                                default:
                                    break
                                }
                            }
                            state.credentialsState = CredentialsState(
                                walletPairingState: WalletPairingState(
                                    emailAddress: walletInfo.wallet?.email ?? "",
                                    emailCode: walletInfo.wallet?.emailCode,
                                    walletGuid: walletInfo.wallet?.guid ?? ""
                                ),
                                twoFAState: twoFAState,
                                nabuInfo: walletInfo.wallet?.nabu
                            )
                        case .walletIdentifier(let guid):
                            state.credentialsState = CredentialsState(
                                walletPairingState: WalletPairingState(
                                    walletGuid: guid ?? ""
                                )
                            )
                        case .manualPairing, .none:
                            state.credentialsState = .init()
                        }
                    case .upgradeAccount:
                        guard case .walletInfo(let info) = state.credentialsContext else {
                            state.route = nil
                            return .none
                        }
                        do {
                            let base64Str = try walletInfoBase64Encoder(info)
                            state.upgradeAccountState = .init(
                                walletInfo: info,
                                base64Str: base64Str
                            )
                        } catch {
                            errorRecorder.error(error)
                        }
                    }
                } else {
                    state.credentialsState = nil
                    state.upgradeAccountState = nil
                }
                state.route = route
                return .none

            // MARK: - Deeplink handling

            case .didReceiveWalletInfoDeeplink(let url):
                return .run { send in
                    do {
                        let walletInfo = try await deviceVerificationService
                            .handleLoginRequestDeeplink(url: url)
                            .receive(on: mainQueue)
                            .await()
                        await send(.didExtractWalletInfo(walletInfo))
                    } catch {
                        errorRecorder.error(error)
                        switch error as! WalletInfoError {
                        case .failToDecodeBase64Component,
                             .failToDecodeToWalletInfo:
                            await send(.fallbackToWalletIdentifier)
                        case .missingSessionToken(let sessionId, let base64Str),
                             .sessionTokenMismatch(let sessionId, let base64Str):
                            await send(.checkIfConfirmationRequired(sessionId: sessionId, base64Str: base64Str))
                        }
                    }
                }

            case .didExtractWalletInfo(let walletInfo):
                guard walletInfo.wallet?.email != nil, walletInfo.wallet?.emailCode != nil
                else {
                    state.credentialsContext = .walletIdentifier(guid: walletInfo.wallet?.guid)
                    // cancel the polling once wallet info is extracted
                    // it could be from the deeplink or from the polling
                    return .merge(
                        .cancel(id: VerifyDeviceCancellations.WalletInfoPollingId()),
                        .navigate(to: .credentials)
                    )
                }
                state.credentialsContext = .walletInfo(walletInfo)
                return .run { send in
                    let featureEnabled = await (try? app.get(blockchain.app.configuration.unified.sign_in.is.enabled, as: Bool.self)) ?? false

                    guard featureEnabled,
                        walletInfo.shouldUpgradeAccount,
                        let userType = walletInfo.userType
                    else {
                        await send(.navigate(.credentials))
                        return
                    }
                    await send(.navigate(.upgradeAccount(exchangeOnly: userType == .exchange)))
                }
            case .navigate(let route):
                return .merge(
                    .cancel(id: VerifyDeviceCancellations.WalletInfoPollingId()),
                    .navigate(to: route)
                )
            case .fallbackToWalletIdentifier:
                state.credentialsContext = .walletIdentifier(guid: "")
                return Effect.send(.navigate(to: .credentials))

            case .checkIfConfirmationRequired:
                return .none

            // MARK: - WalletInfo polling

            case .pollWalletInfo:
                return .run { send in
                    let pollResult = try? await deviceVerificationService
                        .pollForWalletInfo()
                        .receive(on: mainQueue)
                        .await()
                    guard let pollResult else {
                        return
                    }
                    await send(.didPolledWalletInfo(pollResult))
                }
                .cancellable(id: VerifyDeviceCancellations.WalletInfoPollingId())

            case .didPolledWalletInfo(let result):
                // extract wallet info once the polling endpoint receives a value
                switch result {
                case .success(let walletInfo):
                    analyticsRecorder.record(event: .loginRequestApproved(.magicLink))
                    return Effect.send(.didExtractWalletInfo(walletInfo))
                case .failure(.requestDenied):
                    analyticsRecorder.record(event: .loginRequestDenied(.magicLink))
                    return Effect.send(.deviceRejected)
                case .failure:
                    return .none
                }

            case .deviceRejected:
                return .none

            // MARK: - Device Verification

            case .sendDeviceVerificationEmail:
                // handled in email login reducer
                return .none

            case .openMailApp:
                externalAppOpener.openMailApp { _ in }
                return .none

            // MARK: - Local Reducers

            case .credentials:
                // handled in credentials reducer
                return .none

            case .upgradeAccount:
                // handled in upgrade account reducer
                return .none

            // MARK: - Utils

            case .none:
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
        .ifLet(\.upgradeAccountState, action: /Action.upgradeAccount) {
            UpgradeAccountReducer(
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
        VerifyDeviceAnalytics(analyticsRecorder: analyticsRecorder)
    }
}

// MARK: - Private

struct VerifyDeviceAnalytics: Reducer {

    typealias State = VerifyDeviceState
    typealias Action = VerifyDeviceAction

    let analyticsRecorder: AnalyticsEventRecorderAPI

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .didExtractWalletInfo(let walletInfo):
                analyticsRecorder.record(
                    event: .deviceVerified(info: walletInfo)
                )
                return .none
            default:
                return .none
            }
        }
    }
}
