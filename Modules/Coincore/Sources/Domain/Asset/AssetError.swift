// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum AssetError: LocalizedError, Equatable {
    case initialisationFailed

    public var errorDescription: String? {
        switch self {
        case .initialisationFailed:
            return "Asset initialisation failed."
        }
    }
}
