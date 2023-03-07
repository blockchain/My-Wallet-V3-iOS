// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableNavigation
import DIKit
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

    case alert(AlertAction)

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

    var alert: AlertState<VerifyDeviceAction>?

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

struct VerifyDeviceEnvironment {
    let app: AppProtocol
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI
    let featureFlagsService: FeatureFlagsServiceAPI
    let errorRecorder: ErrorRecording
    let externalAppOpener: ExternalAppOpener
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let walletInfoBase64Encoder: (WalletInfo) throws -> String
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let accountRecoveryService: AccountRecoveryServiceAPI
    let recaptchaService: GoogleRecaptchaServiceAPI

    init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        deviceVerificationService: DeviceVerificationServiceAPI,
        featureFlagsService: FeatureFlagsServiceAPI,
        errorRecorder: ErrorRecording,
        externalAppOpener: ExternalAppOpener,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        walletRecoveryService: WalletRecoveryService,
        walletCreationService: WalletCreationService,
        walletFetcherService: WalletFetcherService,
        accountRecoveryService: AccountRecoveryServiceAPI,
        recaptchaService: GoogleRecaptchaServiceAPI,
        walletInfoBase64Encoder: @escaping (WalletInfo) throws -> String = {
            try JSONEncoder().encode($0).base64EncodedString()
        }
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.deviceVerificationService = deviceVerificationService
        self.featureFlagsService = featureFlagsService
        self.errorRecorder = errorRecorder
        self.externalAppOpener = externalAppOpener
        self.analyticsRecorder = analyticsRecorder
        self.walletRecoveryService = walletRecoveryService
        self.walletCreationService = walletCreationService
        self.walletFetcherService = walletFetcherService
        self.accountRecoveryService = accountRecoveryService
        self.recaptchaService = recaptchaService
        self.walletInfoBase64Encoder = walletInfoBase64Encoder
    }
}

let verifyDeviceReducer = Reducer.combine(
    credentialsReducer
        .optional()
        .pullback(
            state: \.credentialsState,
            action: /VerifyDeviceAction.credentials,
            environment: {
                CredentialsEnvironment(
                    mainQueue: $0.mainQueue,
                    deviceVerificationService: $0.deviceVerificationService,
                    errorRecorder: $0.errorRecorder,
                    externalAppOpener: $0.externalAppOpener,
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
    upgradeAccountReducer
        .optional()
        .pullback(
            state: \.upgradeAccountState,
            action: /VerifyDeviceAction.upgradeAccount,
            environment: {
                UpgradeAccountEnvironment(
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
        VerifyDeviceState,
        VerifyDeviceAction,
        VerifyDeviceEnvironment
    > { state, action, environment in
        switch action {

        // MARK: - Alert

        case .alert(.show(let title, let message)):
            state.alert = AlertState(
                title: TextState(verbatim: title),
                message: TextState(verbatim: message),
                dismissButton: .default(
                    TextState(LocalizationConstants.okString),
                    action: .send(.alert(.dismiss))
                )
            )
            return .none

        case .alert(.dismiss):
            state.alert = nil
            return .none

        // MARK: - Navigations

        case .onAppear:
            let mailAppURL = URL(string: "message://")
            let canOpenURL = mailAppURL != nil ? UIApplication.shared.canOpenURL(mailAppURL!) : false
            state.showOpenMailAppButton = canOpenURL
            return environment
                .featureFlagsService
                .isEnabled(.pollingForEmailLogin)
                .flatMap { isEnabled -> Effect<VerifyDeviceAction, Never> in
                    guard isEnabled else {
                        return .none
                    }
                    return Effect(value: .pollWalletInfo)
                }
                .receive(on: environment.mainQueue)
                .eraseToEffect()

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
                        let base64Str = try environment.walletInfoBase64Encoder(info)
                        state.upgradeAccountState = .init(
                            walletInfo: info,
                            base64Str: base64Str
                        )
                    } catch {
                        environment.errorRecorder.error(error)
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
            return environment
                .deviceVerificationService
                .handleLoginRequestDeeplink(url: url)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> VerifyDeviceAction in
                    switch result {
                    case .success(let walletInfo):
                        return .didExtractWalletInfo(walletInfo)
                    case .failure(let error):
                        environment.errorRecorder.error(error)
                        switch error {
                        case .failToDecodeBase64Component,
                             .failToDecodeToWalletInfo:
                            return .fallbackToWalletIdentifier
                        case .missingSessionToken(let sessionId, let base64Str),
                             .sessionTokenMismatch(let sessionId, let base64Str):
                            return .checkIfConfirmationRequired(sessionId: sessionId, base64Str: base64Str)
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
            return environment.app.publisher(
                for: blockchain.app.configuration.unified.sign_in.is.enabled,
                as: Bool.self
            )
            .prefix(1)
            .replaceError(with: false)
            .flatMap { featureEnabled -> Effect<VerifyDeviceAction, Never> in
                guard
                    featureEnabled,
                    walletInfo.shouldUpgradeAccount,
                    let userType = walletInfo.userType
                else {
                    return .merge(
                        .cancel(id: VerifyDeviceCancellations.WalletInfoPollingId()),
                        .navigate(to: .credentials)
                    )
                }
                return .merge(
                    .cancel(id: VerifyDeviceCancellations.WalletInfoPollingId()),
                    .navigate(to: .upgradeAccount(exchangeOnly: userType == .exchange))
                )
            }
            .receive(on: environment.mainQueue)
            .eraseToEffect()

        case .fallbackToWalletIdentifier:
            state.credentialsContext = .walletIdentifier(guid: "")
            return Effect(value: .navigate(to: .credentials))

        case .checkIfConfirmationRequired:
            return .none

        // MARK: - WalletInfo polling

        case .pollWalletInfo:
            return environment
                .deviceVerificationService
                .pollForWalletInfo()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: VerifyDeviceCancellations.WalletInfoPollingId())
                .map { result -> VerifyDeviceAction in
                    guard case .success(let pollResult) = result else {
                        return .none
                    }
                    return .didPolledWalletInfo(pollResult)
                }

        case .didPolledWalletInfo(let result):
            // extract wallet info once the polling endpoint receives a value
            switch result {
            case .success(let walletInfo):
                environment.analyticsRecorder.record(event: .loginRequestApproved(.magicLink))
                return Effect(value: .didExtractWalletInfo(walletInfo))
            case .failure(.requestDenied):
                environment.analyticsRecorder.record(event: .loginRequestDenied(.magicLink))
                return Effect(value: .deviceRejected)
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
            environment
                .externalAppOpener
                .openMailApp { _ in }
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
)
.analytics()

// MARK: - Private

extension Reducer where
    Action == VerifyDeviceAction,
    State == VerifyDeviceState,
    Environment == VerifyDeviceEnvironment
{
    /// Helper reducer for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                VerifyDeviceState,
                VerifyDeviceAction,
                VerifyDeviceEnvironment
            > { _, action, environment in
                switch action {
                case .didExtractWalletInfo(let walletInfo):
                    environment.analyticsRecorder.record(
                        event: .deviceVerified(info: walletInfo)
                    )
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
