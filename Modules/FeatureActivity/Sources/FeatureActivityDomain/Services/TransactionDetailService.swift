// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import NetworkKit
import PlatformKit

public protocol TransactionDetailServiceAPI {

    /// Returns the URL for the specified address's transaction detail.
    ///
    /// - Parameter transactionHash: the hash of the transaction
    /// - Parameter cryptoCurrency: the `CryptoCurrency`
    /// - Returns: the URL for the transaction detail
    func transactionDetailURL(for transactionHash: String, cryptoCurrency: CryptoCurrency) -> String?
}

final class TransactionDetailService: TransactionDetailServiceAPI {

    private let blockchainAPI: BlockchainAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

    init(blockchainAPI: BlockchainAPI, enabledCurrenciesService: EnabledCurrenciesServiceAPI) {
        self.blockchainAPI = blockchainAPI
        self.enabledCurrenciesService = enabledCurrenciesService
    }

    func transactionDetailURL(for transactionHash: String, cryptoCurrency: CryptoCurrency) -> String? {
        switch cryptoCurrency {
        case .bitcoin:
            return "\(blockchainAPI.bitcoinExplorerUrl)/tx/\(transactionHash)"
        case .bitcoinCash:
            return "\(blockchainAPI.bitcoinCashExplorerUrl)/tx/\(transactionHash)"
        case .stellar:
            return "\(blockchainAPI.stellarchainUrl)/tx/\(transactionHash)"
        default:
            break
        }

        if let network = evmNetwork(cryptoCurrency: cryptoCurrency) {
            return "\(network.networkConfig.explorerUrl)/\(transactionHash)"
        }

        return nil
    }

    private func evmNetwork(cryptoCurrency: CryptoCurrency) -> EVMNetwork? {
        enabledCurrenciesService.network(for: cryptoCurrency)
    }
}
