// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import stellarsdk

enum StellarAccountError: Error {
    case unableToSaveNewAccount
}

enum StellarNetworkError: Error {
    case notFound
    case parsingFailed
    case destinationRequiresMemo
    case horizonRequestError(Error)
}

extension HorizonRequestError {
    var stellarNetworkError: StellarNetworkError {
        switch self {
        case .notFound:
            .notFound
        case .parsingResponseFailed:
            .parsingFailed
        default:
            .horizonRequestError(self)
        }
    }
}
