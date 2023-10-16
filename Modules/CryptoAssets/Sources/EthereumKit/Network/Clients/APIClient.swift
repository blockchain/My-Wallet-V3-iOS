// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import NetworkKit
import PlatformKit

protocol TransactionPushClientAPI: AnyObject {

    /// Pushes a Ethereum transaction.
    func push(
        transaction: EthereumTransactionEncoded
    ) -> AnyPublisher<EthereumPushTxResponse, NetworkError>

    /// Pushes a EVM transaction
    func evmPush(
        transaction: EthereumTransactionEncoded,
        network: EVMNetworkConfig
    ) -> AnyPublisher<EVMPushTxResponse, NetworkError>
}

protocol TransactionFeeClientAPI {

    func fees(
        network: EVMNetworkConfig,
        contractAddress: String?
    ) -> AnyPublisher<TransactionFeeResponse, NetworkError>
}

final class APIClient: TransactionPushClientAPI, TransactionFeeClientAPI {

    // MARK: - Types

    /// Privately used endpoint data
    private enum Endpoint {

        static func fees(network: EVMNetworkConfig) -> String {
            "/currency/evm/fees/\(network.networkTicker)"
        }

        static var pushTx: String {
            "/eth/pushtx"
        }

        static var pushTxEVM: String {
            "/currency/evm/pushTx"
        }
    }

    // MARK: - Private Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder
    private let apiCode: String

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(),
        requestBuilder: RequestBuilder = resolve(),
        apiCode: APICode = resolve()
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
        self.apiCode = apiCode
    }

    func fees(
        network: EVMNetworkConfig,
        contractAddress: String?
    ) -> AnyPublisher<TransactionFeeResponse, NetworkError> {
        var parameters: [URLQueryItem] = []
        if let contractAddress {
            parameters.append(URLQueryItem(name: "identifier", value: contractAddress))
        }
        let request = requestBuilder.get(
            path: Endpoint.fees(network: network),
            parameters: parameters
        )!
        return networkAdapter.perform(request: request)
    }

    func push(
        transaction: EthereumTransactionEncoded
    ) -> AnyPublisher<EthereumPushTxResponse, NetworkError> {
        let body = PushTxRequest(
            rawTx: transaction.rawTransaction,
            network: "ETH",
            api_code: apiCode
        )
        let request = requestBuilder.post(
            path: Endpoint.pushTx,
            body: try? body.encode(),
            recordErrors: true
        )!
        return networkAdapter.perform(request: request)
    }

    func evmPush(
        transaction: EthereumTransactionEncoded,
        network: EVMNetworkConfig
    ) -> AnyPublisher<EVMPushTxResponse, NetworkError> {
        let body = PushTxRequest(
            rawTx: transaction.rawTransaction,
            network: network.networkTicker,
            api_code: apiCode
        )
        let request = requestBuilder.post(
            path: Endpoint.pushTxEVM,
            body: try? body.encode(),
            recordErrors: true
        )!
        return networkAdapter.perform(request: request)
    }
}
