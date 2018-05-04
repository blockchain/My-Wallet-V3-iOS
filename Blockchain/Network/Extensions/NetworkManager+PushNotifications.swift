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
        guard
            let pushNotificationsUrl = BlockchainAPI.shared.pushNotificationsUrl,
            let url = URL(string: pushNotificationsUrl),
            let guid = WalletManager.shared.wallet.guid,
            let sharedKey = WalletManager.shared.wallet.sharedKey,
            let payload = BlockchainAPI.registerDeviceForPushNotificationsPayload(guid, sharedKey, token) else {
                return
        }
        var notificationRequest = URLRequest(url: url)
        notificationRequest.httpMethod = "POST"
        notificationRequest.httpBody = payload
        notificationRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        notificationRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = NetworkManager.shared.session.dataTask(with: notificationRequest, completionHandler: { _, response, error in
            guard error == nil else {
                print("Error registering device with backend: %@", error!.localizedDescription)
                return
            }
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    return
            }
        })
        task.resume()
    }
}
