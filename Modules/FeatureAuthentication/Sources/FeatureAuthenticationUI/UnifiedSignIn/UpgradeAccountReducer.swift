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
}

// MARK: - Properties

public struct UpgradeAccountState: NavigationState {

    // MARK: - Navigation State

    public var route: RouteIntent<UpgradeAccountRoute>?

    // MARK: - Wallet Info

    var walletInfo: WalletInfo

    // MARK: - Local States

    var skipUpgradeState: SkipUpgradeState?

    init(walletInfo: WalletInfo) {
        self.walletInfo = walletInfo
    }
}

struct UpgradeAccountEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI
    let errorRecorder: ErrorRecording
    let appFeatureConfigurator: FeatureConfiguratorAPI
    let analyticsRecorder: AnalyticsEventRecorderAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        deviceVerificationService: DeviceVerificationServiceAPI,
        errorRecorder: ErrorRecording,
        appFeatureConfigurator: FeatureConfiguratorAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI
    ) {
        self.mainQueue = mainQueue
        self.deviceVerificationService = deviceVerificationService
        self.errorRecorder = errorRecorder
        self.appFeatureConfigurator = appFeatureConfigurator
        self.analyticsRecorder = analyticsRecorder
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
                    appFeatureConfigurator: $0.appFeatureConfigurator,
                    analyticsRecorder: $0.analyticsRecorder
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
            return Effect(value: .navigate(to: nil))

        case .skipUpgrade:
            return .none
        }
    }
)