// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import FirebaseMessaging
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import ToolKit
import UserNotifications

/// The class is responsible for receiving notifications and streaming to subscribers
final class RemoteNotificationRelay: NSObject {

    // MARK: - Properties

    private let relay = PassthroughSubject<RemoteNotification.NotificationType, RemoteNotificationEmitterError>()

    private let app: AppProtocol
    private let cacheSuite: CacheSuite
    private let userNotificationCenter: UNUserNotificationCenterAPI
    private let messagingService: FirebaseCloudMessagingServiceAPI
    private let secureChannelNotificationRelay: SecureChannelNotificationRelaying

    // MARK: - Setup

    init(
        app: AppProtocol,
        cacheSuite: CacheSuite,
        userNotificationCenter: UNUserNotificationCenterAPI,
        messagingService: FirebaseCloudMessagingServiceAPI,
        secureChannelNotificationRelay: SecureChannelNotificationRelaying
    ) {
        self.app = app
        self.cacheSuite = cacheSuite
        self.userNotificationCenter = userNotificationCenter
        self.messagingService = messagingService
        self.secureChannelNotificationRelay = secureChannelNotificationRelay
        super.init()
        userNotificationCenter.delegate = self
    }
}

// MARK: - RemoteNotificationEmitting

extension RemoteNotificationRelay: RemoteNotificationEmitting {
    var notification: AnyPublisher<
        RemoteNotification.NotificationType,
        RemoteNotificationEmitterError
    > {
        relay.eraseToAnyPublisher()
    }
}

extension RemoteNotificationRelay: RemoteNotificationBackgroundReceiving {

    func didReceiveRemoteNotification(
        _ userInfo: [AnyHashable: Any],
        onApplicationState applicationState: UIApplication.State,
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        let secureChannelResult = secureChannelNotificationRelay.didReceiveRemoteNotification(
            userInfo,
            onApplicationState: applicationState,
            fetchCompletionHandler: completionHandler
        )
        guard !secureChannelResult else {
            // SecureChannelNotificationRelaying reacted to the given input.
            return
        }
        // SecureChannelNotificationRelaying did not react to the given input.

        updateRemoteConfigState(userInfo: userInfo)
        completionHandler(.noData)
    }

    private func updateRemoteConfigState(userInfo: [AnyHashable: Any]) {
        guard let value = userInfo["CONFIG_STATE"] as? String else {
            return
        }
        guard value == "STALE" else {
            return
        }
        // Update User Defaults
        app.state.set(blockchain.app.configuration.remote.is.stale, to: true)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension RemoteNotificationRelay: UNUserNotificationCenterDelegate {

    /// Use this method to process the user's response to a notification.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        Logger.shared.debug("Notification didReceive: \(userInfo)")

        if secureChannelNotificationRelay.isSecureChannelNotification(userInfo) {
            secureChannelNotificationRelay.didReceiveSecureChannelNotification(userInfo)
        } else {
            messagingService.appDidReceiveMessage(userInfo)
        }
        completionHandler()
    }

    /// If the app is in foreground when a notification arrives, the shared user notification
    /// center calls this method to deliver the notification directly to the app.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        Logger.shared.debug("Notification willPresent: \(userInfo)")
        if secureChannelNotificationRelay.isSecureChannelNotification(userInfo) {
            secureChannelNotificationRelay.didReceiveSecureChannelNotification(userInfo)
            completionHandler([])
        } else {
            messagingService.appDidReceiveMessage(userInfo)
            completionHandler(.defaultPresentationOptions)
        }
    }
}

extension UNNotificationPresentationOptions {
    static let defaultPresentationOptions: UNNotificationPresentationOptions = {
        [.banner, .list, .badge, .sound]
    }()
}
