// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct PaymentToken: Decodable {
    let address: String
    let ethPrice: String
    let imageURL: String
    let name: String
    let symbol: String
    let usdPrice: String

    enum CodingKeys: String, CodingKey {
        case address
        case ethPrice = "eth_price"
        case imageURL = "image_url"
        case name
        case symbol
        case usdPrice = "usd_price"
    }
}
