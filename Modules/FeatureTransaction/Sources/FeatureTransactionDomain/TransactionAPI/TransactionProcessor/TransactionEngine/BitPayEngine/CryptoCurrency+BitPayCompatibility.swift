// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

extension CryptoCurrency {
    /// Indicates whether the currency supports bit pay transactions
    var supportsBitPay: Bool {
        switch self {
        case .bitcoin,
             .bitcoinCash:
            true
        default:
            false
        }
    }
}
