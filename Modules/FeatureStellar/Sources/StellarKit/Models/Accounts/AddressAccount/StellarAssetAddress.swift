// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

struct StellarAssetAddress: Equatable {
    let publicKey: String
    let cryptoCurrency: CryptoCurrency = .stellar

    init(publicKey: String) {
        self.publicKey = publicKey
    }
}
