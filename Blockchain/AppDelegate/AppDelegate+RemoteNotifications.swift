// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit
#if canImport(Intercom)
import Intercom
#endif
import FeatureWalletConnectDomain

extension AppDelegate {

    struct RemoteNotification: Decodable {
        let url: URL?

        init(decoding userInfo: [AnyHashable: Any]) throws {
            self = try AnyDecoder().decode(RemoteNotification.self, from: userInfo)
        }
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if let notification = try? RemoteNotification(decoding: userInfo),
           let url = notification.url
        {
            app.post(
                event: blockchain.app.process.deep_link,
                context: [blockchain.app.process.deep_link.url: url]
            )
        }

        let pushNotification = Notification(
            name: UIApplication.pushNotificationReceivedNotification,
            userInfo: userInfo
        )
        NotificationCenter.default.post(pushNotification)

        viewStore.send(
            .appDelegate(
                .didReceiveRemoteNotification(
                    application,
                    userInfo: userInfo,
                    completionHandler: completionHandler
                )
            )
        )
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        viewStore.send(
            .appDelegate(
                .didRegisterForRemoteNotifications(
                    .failure(
                        error as NSError
                    )
                )
            )
        )
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        viewStore.send(
            .appDelegate(
                .didRegisterForRemoteNotifications(
                    .success(
                        deviceToken
                    )
                )
            )
        )
        #if canImport(Intercom)
        Intercom.setDeviceToken(deviceToken, failure: nil)
        #endif
        Task(priority: .high) {
            try? await registerWalletConnectEchoClient(deviceToken: deviceToken)
        }
    }
}
