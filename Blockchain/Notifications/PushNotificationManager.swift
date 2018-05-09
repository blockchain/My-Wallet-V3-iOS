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
@available(iOS, deprecated: 10.0, message: "Use PushNotificationManager")
class LegacyPushNotificationManager {
    static let shared = LegacyPushNotificationManager()

    /// Requests permission from the user to grant access to receive push notifications
    func requestAuthorization() {
        let notificationSettings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
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

    /// Requests permission from the user to grant access to receive push notifications
    func requestAuthorization() {
        let userNotificationCenter = UNUserNotificationCenter.current()
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
