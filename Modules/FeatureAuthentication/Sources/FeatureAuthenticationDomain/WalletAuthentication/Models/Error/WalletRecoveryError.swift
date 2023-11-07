// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

public enum WalletRecoveryError: LocalizedError, Equatable {
    case restoreFailure(WalletError)

    public var errorDescription: String? {
        switch self {
        case .restoreFailure(let walletError):
            walletError.errorDescription
        }
    }
}
