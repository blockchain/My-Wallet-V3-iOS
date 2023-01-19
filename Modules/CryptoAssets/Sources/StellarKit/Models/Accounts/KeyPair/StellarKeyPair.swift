// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

struct StellarKeyPair {

    let accountID: String
    let publicKey: String
    let privateKey: StellarPrivateKey

    init(accountID: String, publicKey: String, secret: String) {
        self.accountID = accountID
        self.publicKey = publicKey
        self.privateKey = StellarPrivateKey(secret: secret)
    }
}
