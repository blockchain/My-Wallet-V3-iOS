// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum CoincoreError: Error, Equatable {
    case failedToInitializeAsset(error: AssetError)
}
