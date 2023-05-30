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
