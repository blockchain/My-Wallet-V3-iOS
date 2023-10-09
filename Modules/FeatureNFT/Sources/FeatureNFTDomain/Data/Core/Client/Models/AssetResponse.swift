// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AssetResponse: Decodable {
    let animationURL: URL
    let animationOriginalURL: URL
    let assetContract: AssetContractResponse
    let backgroundColor: String
    let collection: CollectionResponse
    let creator: String
    let nftDescription: String
    let externalLink: String
    let identifier: Int
    let imageOriginalURL: URL
    let imagePreviewURL: URL
    let imageThumbnailURL: URL
    let imageURL: URL?
    let name: String
    let numSales: Int
    let offers: [OfferResponse]
    let owners: [String]
    let permalink: String
    let tokenID: String
    let traits: [String]

    enum CodingKeys: String, CodingKey {
        case animationURL = "animation_url"
        case animationOriginalURL = "animation_original_url"
        case assetContract = "asset_contract"
        case backgroundColor = "background_color"
        case nftDescription = "description"
        case externalLink = "external_link"
        case identifier = "id"
        case imageOriginalURL = "image_original_url"
        case imagePreviewURL = "image_preview_url"
        case imageThumbnailURL = "image_thumbnail_url"
        case imageURL = "image_url"
        case name
        case numSales = "num_sales"
        case creator
        case collection
        case offers
        case owners
        case permalink
        case tokenID = "token_id"
        case traits
    }
}
