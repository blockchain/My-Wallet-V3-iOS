// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExtensions
import Errors

public protocol AssetProviderRepositoryAPI {
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

    public init(_ assets: AnyPublisher<AssetPageResponse, NabuNetworkError> = .empty()) {
        self.assets = assets
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
