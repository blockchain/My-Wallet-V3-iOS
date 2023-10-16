// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct CollectionResponse: Decodable {
    let bannerImageURL: URL
    let chatURL: URL
    let createdDate: String
    let defaultToFiat: Bool
    let collectionDescription: String
    let discordURL: URL
    let externalURL: URL
    let featured: Bool
    let featuredImageURL: URL
    let hidden: Bool
    let instagramUsername: String
    let name: String
    let paymentTokens: [PaymentToken]
    let payoutAddress: String
    let primaryAssetContracts: [AssetContractResponse]
    let shortDescription: String
    let slug: String
    let stats: [String: Int]
    let twitterUsername: String

    enum CodingKeys: String, CodingKey {
        case bannerImageURL = "banner_image_url"
        case chatURL = "chat_url"
        case createdDate = "created_date"
        case defaultToFiat = "default_to_fiat"
        case collectionDescription = "description"
        case discordURL = "discord_url"
        case externalURL = "external_url"
        case featured
        case featuredImageURL = "featured_image_url"
        case hidden
        case instagramUsername = "instagram_username"
        case name
        case paymentTokens = "payment_tokens"
        case payoutAddress = "payout_address"
        case primaryAssetContracts = "primary_asset_contracts"
        case shortDescription = "short_description"
        case slug
        case stats
        case twitterUsername = "twitter_username"
    }
}
