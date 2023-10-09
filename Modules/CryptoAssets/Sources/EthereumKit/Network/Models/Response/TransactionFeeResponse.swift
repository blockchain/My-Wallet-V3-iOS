// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct TransactionFeeResponse: Decodable {
    let gasLimit: String
    let gasLimitContract: String
    let normal: String
    let high: String

    enum CodingKeys: String, CodingKey {
        case gasLimit
        case gasLimitContract
        case normal = "NORMAL"
        case high = "HIGH"
    }
}
