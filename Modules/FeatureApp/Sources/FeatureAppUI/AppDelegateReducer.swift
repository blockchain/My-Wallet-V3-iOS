// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import FeatureAuthenticationDomain
import FeatureDebugUI
import FeatureSettingsDomain
import MoneyKit
import NetworkKit
import ObservabilityKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import ToolKit
import UIKit

typealias AppDelegateEffect = EffectTask<AppDelegateAction>

/// Used to cancel the background task if needed
struct BackgroundTaskId: Hashable {}

public struct AppDelegateContext: Equatable {
    let embraceAppId: String

    public init(
        embraceAppId: String
    ) {
        self.embraceAppId = embraceAppId
    }
}

/// The actions to be performed by the AppDelegate
public enum AppDelegateAction: Equatable {
    case didFinishLaunching(window: UIWindow, context: AppDelegateContext)
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
    var featureFlagService: FeatureFlagsServiceAPI
    var observabilityService: ObservabilityServiceAPI
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
let appDelegateReducer = Reducer<
    AppDelegateState, AppDelegateAction, AppDelegateEnvironment
> { state, action, environment in
    switch action {
    case .didFinishLaunching(let window, let context):
        state.window = window
        return .merge(
            environment.assetsRemoteService
                .refreshCache
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .fireAndForget(),

            environment.remoteNotificationAuthorizer
                .registerForRemoteNotificationsIfAuthorized()
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .fireAndForget(),

            initializeObservability(
                using: environment.observabilityService,
                appId: context.embraceAppId
            ),

            .fireAndForget {
                environment.app.post(event: blockchain.app.did.finish.launching)
            },

            environment.app.publisher(for: blockchain.app.configuration.SSL.pinning.is.enabled, as: Bool.self)
                .prefix(1)
                .replaceError(with: true)
                .filter { $0 }
                .map(.applyCertificatePinning)
                .receive(on: environment.mainQueue)
                .eraseToEffect(),

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
            environment.backgroundAppHandler
                .appEnteredForeground(application)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .fireAndForget()
        )
    case .didEnterBackground(let application):
        return environment.backgroundAppHandler
                .appEnteredBackground(application)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .cancellable(id: BackgroundTaskId(), cancelInFlight: true)
                .map { _ in .handleDelayedEnterBackground }
    case .handleDelayedEnterBackground:
        return .merge(
            .fireAndForget {
                environment.app.state.set(blockchain.app.is.ready.for.deep_link, to: false)
            },
            .cancel(id: BackgroundTaskId())
        )
    case .didBecomeActive:
        return .merge(
            removeBlurFilter(
                handler: environment.blurEffectHandler,
                from: state.window
            ),
            .fireAndForget {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        )
    case .open(let url):
        return .none
    case .didRegisterForRemoteNotifications(let result):
        return .fireAndForget {
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
        return .fireAndForget {
            environment.remoteNotificationBackgroundReceiver
                .didReceiveRemoteNotification(
                    userInfo,
                    onApplicationState: application.applicationState,
                    fetchCompletionHandler: completionHandler
                )
        }
    case .userActivity(let userActivity):
        return .none
    case .applyCertificatePinning:
        return .fireAndForget {
            environment.certificatePinner.pinCertificateIfNeeded()
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
    return .fireAndForget {
        handler.applyEffect(on: view)
    }
}

private func initializeObservability(
    using service: ObservabilityServiceAPI,
    appId: String
) -> AppDelegateEffect {
    .fireAndForget {
        service.start(with: appId)
    }
}

private func removeBlurFilter(
    handler: BlurVisualEffectHandlerAPI,
    from window: UIWindow?
) -> AppDelegateEffect {
    guard let view = window else {
        return .none
    }
    return .fireAndForget {
        handler.removeEffect(from: view)
    }
}

private func enableSift(
    using service: FeatureAuthenticationDomain.SiftServiceAPI
) -> AppDelegateEffect {
    .fireAndForget {
        service.enable()
    }
}
