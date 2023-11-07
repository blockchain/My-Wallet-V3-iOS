// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum KYCStatus: Equatable {
    case unverified
    case inReview
    case gold

    public var canSellCrypto: Bool {
        switch self {
        case .unverified, .inReview:
            false
        case .gold:
            true
        }
    }
}
