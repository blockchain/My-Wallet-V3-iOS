// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit

/// Service that provides fees to transact EVM tokens.
public protocol EthereumFeeServiceAPI {
    /// Streams a single `EthereumTransactionFee`, representing suggested fee amounts based on mempool.
    /// Never fails, uses default Fee values if network call fails.
    /// - Parameter cryptoCurrency: An EVM Native token or ERC20 token.
    func fees(network: EVMNetwork, contractAddress: String?) -> AnyPublisher<EVMTransactionFee, Never>
}

extension EthereumFeeServiceAPI {

    public func fees(network: EVMNetwork) -> AnyPublisher<EVMTransactionFee, Never> {
        fees(network: network, contractAddress: nil)
    }

    public func fees(network: EVMNetwork, cryptoCurrency: CryptoCurrency) -> AnyPublisher<EVMTransactionFee, Never> {
        fees(network: network, contractAddress: cryptoCurrency.assetModel.kind.erc20ContractAddress)
    }
}

final class EthereumFeeService: EthereumFeeServiceAPI {

    // MARK: - Private Properties

    private let client: TransactionFeeClientAPI

    // MARK: - Init

    init(client: TransactionFeeClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - CryptoFeeServiceAPI

    func fees(network: EVMNetwork, contractAddress: String?) -> AnyPublisher<EVMTransactionFee, Never> {
        client
            .fees(
                network: network.networkConfig,
                contractAddress: contractAddress
            )
            .map { EVMTransactionFee(response: $0, network: network) }
            .replaceError(with: EVMTransactionFee.default(network: network))
            .eraseToAnyPublisher()
    }
}

extension EVMTransactionFee {

    fileprivate init(response: TransactionFeeResponse, network: EVMNetwork) {
        self.init(
            regularMinor: response.normal,
            priorityMinor: response.high,
            gasLimit: response.gasLimit,
            gasLimitContract: response.gasLimitContract,
            network: network
        )
    }
}
