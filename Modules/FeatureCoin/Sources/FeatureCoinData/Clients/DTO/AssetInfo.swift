// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AssetInfoResponse: Decodable {
    public let description: String?
    public let whitepaper: String?
    public let website: String?
}
