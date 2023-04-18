// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

// MARK: - Nft

public struct Nft: Codable {
    let next: String?
    let previous: String?
    let assets: [AssetElement]
}

// MARK: - AssetElement

struct AssetElement: Codable {

    var nftDescription: String {
        (assetDescription ?? collection.collectionDescription) ?? ""
    }

    let id: Int
    let backgroundColor: String?
    let imageURL: String?
    let imagePreviewURL: String
    let imageThumbnailURL: String
    let imageOriginalURL: String?
    let animationURL: String?
    let animationOriginalURL: String?
    let name: String
    let assetDescription: String?
    let externalLink: String?
    let assetContract: AssetContract
    let permalink: String
    let collection: AssetCollectionResponse
    let decimals: Int?
    let tokenMetadata: String?
    let owner: Creator
    let creator: Creator?
    let traits: [Trait]
    let isPresale: Bool
    let tokenID: String

    enum CodingKeys: String, CodingKey {
        case id
        case backgroundColor = "background_color"
        case imageURL = "image_url"
        case imagePreviewURL = "image_preview_url"
        case imageThumbnailURL = "image_thumbnail_url"
        case imageOriginalURL = "image_original_url"
        case animationURL = "animation_url"
        case animationOriginalURL = "animation_original_url"
        case name
        case assetDescription = "description"
        case externalLink = "external_link"
        case assetContract = "asset_contract"
        case permalink, collection, decimals
        case tokenMetadata = "token_metadata"
        case owner
        case creator, traits
        case isPresale = "is_presale"
        case tokenID = "token_id"
    }

    // MARK: - Trait

    struct Trait: Codable {

        var valueDescription: String {
            switch value {
            case .double(let double):
                return "\(double)"
            case .string(let string):
                return string
            }
        }

        let traitType: String
        let value: Value
        let maxValue: String?
        let traitCount: Int

        enum CodingKeys: String, CodingKey {
            case traitType = "trait_type"
            case value
            case maxValue = "max_value"
            case traitCount = "trait_count"
        }
    }
}

// MARK: - AssetContract

struct AssetContract: Codable {
    let address: String
    let createdDate: String
    let name: String?
    let schemaName: SchemaName

    enum CodingKeys: String, CodingKey {
        case address
        case createdDate = "created_date"
        case name
        case schemaName = "schema_name"
    }
}

enum SchemaName: String, Codable {
    case cryptopunks = "CRYPTOPUNKS"
    case erc1155 = "ERC1155"
    case erc721 = "ERC721"
}

// MARK: - Collection

struct AssetCollectionResponse: Codable {
    let bannerImageURL: String?
    let createdDate: String
    let defaultToFiat: Bool
    let collectionDescription: String?
    let devBuyerFeeBasisPoints, devSellerFeeBasisPoints: String
    let discordURL: String?
    let externalURL: String?
    let featured: Bool
    let featuredImageURL: String?
    let hidden: Bool
    let safelistRequestStatus: SafelistRequestStatus?
    let imageURL: String?
    let isSubjectToWhitelist: Bool
    let mediumUsername: String?
    let name: String
    let onlyProxiedTransfers: Bool
    let openseaBuyerFeeBasisPoints, openseaSellerFeeBasisPoints: String
    let payoutAddress: String?
    let requireEmail: Bool
    let shortDescription: String?
    let slug: String
    let telegramURL: String?
    let twitterUsername, instagramUsername: String?

    enum CodingKeys: String, CodingKey {
        case bannerImageURL = "banner_image_url"
        case createdDate = "created_date"
        case defaultToFiat = "default_to_fiat"
        case collectionDescription = "description"
        case devBuyerFeeBasisPoints = "dev_buyer_fee_basis_points"
        case devSellerFeeBasisPoints = "dev_seller_fee_basis_points"
        case discordURL = "discord_url"
        case externalURL = "external_url"
        case featured
        case featuredImageURL = "featured_image_url"
        case hidden
        case safelistRequestStatus = "safelist_request_status"
        case imageURL = "image_url"
        case isSubjectToWhitelist = "is_subject_to_whitelist"
        case mediumUsername = "medium_username"
        case name
        case onlyProxiedTransfers = "only_proxied_transfers"
        case openseaBuyerFeeBasisPoints = "opensea_buyer_fee_basis_points"
        case openseaSellerFeeBasisPoints = "opensea_seller_fee_basis_points"
        case payoutAddress = "payout_address"
        case requireEmail = "require_email"
        case shortDescription = "short_description"
        case slug
        case telegramURL = "telegram_url"
        case twitterUsername = "twitter_username"
        case instagramUsername = "instagram_username"
    }
}

enum SafelistRequestStatus: String, Codable {
    case approved
    case disabledTopTrending = "disabled_top_trending"
    case requested
    case notRequested = "not_requested"
    case verified
}

// MARK: - Creator

struct Creator: Codable {
    let user: User?
    let profileImgURL: String
    let address: String

    enum CodingKeys: String, CodingKey {
        case user
        case profileImgURL = "profile_img_url"
        case address
    }
}

// MARK: - User

struct User: Codable {
    let username: String?
}

enum Name: String, Codable {
    case ether = "Ether"
    case wrappedEther = "Wrapped Ether"
}

enum Symbol: String, Codable {
    case eth = "ETH"
    case weth = "WETH"
}

// MARK: - Transaction

struct Transaction: Codable {
    let blockHash, blockNumber: String
    let fromAccount: Creator
    let id: Int
    let timestamp: String
    let toAccount: Creator
    let transactionHash, transactionIndex: String

    enum CodingKeys: String, CodingKey {
        case blockHash = "block_hash"
        case blockNumber = "block_number"
        case fromAccount = "from_account"
        case id, timestamp
        case toAccount = "to_account"
        case transactionHash = "transaction_hash"
        case transactionIndex = "transaction_index"
    }
}

enum Value: Codable {
    case double(Double)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(
            Value.self, DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Wrong type for Value"
            )
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}
