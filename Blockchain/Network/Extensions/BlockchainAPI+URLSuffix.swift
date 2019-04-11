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

    /// Returns the URL for retrieving chart related information.
    ///
    /// - Parameters:
    ///   - base: base currency (btc, eth, bch, xlm)
    ///   - quote: the fiat currency symbol
    ///   - startDate: unix timestamp of the starting date
    ///   - scale: the scale in seconds
    /// - Returns: the URL for retrieving chart related information
    func chartsURL(for base: String, quote: String, startDate: Int, scale: String) -> String {
        return "\(apiUrl)/price/index-series?base=\(base)&quote=\(quote)&start=\(String(startDate))&scale=\(scale)&omitnull=true"
    }

    /// Returns the URL for the specified address's transaction detail.
    ///
    /// - Parameter transactionHash: the hash of the transaction
    /// - Parameter assetType: the `AssetType`
    /// - Returns: the URL for the transaction detail
    func transactionDetailURL(for transactionHash: String, assetType: AssetType) -> String? {
        switch assetType {
        case .bitcoin:
            return "\(bitcoinExplorerUrl)/tx/\(transactionHash)"
        case .ethereum:
            return "\(etherExplorerUrl)/tx/\(transactionHash)"
        case .bitcoinCash:
            return "\(bitcoinCashExplorerUrl)/tx/\(transactionHash)"
        case .stellar:
            return "\(stellarchainUrl)/tx/\(transactionHash)"
        case .pax:
            // TODO
            fatalError("Not implemented yet")
        }
    }
}
