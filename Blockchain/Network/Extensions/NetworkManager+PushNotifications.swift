//
//  NetworkManager+PushNotifications.swift
//  Blockchain
//
//  Created by Maurice A. on 5/4/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension NetworkManager {
    static func registerDeviceForPushNotifications(withDeviceToken token: String) {
        // TODO: test deregistering from the server
        let pushNotificationsUrl = BlockchainAPI.shared.pushNotificationsUrl
        guard let url = URL(string: pushNotificationsUrl),
            let guid = WalletManager.shared.wallet.guid,
            let sharedKey = WalletManager.shared.wallet.sharedKey,
            let payload = PushNotificationAuthPayload(guid: guid, sharedKey: sharedKey, deviceToken: token),
            let body = BlockchainAPI.registerDeviceForPushNotifications(using: payload) else {
                return
        }
        var notificationRequest = URLRequest(url: url)
        notificationRequest.httpMethod = "POST"
        notificationRequest.httpBody = body
        notificationRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        notificationRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = NetworkManager.shared.session.dataTask(with: notificationRequest, completionHandler: { data, response, error in
            guard error == nil else {
                print("Error registering device with backend: %@", error!.localizedDescription)
                return
            }
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    return
            }
            guard
                let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject],
                let success = json!["success"] as? Bool, success == true else {
                    return
            }
        })
        task.resume()
    }
}
