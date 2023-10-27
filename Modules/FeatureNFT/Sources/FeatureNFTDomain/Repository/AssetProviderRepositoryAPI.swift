// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExtensions
import Errors

public protocol AssetProviderRepositoryAPI {
    func fetchAssets(
        address: String,
        network: String?
    ) -> AnyPublisher<Assets, NetworkError>
}

// MARK: - Preview Helper

public struct PreviewAssetProviderRepository: AssetProviderRepositoryAPI {

    private let assets: AnyPublisher<Assets, NetworkError>

    public init(
        _ assets: AnyPublisher<Assets, NetworkError> = .empty()
    ) {
        self.assets = assets
    }

    public func fetchAssets(
        address: String,
        network: String?
    ) -> AnyPublisher<Assets, NetworkError> {
        assets
    }
}
