// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import FeatureAuthenticationDomain
import FeatureDebugUI
import FeatureSettingsDomain
import FeatureWalletConnectDomain
import MoneyKit
import NetworkKit
import ObservabilityKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import ToolKit
import UIKit

typealias AppDelegateEffect = Effect<AppDelegateAction>

/// Used to cancel the background task if needed
struct BackgroundTaskId: Hashable {}

/// The actions to be performed by the AppDelegate
public enum AppDelegateAction: Equatable {
    case didFinishLaunching(window: UIWindow)
    case willResignActive
    case willEnterForeground(_ application: UIApplication)
    case didEnterBackground(_ application: UIApplication)
    case handleDelayedEnterBackground
    case didBecomeActive
    case open(_ url: URL)
    case userActivity(_ userActivity: NSUserActivity)
    case didRegisterForRemoteNotifications(Result<Data, NSError>)
    case didReceiveRemoteNotification(
        _ application: UIApplication,
        userInfo: [AnyHashable: Any],
        completionHandler: (UIBackgroundFetchResult) -> Void
    )
    case applyCertificatePinning
}

extension AppDelegateAction {
    public static func == (lhs: AppDelegateAction, rhs: AppDelegateAction) -> Bool {
        switch (lhs, rhs) {
        case (.didReceiveRemoteNotification, .didReceiveRemoteNotification):
            // since we can't compare the userInfo
            // we'll always assume the notifications are different
            return false
        default:
            return lhs == rhs
        }
    }
}

/// Holds the dependencies
struct AppDelegateEnvironment {
    var app: AppProtocol
    var cacheSuite: CacheSuite
    var remoteNotificationBackgroundReceiver: RemoteNotificationBackgroundReceiving
    var remoteNotificationAuthorizer: RemoteNotificationRegistering
    var remoteNotificationTokenReceiver: RemoteNotificationDeviceTokenReceiving
    var certificatePinner: CertificatePinnerAPI
    var siftService: FeatureAuthenticationDomain.SiftServiceAPI
    var blurEffectHandler: BlurVisualEffectHandlerAPI
    var backgroundAppHandler: BackgroundAppHandlerAPI
    var assetsRemoteService: AssetsRemoteServiceAPI
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

/// The state of the app delegate
public struct AppDelegateState: Equatable {
    var window: UIWindow?
    /// `true` if a user activity was handled, such as universal links, otherwise `false`
    public var userActivityHandled: Bool = false
    /// `true` if a deep link was handled, otherwise `false`
    public var urlHandled: Bool = false

    public init(
        userActivityHandled: Bool = false,
        urlHandled: Bool = false
    ) {
        self.userActivityHandled = userActivityHandled
        self.urlHandled = urlHandled
    }
}

/// The reducer of the app delegate that describes the effects for each action.
struct AppDelegateReducer: Reducer {

    typealias State = AppDelegateState
    typealias Action = AppDelegateAction

    let environment: AppDelegateEnvironment

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didFinishLaunching(let window):
                state.window = window
                return .merge(
                    .run { _ in
                        try await environment.assetsRemoteService
                            .refreshCache
                            .receive(on: environment.mainQueue)
                            .await()
                    },
                    .run { _ in
                        environment.app.post(event: blockchain.app.did.finish.launching)
                    },
                    .run { send in
                        do {
                            try await environment.app.publisher(for: blockchain.app.configuration.SSL.pinning.is.enabled, as: Bool.self)
                                .prefix(1)
                                .replaceError(with: true)
                                .filter { $0 }
                                .receive(on: environment.mainQueue)
                                .await()
                            await send(.applyCertificatePinning)
                        }
                    },
                    setupWalletConnectV2(
                        projectId: InfoDictionaryHelper.value(for: .walletConnectId),
                        configurator: configureWalletConnectV2(projectId:)
                    ),

                    enableSift(using: environment.siftService)
                )
            case .willResignActive:
                return applyBlurFilter(
                    handler: environment.blurEffectHandler,
                    on: state.window
                )
            case .willEnterForeground(let application):
                return .merge(
                    .cancel(id: BackgroundTaskId()),
                    .run { _ in
                        try await environment.backgroundAppHandler
                            .appEnteredForeground(application)
                            .receive(on: environment.mainQueue)
                            .await()
                    }
                )
            case .didEnterBackground(let application):
                return .run { send in
                    try await environment.backgroundAppHandler
                        .appEnteredBackground(application)
                        .receive(on: environment.mainQueue)
                        .await()
                    await send(.handleDelayedEnterBackground)
                }
                .cancellable(id: BackgroundTaskId(), cancelInFlight: true)
            case .handleDelayedEnterBackground:
                return .merge(
                    .run { _ in
                        environment.app.state.set(blockchain.app.is.ready.for.deep_link, to: false)
                    },
                    .cancel(id: BackgroundTaskId())
                )
            case .didBecomeActive:
                UIApplication.shared.applicationIconBadgeNumber = 0
                return .merge(
                    removeBlurFilter(
                        handler: environment.blurEffectHandler,
                        from: state.window
                    )
                )
            case .open:
                return .none
            case .didRegisterForRemoteNotifications(let result):
                return .run { _ in
                    switch result {
                    case .success(let data):
                        environment.remoteNotificationTokenReceiver
                            .appDidRegisterForRemoteNotifications(with: data)
                    case .failure(let error):
                        environment.remoteNotificationTokenReceiver
                            .appDidFailToRegisterForRemoteNotifications(with: error)
                    }
                }
            case .didReceiveRemoteNotification(let application, let userInfo, let completionHandler):
                return .run { _ in
                    await environment.remoteNotificationBackgroundReceiver
                        .didReceiveRemoteNotification(
                            userInfo,
                            onApplicationState: application.applicationState,
                            fetchCompletionHandler: completionHandler
                        )
                }
            case .userActivity:
                return .none
            case .applyCertificatePinning:
                return .run { _ in
                    environment.certificatePinner.pinCertificateIfNeeded()
                }
            }
        }
    }
}

// MARK: - Effect Methods

private func applyBlurFilter(
    handler: BlurVisualEffectHandlerAPI,
    on window: UIWindow?
) -> AppDelegateEffect {
    guard let view = window else {
        return .none
    }
    return .run { _ in
        DispatchQueue.main.async {
            handler.applyEffect(on: view)
        }
    }
}

private func removeBlurFilter(
    handler: BlurVisualEffectHandlerAPI,
    from window: UIWindow?
) -> AppDelegateEffect {
    guard let view = window else {
        return .none
    }
    return .run { _ in
        DispatchQueue.main.async {
            handler.removeEffect(from: view)
        }
    }
}

private func enableSift(
    using service: FeatureAuthenticationDomain.SiftServiceAPI
) -> AppDelegateEffect {
    .run { _ in
        service.enable()
    }
}

private func setupWalletConnectV2(
    projectId: String,
    configurator: @escaping (_ projectId: String) -> Void
) -> AppDelegateEffect {
    .run { _ in
        configurator(projectId)
    }
}
