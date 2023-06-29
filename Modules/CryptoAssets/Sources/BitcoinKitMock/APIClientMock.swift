// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
@testable import BitcoinKit

import Combine
import Errors

class APIClientMock: BitcoinKit.APIClientAPI {
    var multiAddressResult: Result<BitcoinMultiAddressResponse, NetworkError> = .failure(
        NetworkError.unknown
    )

    func multiAddress(
        for addresses: [XPub]
    ) -> AnyPublisher<BitcoinMultiAddressResponse, NetworkError> {
        multiAddressResult
            .publisher
            .eraseToAnyPublisher()
    }

    func unspentOutputs(
        for addresses: [XPub]
    ) -> AnyPublisher<UnspentOutputsResponse, NetworkError> {
        .failure(.unknown)
    }
}
