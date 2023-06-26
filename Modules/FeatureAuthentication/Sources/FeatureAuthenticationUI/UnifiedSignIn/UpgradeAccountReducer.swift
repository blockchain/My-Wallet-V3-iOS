// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
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

struct UpgradeAccountEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI
    let errorRecorder: ErrorRecording
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let accountRecoveryService: AccountRecoveryServiceAPI
    let recaptchaService: GoogleRecaptchaServiceAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        deviceVerificationService: DeviceVerificationServiceAPI,
        errorRecorder: ErrorRecording,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        walletRecoveryService: WalletRecoveryService,
        walletCreationService: WalletCreationService,
        walletFetcherService: WalletFetcherService,
        accountRecoveryService: AccountRecoveryServiceAPI,
        recaptchaService: GoogleRecaptchaServiceAPI
    ) {
        self.mainQueue = mainQueue
        self.deviceVerificationService = deviceVerificationService
        self.errorRecorder = errorRecorder
        self.analyticsRecorder = analyticsRecorder
        self.walletRecoveryService = walletRecoveryService
        self.walletCreationService = walletCreationService
        self.walletFetcherService = walletFetcherService
        self.accountRecoveryService = accountRecoveryService
        self.recaptchaService = recaptchaService
    }
}

let upgradeAccountReducer = Reducer.combine(
    skipUpgradeReducer
        .optional()
        .pullback(
            state: \.skipUpgradeState,
            action: /UpgradeAccountAction.skipUpgrade,
            environment: {
                SkipUpgradeEnvironment(
                    mainQueue: $0.mainQueue,
                    deviceVerificationService: $0.deviceVerificationService,
                    errorRecorder: $0.errorRecorder,
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
        UpgradeAccountState,
        UpgradeAccountAction,
        UpgradeAccountEnvironment
    > { state, action, _ in
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
)
