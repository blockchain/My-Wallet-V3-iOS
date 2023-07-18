// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
import Combine
import Errors
import Foundation
import ToolKit

enum TestAPIClientError: Error {
    case testError
}

class APIClientMock: BitcoinChainKit.APIClientAPI {
    var underlyingUnspentOutputs: AnyPublisher<UnspentOutputsResponse, NetworkError> =
        .failure(NetworkError(request: nil, type: .authentication(TestAPIClientError.testError)))

    func multiAddress<T: BitcoinChainHistoricalTransactionResponse>(
        for wallets: [XPub]
    ) -> AnyPublisher<BitcoinChainMultiAddressResponse<T>, NetworkError> {
        .failure(NetworkError(request: nil, type: .authentication(TestAPIClientError.testError)))
    }

    func unspentOutputs(
        for wallets: [XPub]
    ) -> AnyPublisher<UnspentOutputsResponse, NetworkError> {
        underlyingUnspentOutputs
    }

    func push(
        transaction: EncodedBitcoinChainTransaction
    ) -> AnyPublisher<Void, NetworkError> {
        unimplemented()
    }
}
