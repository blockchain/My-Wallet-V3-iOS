// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import DIKit
import Errors
import PlatformKit

protocol APIClientAPI {

    func multiAddress(
        for addresses: [XPub]
    ) -> AnyPublisher<BitcoinMultiAddressResponse, NetworkError>

    func unspentOutputs(
        for addresses: [XPub]
    ) -> AnyPublisher<UnspentOutputsResponse, NetworkError>
}

final class APIClient: APIClientAPI {

    private let client: BitcoinChainKit.APIClientAPI

    // MARK: - Init

    init(client: BitcoinChainKit.APIClientAPI = resolve(tag: BitcoinChainCoin.bitcoin)) {
        self.client = client
    }

    // MARK: - APIClientAPI

    func unspentOutputs(
        for addresses: [XPub]
    ) -> AnyPublisher<UnspentOutputsResponse, NetworkError> {
        client.unspentOutputs(for: addresses)
    }

    func multiAddress(
        for addresses: [XPub]
    ) -> AnyPublisher<BitcoinMultiAddressResponse, NetworkError> {
        client.multiAddress(for: addresses)
    }
}
