// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct OfferResponse: Decodable {
    let bidAmount: String
    let collectionSlug: String
    let contractAddress: String
    let createdDate: String
    let devSellerFeeBasisPoints: Int
    let eventType: String
    let identifier: Int
    let quantity: String

    enum CodingKeys: String, CodingKey {
        case bidAmount = "bid_amount"
        case collectionSlug = "collection_slug"
        case contractAddress = "contract_address"
        case createdDate = "created_date"
        case devSellerFeeBasisPoints = "dev_seller_fee_basis_points"
        case eventType = "event_type"
        case identifier = "id"
        case quantity
    }
}
