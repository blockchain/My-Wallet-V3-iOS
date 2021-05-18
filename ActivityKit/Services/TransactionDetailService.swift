//
//  TransactionDetailService.swift
//  ActivityKit
//
//  Created by Dimitrios Chatzieleftheriou on 24/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import NetworkKit

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
    
    init(blockchainAPI: BlockchainAPI = resolve()) {
        self.blockchainAPI = blockchainAPI
    }
    
    func transactionDetailURL(for transactionHash: String, cryptoCurrency: CryptoCurrency) -> String? {
        switch cryptoCurrency {
        case .algorand, .polkadot:
            return nil
        case .bitcoin:
            return "\(blockchainAPI.bitcoinExplorerUrl)/tx/\(transactionHash)"
        case .ethereum:
            return "\(blockchainAPI.etherExplorerUrl)/tx/\(transactionHash)"
        case .bitcoinCash:
            return "\(blockchainAPI.bitcoinCashExplorerUrl)/tx/\(transactionHash)"
        case .stellar:
            return "\(blockchainAPI.stellarchainUrl)/tx/\(transactionHash)"
        case .aave, .pax, .tether, .wDGLD, .yearnFinance:
            return "\(blockchainAPI.etherExplorerUrl)/tx/\(transactionHash)"
        }
    }
}
