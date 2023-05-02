// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import Foundation
import MoneyKit
import NetworkKit
import PlatformKit

protocol EstimateGasClientAPI {
    /// Estimate gas (gas limit) of the given ethereum transaction.
    func estimateGas(
        network: EVMNetwork,
        transaction: EthereumJsonRpcTransaction
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError>
}

protocol GetCodeClientAPI {
    /// Get contract code (if any) on the given address.
    func code(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<JsonRpcHexaDataResponse, NetworkError>
}

protocol GetTransactionCountClientAPI {
    /// Get the transaction count (nonce) of a given ethereum address.
    func transactionCount(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError>
}

protocol GetBalanceClientAPI {
    /// Get the ethereum balance of a given ethereum address.
    func balance(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError>
}

final class RPCClient: EstimateGasClientAPI,
    GetBalanceClientAPI,
    GetTransactionCountClientAPI,
    GetCodeClientAPI
{

    // MARK: - Private Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: BaseRequestBuilder
    private let apiCode: String

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(),
        requestBuilder: BaseRequestBuilder = resolve(),
        apiCode: APICode = resolve()
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
        self.apiCode = apiCode
    }

    // MARK: - RPCClient

    func balance(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        createAndPerformHexaNumberRPCRequest(
            network: network,
            encodable: GetBalanceRequest(address: address)
        )
    }

    func transactionCount(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        createAndPerformHexaNumberRPCRequest(
            network: network,
            encodable: GetTransactionCountRequest(address: address)
        )
    }

    func estimateGas(
        network: EVMNetwork,
        transaction: EthereumJsonRpcTransaction
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        createAndPerformHexaNumberRPCRequest(
            network: network,
            encodable: EstimateGasRequest(transaction: transaction)
        )
    }

    func code(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<JsonRpcHexaDataResponse, NetworkError> {
        createAndPerformHexaDataRPCRequest(
            network: network,
            encodable: GetCodeRequest(address: address)
        )
    }

    private func createAndPerformHexaDataRPCRequest(
        network: EVMNetwork,
        encodable: Encodable
    ) -> AnyPublisher<JsonRpcHexaDataResponse, NetworkError> {
        rpcRequest(network: network, encodable: encodable)
            .publisher
            .flatMap { [networkAdapter] networkRequest in
                networkAdapter.perform(request: networkRequest)
            }
            .eraseToAnyPublisher()
    }

    private func createAndPerformHexaNumberRPCRequest(
        network: EVMNetwork,
        encodable: Encodable
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        rpcRequest(network: network, encodable: encodable)
            .publisher
            .flatMap { [networkAdapter] networkRequest in
                networkAdapter.perform(request: networkRequest)
            }
            .eraseToAnyPublisher()
    }

    private func rpcRequest(
        network: EVMNetwork,
        encodable: Encodable
    ) -> Result<NetworkRequest, NetworkError> {
        guard
            let data = try? encodable.data(),
            let nodeURL: String = network.networkConfig.nodeURL,
            let url = URL(string: nodeURL)
        else {
            return .failure(NetworkError(request: nil, type: .payloadError(.emptyData)))
        }
        guard let request = requestBuilder.post(
            networkConfig: Network.Config(scheme: url.scheme, host: url.host ?? "", components: url.pathComponents),
            path: nil,
            body: data
        ) else {
            return .failure(NetworkError(request: nil, type: .payloadError(.emptyData)))
        }
        return .success(request)
    }
}
