// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit

enum EthereumTransactionPushError: Error {
    case noTransactionID
    case networkError(NetworkError)
}

protocol EthereumTransactionPushServiceAPI {

    func push(
        transaction: EthereumTransactionEncoded,
        network: EVMNetworkConfig
    ) -> AnyPublisher<String, EthereumTransactionPushError>
}

final class EthereumTransactionPushService: EthereumTransactionPushServiceAPI {

    private let client: TransactionPushClientAPI

    init(client: TransactionPushClientAPI) {
        self.client = client
    }

    func push(
        transaction: EthereumTransactionEncoded,
        network: EVMNetworkConfig
    ) -> AnyPublisher<String, EthereumTransactionPushError> {
        switch network {
        case .ethereum:
            client.push(transaction: transaction)
                .map(\.txHash)
                .mapError(EthereumTransactionPushError.networkError)
                .eraseToAnyPublisher()
        default:
            client.evmPush(
                transaction: transaction,
                network: network
            )
            .map(\.txId)
            .mapError(EthereumTransactionPushError.networkError)
            .onNil(EthereumTransactionPushError.noTransactionID)
            .eraseToAnyPublisher()
        }
    }
}
