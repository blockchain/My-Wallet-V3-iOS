// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftExtensions

// MARK: - Nft

public struct Nft: Codable {
    let next: String?
    let assets: [AssetElement]
}

// MARK: - AssetElement

struct AssetElement: Codable {

    let id: Int
    let backgroundColor: String?
    let imageURL: String?
    let imagePreviewURL: String
    let imageThumbnailURL: String
    let imageOriginalURL: String?
    let animationURL: String?
    let name: String
    let assetDescription: String?
    let assetContract: AssetContract
    let collection: AssetCollectionResponse
    let creator: Creator?
    let traits: [Trait]
    let tokenID: String

    var nftDescription: String {
        (assetDescription ?? collection.collectionDescription) ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case id
        case backgroundColor = "background_color"
        case imageURL = "image_url"
        case imagePreviewURL = "image_preview_url"
        case imageThumbnailURL = "image_thumbnail_url"
        case imageOriginalURL = "image_original_url"
        case animationURL = "animation_url"
        case name
        case assetDescription = "description"
        case collection
        case creator
        case assetContract = "asset_contract"
        case tokenID = "token_id"
        case traits
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

        enum CodingKeys: String, CodingKey {
            case traitType = "trait_type"
            case value
        }
    }
}

// MARK: - AssetContract

struct AssetContract: Codable {
    let address: String
}

// MARK: - Collection

struct AssetCollectionResponse: Codable {
    let bannerImageURL: String?
    let collectionDescription: String?
    let safelistRequestStatus: SafelistRequestStatus?
    let imageURL: String?
    let name: String

    enum CodingKeys: String, CodingKey {
        case bannerImageURL = "banner_image_url"
        case collectionDescription = "description"
        case safelistRequestStatus = "safelist_request_status"
        case imageURL = "image_url"
        case name
    }
}

struct SafelistRequestStatus: NewTypeString, Codable {
    let value: String
    init(_ value: String) { self.value = value }

    static let verified: Self = "verified"
}

// MARK: - Creator

struct Creator: Codable {
    let user: User?
    let address: String
}

// MARK: - User

struct User: Codable {
    let username: String?
}

// MARK: - Value

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
