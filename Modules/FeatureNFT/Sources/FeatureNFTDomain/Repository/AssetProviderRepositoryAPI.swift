// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExtensions
import Errors

public protocol AssetProviderRepositoryAPI {
    func fetchAssets(
        address: String,
        network: String?
    ) -> AnyPublisher<Assets, NabuNetworkError>

    func fetchAssetsFromEthereumAddress(
        _ address: String
    ) -> AnyPublisher<AssetPageResponse, NabuNetworkError>

    func fetchAssetsFromEthereumAddress(
        _ address: String,
        pageKey: String
    ) -> AnyPublisher<AssetPageResponse, NabuNetworkError>
}

// MARK: - Preview Helper

public struct PreviewAssetProviderRepository: AssetProviderRepositoryAPI {

    private let assets: AnyPublisher<AssetPageResponse, NabuNetworkError>

    private let assetsV2: AnyPublisher<Assets, NabuNetworkError>

    public init(
        _ assets: AnyPublisher<AssetPageResponse, NabuNetworkError> = .empty(),
        _ assetsV2: AnyPublisher<Assets, NabuNetworkError> = .empty()
    ) {
        self.assets = assets
        self.assetsV2 = assetsV2
    }

    public func fetchAssets(
        address: String,
        network: String?
    ) -> AnyPublisher<Assets, NabuNetworkError> {
        assetsV2
    }

    public func fetchAssetsFromEthereumAddress(
        _ address: String
    ) -> AnyPublisher<AssetPageResponse, NabuNetworkError> {
        assets
    }

    public func fetchAssetsFromEthereumAddress(
        _ address: String,
        pageKey: String
    ) -> AnyPublisher<AssetPageResponse, NabuNetworkError> {
        assets
    }
}
