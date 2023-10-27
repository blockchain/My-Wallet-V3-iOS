// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import NetworkKit

public final class AssetProviderRepository: AssetProviderRepositoryAPI {

    private let client: FeatureNFTClientAPI

    public init(client: FeatureNFTClientAPI) {
        self.client = client
    }

    // MARK: - AssetProviderRepositoryAPI

    public func fetchAssets(
        address: String,
        network: String?
    ) -> AnyPublisher<Assets, NetworkError> {
        client.fetchAssets(
            address: address,
            network: network
        )
        .map(Assets.init)
        .eraseToAnyPublisher()
    }
}
