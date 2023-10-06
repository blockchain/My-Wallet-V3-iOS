// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct NftCollection: Decodable {
    let assets: [NftAssets]
}

struct NftAssets: Decodable {
    let result: [NftAsset]
}

struct NftAsset: Decodable {
    let tokenAddress: String
    let tokenId: String
    let name: String?
    let creator: String?
    let media: NftMedia?
    let metadata: NftMetadata?
    let possibleSpam: Bool
    let collectionVerified: Bool
    let lastSyncDate: String?

    enum CodingKeys: String, CodingKey {
        case tokenAddress = "token_address"
        case tokenId = "token_id"
        case name
        case creator = "owner_of"
        case media
        case metadata = "normalized_metadata"
        case possibleSpam = "possible_spam"
        case collectionVerified = "verified_collection"
        case lastSyncDate = "last_token_uri_sync"
    }

    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<NftAsset.CodingKeys> = try decoder.container(keyedBy: NftAsset.CodingKeys.self)

        self.tokenAddress = try container.decode(String.self, forKey: NftAsset.CodingKeys.tokenAddress)
        self.tokenId = try container.decode(String.self, forKey: NftAsset.CodingKeys.tokenId)
        self.name = try container.decodeIfPresent(String.self, forKey: NftAsset.CodingKeys.name)
        self.creator = try container.decodeIfPresent(String.self, forKey: NftAsset.CodingKeys.creator)
        self.media = try container.decodeIfPresent(NftMedia.self, forKey: NftAsset.CodingKeys.media)
        self.metadata = try container.decodeIfPresent(NftMetadata.self, forKey: NftAsset.CodingKeys.metadata)
        self.possibleSpam = try container.decode(Bool.self, forKey: NftAsset.CodingKeys.possibleSpam)
        self.collectionVerified = try container.decode(Bool.self, forKey: NftAsset.CodingKeys.collectionVerified)
        self.lastSyncDate = try container.decodeIfPresent(String.self, forKey: NftAsset.CodingKeys.lastSyncDate)
    }
}

struct NftMedia: Decodable {
    let collection: NftMediaCollection?
    let mimetype: String?

    enum CodingKeys: String, CodingKey {
        case collection = "media_collection"
        case mimetype
    }

    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<NftMedia.CodingKeys> = try decoder.container(keyedBy: NftMedia.CodingKeys.self)

        self.collection = try container.decodeIfPresent(NftMediaCollection.self, forKey: NftMedia.CodingKeys.collection)
        self.mimetype = try container.decodeIfPresent(String.self, forKey: NftMedia.CodingKeys.mimetype)
    }
}

struct NftMediaCollection: Decodable {
    let medium: NftImage
    let high: NftImage
}

struct NftImage: Decodable {
    let url: String
}

struct NftMetadata: Decodable {
    let nftName: String?
    let description: String?
    let attributes: [NftAttribute]?

    enum CodingKeys: String, CodingKey {
        case nftName = "name"
        case description
        case attributes
    }

    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<NftMetadata.CodingKeys> = try decoder.container(keyedBy: NftMetadata.CodingKeys.self)

        self.nftName = try container.decodeIfPresent(String.self, forKey: NftMetadata.CodingKeys.nftName)
        self.description = try container.decodeIfPresent(String.self, forKey: NftMetadata.CodingKeys.description)
        self.attributes = try container.decodeIfPresent([NftAttribute].self, forKey: NftMetadata.CodingKeys.attributes)
    }
}

struct NftAttribute: Decodable {
    let name: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case name = "trait_type"
        case value
    }

    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<NftAttribute.CodingKeys> = try decoder.container(keyedBy: NftAttribute.CodingKeys.self)

        self.name = try container.decode(String.self, forKey: NftAttribute.CodingKeys.name)
        if let value = try? container.decode(Int.self, forKey: NftAttribute.CodingKeys.value) {
            self.value = "\(value)"
        } else if let value = try? container.decode(String.self, forKey: NftAttribute.CodingKeys.value) {
            self.value = value
        } else {
            self.value = ""
        }
    }
}
