// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import DIKit
import Errors
import NetworkKit
import PlatformKit

enum APIClientError: Error {
    case unknown
}

protocol APIClientAPI {

    func multiAddress(for wallets: [XPub]) -> AnyPublisher<BitcoinCashMultiAddressResponse, NetworkError>

    func dust() -> AnyPublisher<BchDustResponse, NetworkError>
}

final class APIClient: APIClientAPI {

    private let client: BitcoinChainKit.APIClientAPI
    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Init

    init(
        client: BitcoinChainKit.APIClientAPI = resolve(tag: BitcoinChainCoin.bitcoinCash),
        requestBuilder: RequestBuilder = resolve(),
        networkAdapter: NetworkAdapterAPI = resolve()
    ) {
        self.client = client
        self.requestBuilder = requestBuilder
        self.networkAdapter = networkAdapter
    }

    // MARK: - APIClientAPI

    func multiAddress(
        for wallets: [XPub]
    ) -> AnyPublisher<BitcoinCashMultiAddressResponse, NetworkError> {
        client.multiAddress(for: wallets)
    }

    func dust() -> AnyPublisher<BchDustResponse, NetworkError> {
        let request = requestBuilder.get(
            path: "/bch/dust"
        )!
        return networkAdapter.perform(request: request)
    }
}
