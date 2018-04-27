//
//  NotificationManager.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/**
 Manager object for push notifications for iOS versions < 10.0.
 */
class LegacyPushNotificationManager {
    static let shared = LegacyPushNotificationManager()

    func requestAuthorization() {
        let notificationSettings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }

    func registerDeviceForPushNotifications() {
        // TODO
    }
}

/**
 Manager object for push notifications
 */
@available(iOS 10.0, *)
@objc
class PushNotificationManager: NSObject {

    static let shared = PushNotificationManager()

    @objc class func sharedInstace() -> PushNotificationManager {
        return shared
    }

    /// UNNotification that is to be presented to the user
    @objc var presentingPushNotification: UNNotification?

    /// Requests permission from the user to grant access to receive push notifications
    func requestAuthorization() {
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.delegate = self
        userNotificationCenter.requestAuthorization(options: [.sound, .alert, .badge]) { _, error in
            guard error == nil else {
                print("Push registration FAILED")
                print("ERROR: \(error!.localizedDescription)")
                return
            }

            print("Push registration success.")
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

@available(iOS 10.0, *)
extension PushNotificationManager: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        presentingPushNotification = notification
    }
}
