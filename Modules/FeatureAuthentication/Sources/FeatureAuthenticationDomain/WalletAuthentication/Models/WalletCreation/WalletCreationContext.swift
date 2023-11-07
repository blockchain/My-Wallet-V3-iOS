// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

// MARK: Wallet Creation

/// Used to determine whether the wallet to be authenticated is new or not
public enum WalletCreationContext: Equatable {
    /// Determines the wallet created is new
    case new
    /// Determines the wallet created through recovery
    case recovery
    /// Determines the wallet already exists and it will be fetched
    case existing

    public var isNew: Bool {
        switch self {
        case .new:
            true
        case .recovery, .existing:
            false
        }
    }
}
