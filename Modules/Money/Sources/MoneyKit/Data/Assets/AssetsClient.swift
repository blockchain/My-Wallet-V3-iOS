// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

protocol AssetsClientAPI {
    var coinAssets: AnyPublisher<AssetsResponse, NetworkError> { get }
    var custodialAssets: AnyPublisher<AssetsResponse, NetworkError> { get }
    var ethereumERC20Assets: AnyPublisher<AssetsResponse, NetworkError> { get }
    var otherERC20Assets: AnyPublisher<AssetsResponse, NetworkError> { get }
    var networkConfig: AnyPublisher<NetworkConfigResponse, NetworkError> { get }
}

final class AssetsClient: AssetsClientAPI {

    // MARK: Properties

    var coinAssets: AnyPublisher<AssetsResponse, NetworkError> {
        networkAdapter.perform(
            request: requestBuilder.get(path: "/assets/currencies/coin")!
        )
    }

    var custodialAssets: AnyPublisher<AssetsResponse, NetworkError> {
        networkAdapter.perform(
            request: requestBuilder.get(path: "/assets/currencies/custodial")!
        )
    }

    var ethereumERC20Assets: AnyPublisher<AssetsResponse, NetworkError> {
        networkAdapter.perform(
            request: requestBuilder.get(path: "/assets/currencies/erc20")!
        )
    }

    var otherERC20Assets: AnyPublisher<AssetsResponse, NetworkError> {
        networkAdapter.perform(
            request: requestBuilder.get(path: "/assets/currencies/other_erc20")!
        )
    }

    var networkConfig: AnyPublisher<NetworkConfigResponse, NetworkError> {
        networkAdapter.perform(
            request: requestBuilder.get(path: "/network-config/")!
        )
    }

    // MARK: Private Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: Init

    init(
        requestBuilder: RequestBuilder,
        networkAdapter: NetworkAdapterAPI
    ) {
        self.requestBuilder = requestBuilder
        self.networkAdapter = networkAdapter
    }
}
