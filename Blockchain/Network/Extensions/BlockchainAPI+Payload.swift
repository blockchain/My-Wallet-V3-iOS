//
//  BlockchainAPI+Payload.swift
//  Blockchain
//
//  Created by Maurice A. on 5/3/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension BlockchainAPI {
    static func registerDeviceForPushNotifications(using payload: PushNotificationAuthPayload?) -> Data? {
        guard let payload = payload else { return nil }
        let language = Locale.preferredLanguages.first ?? "en"
        let length = payload.deviceToken.count
        let body = String(
            format: "guid=%@&sharedKey=%@&payload=%@&length=%d&lang=%@",
            payload.guid,
            payload.sharedKey,
            payload.deviceToken,
            length,
            language
        )
        guard let encodedData = body.data(using: String.Encoding.utf8) else { return nil }
        return encodedData
    }
}
