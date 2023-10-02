// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum ActiveAmountInput {
    case fiat
    case crypto

    var inverted: ActiveAmountInput {
        switch self {
        case .fiat:
            return .crypto
        case .crypto:
            return .fiat
        }
    }
}
