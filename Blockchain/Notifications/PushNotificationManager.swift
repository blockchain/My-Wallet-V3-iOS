//
//  NotificationManager.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import UserNotifications

/**
 Manager object for push notifications
 */
class PushNotificationManager: NSObject {

    static let shared = PushNotificationManager()

    @objc class func sharedInstance() -> PushNotificationManager {
        return shared
    }

    /// Requests permission from the user to grant access to receive push notifications
    func requestAuthorization() {
        guard #available(iOS 10.0, *) else {
            requestAuthorizationPreIos10()
            return
        }

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

    /// Processes a received remote notification.
    ///
    /// - Parameters:
    ///   - application: the application receiving the remote notification
    ///   - userInfo: the payload associated with the remote notification
    ///   - fetchCompletionHandler: the completion handler invoked once processing the remote notification is completed
    func processRemoteNotification(
        from application: UIApplication,
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if application.applicationState == .inactive {
            application.applicationIconBadgeNumber += 1
        }
        fetchCompletionHandler(.noData)
    }

    // MARK: - Pre iOS 10 Methods

    private func requestAuthorizationPreIos10() {
        let notificationSettings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }
}
