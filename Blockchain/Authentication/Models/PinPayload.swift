//
//  PinPayload.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// The payload for authenticating into the wallet using a pin code
@objc class PinPayload: NSObject {
    /// The pin
    let pinCode: String

    /// The key for this pin
    let pinKey: String

    /// The value of the PinStoreKeyPair
    let pinValue: String?

    /// Boolean indicating whether the pin should be persisted locally upon successfully validating
    let persistLocally: Bool

    init(pinCode: String, pinKey: String, persistLocally: Bool = false, pinValue: String? = nil) {
        self.pinCode = pinCode
        self.pinKey = pinKey
        self.persistLocally = persistLocally
        self.pinValue = pinValue
    }

    convenience init(pinCode: String, keyPair: PinStoreKeyPair, persistLocally: Bool = false) {
        self.init(pinCode: pinCode, pinKey: keyPair.key, persistLocally: persistLocally, pinValue: keyPair.value)
    }
}

extension PinPayload {
    var pin: Pin? {
        return Pin(string: pinCode)
    }
}
