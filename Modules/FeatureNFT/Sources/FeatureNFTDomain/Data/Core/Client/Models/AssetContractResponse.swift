// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct AssetContractResponse: Decodable {
    let address: String
    let assetContractType: String

    enum CodingKeys: String, CodingKey {
        case address
        case assetContractType = "asset_contract_type"
    }
}
