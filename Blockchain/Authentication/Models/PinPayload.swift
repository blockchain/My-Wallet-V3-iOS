//
//  PinPayload.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// The payload for authenticating into the wallet using a pin code
struct PinPayload {
    let pinCode: String
    let pinKey: String
}
