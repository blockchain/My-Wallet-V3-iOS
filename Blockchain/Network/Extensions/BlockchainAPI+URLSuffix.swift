//
//  BlockchainAPI+URLSuffix.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc extension BlockchainAPI {
    /// Returns the URL for the specified address's asset information (number of transactions,
    /// total sent/received, etc.)
    ///
    /// - Parameter assetAddress: the `AssetAddress`
    /// - Returns: the URL for the `AssetAddress`
    func assetInfoURL(for assetAddress: AssetAddress) -> String? {
        switch assetAddress.assetType {
        case .bitcoin:
            return "\(walletUrl)/address/\(assetAddress.address)?format=json"
        case .bitcoinCash:
            return "\(walletUrl)/bch/multiaddr?active=\(assetAddress.address)"
        default:
            return nil
        }
    }

    /// Returns the URL for the specified address's transaction detail.
    ///
    /// - Parameter transactionHash: the hash of the transaction
    /// - Parameter assetType: the `AssetType`
    /// - Returns: the URL for the transaction detail
    func transactionDetailURL(for transactionHash: String, assetType: AssetType) -> String? {
        switch assetType {
        case .bitcoin:
            return "\(walletUrl)/tx/\(transactionHash)"
        case .ethereum:
            return "\(etherscanUrl)/tx/\(transactionHash)"
        case .bitcoinCash:
            return "\(blockchairUrl)/bitcoin-cash/transaction/\(transactionHash)"
        }
    }
}
