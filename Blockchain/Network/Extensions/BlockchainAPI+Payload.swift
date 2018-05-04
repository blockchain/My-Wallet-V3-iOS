//
//  BlockchainAPI+Payload.swift
//  Blockchain
//
//  Created by Maurice A. on 5/3/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension BlockchainAPI {
    static func registerDeviceForPushNotificationsPayload(_ guid: String, _ sharedKey: String, _ deviceToken: String) -> Data? {
        guard guid.count > 0 && sharedKey.count > 0 && deviceToken.count > 0 else { return nil }
        let language = Locale.preferredLanguages.first ?? "en"
        let length = deviceToken.count
        let payload = String(format: "guid=%@&sharedKey=%@&payload=%@&length=%d&lang=%@", guid, sharedKey, deviceToken, length, language)
        guard let encodedData = payload.data(using: String.Encoding.utf8) else { return nil }
        return encodedData
    }
}
