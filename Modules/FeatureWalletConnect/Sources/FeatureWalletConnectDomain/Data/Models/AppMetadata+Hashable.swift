// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Web3Wallet

extension AppMetadata: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(url)
        hasher.combine(description)
    }
}

extension AuthRequest: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(payload)
    }
}

extension AuthPayload: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(nonce)
        hasher.combine(version)
        hasher.combine(aud)
        hasher.combine(chainId)
        hasher.combine(domain)
    }
}
