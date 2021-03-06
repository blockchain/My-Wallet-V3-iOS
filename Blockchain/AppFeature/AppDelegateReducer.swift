// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DebugUIKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import SettingsKit
import ToolKit
import UIKit

typealias AppDelegateEffect = Effect<AppDelegateAction, Never>

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
}

/// Holds the dependencies
struct AppDelegateEnvironment {
    var appSettings: BlockchainSettings.App
    var debugCoordinator: DebugCoordinating
    var onboardingSettings: OnboardingSettings
    var cacheSuite: CacheSuite
    var remoteNotificationAuthorizer: RemoteNotificationRegistering
    var remoteNotificationTokenReceiver: RemoteNotificationDeviceTokenReceiving
    var certificatePinner: CertificatePinnerAPI
    var siftService: SiftServiceAPI
    var blurEffectHandler: BlurVisualEffectHandler
    var backgroundAppHandler: BackgroundAppHandler
}

/// The state of the app delegate
struct AppDelegateState: Equatable {
    var window: UIWindow?
}

/// The reducer of the app delegate that describes the effects for each action.
let appDelegateReducer = Reducer<
    AppDelegateState, AppDelegateAction, AppDelegateEnvironment
> { state, action, environment in
    switch action {
    case .didFinishLaunching(let window):
        state.window = window
        return .merge(
            migrateAnnouncements(),
            updateAppBecameActiveCount(appSettings: environment.appSettings),

            environment.remoteNotificationAuthorizer
                .registerForRemoteNotificationsIfAuthorized()
                .asPublisher()
                .eraseToEffect()
                .fireAndForget(),

            applyGlobalNavigationAppearance(using: .lightContent()),

            applyCertificatePinning(using: environment.certificatePinner),

            enableSift(using: environment.siftService),

            enableDebugMenuIfNeeded(
                coordinator: environment.debugCoordinator,
                on: window
            )
        )
    case .willResignActive:
        return applyBlurFilter(
            handler: environment.blurEffectHandler,
            on: state.window
        )
    case .willEnterForeground(let application):
        return .merge(
            .fireAndForget {
                environment.backgroundAppHandler
                    .handleAppEnteredForeground(application)
            },
            updateAppBecameActiveCount(appSettings: environment.appSettings)
        )
    case .didEnterBackground(let application):
        return .fireAndForget {
            environment.backgroundAppHandler
                .handleAppEnteredBackground(application)
        }
    case .handleDelayedEnterBackground:
        return .none
    case .didBecomeActive:
        return .merge(
            removeBlurFilter(
                handler: environment.blurEffectHandler,
                from: state.window
            ),
            Effect.fireAndForget {
                Logger.shared.debug("applicationDidBecomeActive")
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        )
    case .open(let url):
        return .none
    case .didRegisterForRemoteNotifications(let result):
        return Effect.fireAndForget {
            switch result {
            case .success(let data):
                environment.remoteNotificationTokenReceiver
                    .appDidRegisterForRemoteNotifications(with: data)
            case .failure(let error):
                environment.remoteNotificationTokenReceiver
                    .appDidFailToRegisterForRemoteNotifications(with: error)
            }
        }
    case .userActivity(let userActivity):
        return .none
    }
}

// MARK: - Effect Methods

private func applyBlurFilter(handler: BlurVisualEffectHandler, on window: UIWindow?) -> AppDelegateEffect {
    guard let view = window else {
        return .none
    }
    return Effect.fireAndForget {
        handler.applyEffect(on: view)
    }
}

private func removeBlurFilter(handler: BlurVisualEffectHandler, from window: UIWindow?) -> AppDelegateEffect {
    guard let view = window else {
        return .none
    }
    return Effect.fireAndForget {
        handler.removeEffect(from: view)
    }
}

private func applyCertificatePinning(using service: CertificatePinnerAPI) -> AppDelegateEffect {
    Effect.fireAndForget {
        service.pinCertificateIfNeeded()
    }
}

private func enableSift(using service: SiftServiceAPI) -> AppDelegateEffect {
    Effect.fireAndForget {
        service.enable()
    }
}

private func applyGlobalNavigationAppearance(using barStyle: Screen.Style.Bar) -> AppDelegateEffect {
    Effect.fireAndForget {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.isTranslucent = barStyle.isTranslucent
        navigationBarAppearance.titleTextAttributes = barStyle.titleTextAttributes
        navigationBarAppearance.barTintColor = barStyle.backgroundColor
        navigationBarAppearance.tintColor = barStyle.tintColor
    }
}

private func updateAppBecameActiveCount(appSettings: BlockchainSettings.App) -> AppDelegateEffect {
    Effect.fireAndForget {
        appSettings.appBecameActiveCount += 1
    }
}

private func migrateAnnouncements() -> AppDelegateEffect {
    Effect.fireAndForget {
        AnnouncementRecorder.migrate(errorRecorder: CrashlyticsRecorder())
    }
}

private func enableDebugMenuIfNeeded(coordinator: DebugCoordinating, on window: UIWindow) -> AppDelegateEffect {
    #if INTERNAL_BUILD
    return Effect<AppDelegateAction, Never>.fireAndForget {
        coordinator.enableDebugMenu(for: window)
    }
    #else
    return .none
    #endif
}
