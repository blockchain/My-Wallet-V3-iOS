// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit
import UnifiedActivityDomain

struct AuthDataPayload: Encodable {
    let guidHash: String
    let sharedKeyHash: String
}

struct ActivityRequest: Encodable {
    struct Parameters: Encodable {
        let timeZone: String
        let fiatCurrency: String
        let locales: String
    }

    let action: String = "subscribe"
    let channel: Channel = .activity
    let auth: AuthDataPayload
    let params: Parameters
}

struct ActivityDetailsRequest: Encodable {
    struct Parameters: Encodable {
        let timeZone: String
        let locales: String
        let fiatCurrency: String
    }
    let auth: AuthDataPayload
    let localisation: Parameters
    let txId: String
    let network: String
    let pubKey: String
}
