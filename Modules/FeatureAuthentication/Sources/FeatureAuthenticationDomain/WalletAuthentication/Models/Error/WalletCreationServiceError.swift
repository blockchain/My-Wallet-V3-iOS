// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

public enum WalletCreationServiceError: LocalizedError, Equatable {
    case creationFailure(WalletCreateError)

    public var errorDescription: String? {
        switch self {
        case .creationFailure(let error):
            error.errorDescription
        }
    }

    public var walletCreateError: WalletCreateError {
        switch self {
        case .creationFailure(let error):
            error
        }
    }
}
