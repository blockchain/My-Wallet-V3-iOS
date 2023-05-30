// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import EthereumKit
import Foundation
import MoneyKit
import NetworkKit

protocol LatestBlockClientAPI {
    /// Streams the latest block number.
    func latestBlock(
        network: EVMNetworkConfig
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError>
}

final class RPCClient: LatestBlockClientAPI {

    // MARK: - Private Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: BaseRequestBuilder
    private let apiCode: String

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: BaseRequestBuilder,
        apiCode: APICode
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
        self.apiCode = apiCode
    }

    // MARK: - RPCClient

    func latestBlock(
        network: EVMNetworkConfig
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        createAndPerformHexaNumberRPCRequest(
            network: network,
            encodable: BlockNumberRequest()
        )
    }

    private func createAndPerformHexaNumberRPCRequest(
        network: EVMNetworkConfig,
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
        network: EVMNetworkConfig,
        encodable: Encodable
    ) -> Result<NetworkRequest, NetworkError> {
        guard
            let data = try? encodable.data(),
            let nodeURL: String = network.nodeURL,
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
