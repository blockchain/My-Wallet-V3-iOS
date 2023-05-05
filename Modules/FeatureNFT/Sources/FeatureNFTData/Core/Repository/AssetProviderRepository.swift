// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureNFTDomain
import Foundation
import NetworkKit
import ToolKit

public final class AssetProviderRepository: AssetProviderRepositoryAPI {

    private let client: FeatureNFTClientAPI

    public init(client: FeatureNFTClientAPI) {
        self.client = client
    }

    // MARK: - AssetProviderRepositoryAPI

    public func fetchAssetsFromEthereumAddress(
        _ address: String
    ) -> AnyPublisher<AssetPageResponse, NabuNetworkError> {
        client
            .fetchAssetsFromEthereumAddress(address)
            .map(AssetPageResponse.init)
            .eraseToAnyPublisher()
    }

    public func fetchAssetsFromEthereumAddress(
        _ address: String,
        pageKey: String
    ) -> AnyPublisher<AssetPageResponse, NabuNetworkError> {
        client
            .fetchAssetsFromEthereumAddress(address, pageKey: pageKey)
            .map(AssetPageResponse.init)
            .eraseToAnyPublisher()
    }
}

extension AssetPageResponse {
    init(_ nft: Nft) {
        self = .init(
            next: nft.next,
            assets: nft.assets.map(Asset.init(response:))
        )
    }
}

extension Asset {
    init(response: AssetElement) {
        self = .init(
            name: response.name,
            creator: response.creator?.user?.username ?? response.creator?.address ?? response.name,
            tokenID: response.tokenID,
            nftDescription: response.nftDescription,
            identifier: "\(response.id)" + ".\(response.tokenID)" + ".\(response.name)",
            contractId: response.assetContract.address,
            collection: .init(response: response.collection),
            // NOTE: Polygon not supported at this time
            network: .ethereum,
            media: .init(response: response),
            traits: response.traits.map(Trait.init(attribute:))
        )
    }
}

extension Asset.Collection {
    init(response: AssetCollectionResponse) {
        self = .init(
            name: response.name,
            isVerified: response.safelistRequestStatus == .verified,
            bannerImageURL: response.bannerImageURL,
            collectionImageURL: response.imageURL,
            collectionDescription: response.collectionDescription
        )
    }
}

extension Asset.Media {
    init(response: AssetElement) {
        self = .init(
            backgroundColor: response.backgroundColor,
            animationURL: response.animationURL,
            bannerImageURL: response.collection.bannerImageURL,
            collectionImageUrl: response.collection.imageURL,
            imageOriginalURL: response.imageOriginalURL ?? response.imageURL,
            imagePreviewURL: response.imagePreviewURL,
            imageThumbnailURL: response.imageThumbnailURL,
            imageURL: response.imageURL
        )
    }
}

extension Asset.Trait {
    init(attribute: AssetElement.Trait) {
        self = .init(
            type: attribute.traitType,
            description: attribute.valueDescription
        )
    }
}
