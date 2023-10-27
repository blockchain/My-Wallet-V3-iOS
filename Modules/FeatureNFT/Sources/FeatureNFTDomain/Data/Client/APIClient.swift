// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit

public protocol FeatureNFTClientAPI {
    func fetchAssets(
        address: String,
        network: String?
    ) -> AnyPublisher<NftCollection, NetworkError>
}

public final class APIClient: FeatureNFTClientAPI {

    // MARK: - Private Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - FeatureNFTClientAPI

    public func fetchAssets(
        address: String,
        network: String?
    ) -> AnyPublisher<NftCollection, NetworkError> {
        var query: [URLQueryItem] = []
        if let network {
            query = [URLQueryItem(name: "network", value: network)]
        }
        let request = requestBuilder.get(
            path: "/nft-market-api/nft/v2/account_assets/\(address)",
            parameters: query
        )!
        return networkAdapter.perform(request: request)
    }
}
