// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension OrderDirection {
    var requiresDestinationAddress: Bool {
        switch self {
        case .onChain,
             .toUserKey:
            true
        case .fromUserKey,
             .internal:
            false
        }
    }

    var requiresRefundAddress: Bool {
        switch self {
        case .onChain,
             .fromUserKey:
            true
        case .toUserKey,
             .internal:
            false
        }
    }
}
