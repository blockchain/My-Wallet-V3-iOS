// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum CryptoAssetError: Error {
    case noDefaultAccount
    case noAsset
    case addressParseFailure
    case failedToLoadDefaultAccount(Error)
}
