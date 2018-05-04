//
//  PushNotificationAuthPayload.swift
//  Blockchain
//
//  Created by Maurice A. on 5/4/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct PushNotificationAuthPayload {
    let guid: String!
    let sharedKey: String!
    let deviceToken: String!

    init?(guid: String, sharedKey: String, deviceToken: String) {
        if guid.count == 0 || sharedKey.count == 0 || deviceToken.count == 0 {
            return nil
        }
        self.guid = guid
        self.sharedKey = sharedKey
        self.deviceToken = deviceToken
    }
}
