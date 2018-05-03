//
//  PasscodePayload.swift
//  Blockchain
//
//  Created by Maurice A. on 4/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Represents a passcode payload used for authenticating the user.
internal struct PasscodePayload {
    let guid: String
    let password: String
    let sharedKey: String

    init(guid: String, password: String, sharedKey: String) {
        self.guid = guid
        self.password = password
        self.sharedKey = sharedKey
    }
}

extension PasscodePayload {
    init(dictionary: [AnyHashable: Any]) {
        self.guid = dictionary["guid"] as! String
        self.sharedKey = dictionary["sharedKey"] as! String
        self.password = dictionary["password"] as! String
    }
}
