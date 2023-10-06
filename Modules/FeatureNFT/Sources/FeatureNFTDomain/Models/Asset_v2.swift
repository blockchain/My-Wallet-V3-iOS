// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Assets: Equatable {
    public let nfts: [Asset_v2]

    init(_ model: NftCollection) {
        self.nfts = model.assets.flatMap(\.result).map(Asset_v2.init)
    }
}

public struct Asset_v2: Equatable, Identifiable {

    public var id: String {
        "\(tokenAddress).\(tokenId)"
    }

    public let tokenAddress: String
    public let tokenId: String
    public let creator: String?
    public let name: String?
    public let media: Media_v2?
    public let metadata: AssetMetadata?
    public let possibleSpam: Bool
    public let collectionVerified: Bool
    public let lastSyncDate: String?
}

public struct Media_v2: Equatable {
    public let collection: MediaCollection?
}

public struct MediaCollection: Equatable {
    public let medium: MediaImage
    public let high: MediaImage
}

extension MediaCollection {
    public struct MediaImage: Equatable {
        public let url: String?
    }

    init(_ model: NftMediaCollection) {
        self.medium = MediaImage(url: model.medium.url)
        self.high = MediaImage(url: model.high.url)
    }
}

public struct AssetMetadata: Equatable {
    public let name: String?
    public let description: String?
    public let atributes: [AssetAttribute]?
}

public struct AssetAttribute: Equatable, Hashable, Identifiable {
    public let name: String
    public let value: String

    public var id: String {
        "\(name).\(value)"
    }
}

// MARK: Methods

extension Asset_v2 {
    init(_ model: NftAsset) {
        self.tokenAddress = model.tokenAddress
        self.tokenId = model.tokenId
        self.name = model.name
        self.creator = model.creator
        if let media = model.media {
            self.media = Media_v2(media)
        } else {
            self.media = nil
        }
        if let metadata = model.metadata {
            self.metadata = AssetMetadata(metadata)
        } else {
            self.metadata = nil
        }
        self.possibleSpam = model.possibleSpam
        self.collectionVerified = model.collectionVerified
        self.lastSyncDate = model.lastSyncDate
    }
}

extension Media_v2 {
    init(_ model: NftMedia) {
        if let collection = model.collection {
            self.collection = MediaCollection(collection)
        } else {
            self.collection = nil
        }
    }
}

extension AssetMetadata {
    init(_ model: NftMetadata) {
        self.name = model.nftName
        self.description = model.description
        self.atributes = model.attributes?.map(AssetAttribute.init)
    }
}

extension AssetAttribute {
    init(_ model: NftAttribute) {
        self.name = model.name
        self.value = model.value
    }
}
