//
//  AssetAddressFactory.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class AssetAddressFactory {
    /// Creates the appropriate concrete instance of an `AssetAddress` provided an
    /// address string and the desired asset type.
    ///
    /// - Parameters:
    ///   - address: the address of the asset
    ///   - assetType: the type of the asset
    /// - Returns: the concrete AssetAddress
    static func create(fromAddressString address: String, assetType: AssetType) -> AssetAddress {
        switch assetType {
        case .bitcoin:
            return BitcoinAddress(string: address)
        case .bitcoinCash:
            return BitcoinCashAddress(string: address)
        case .ethereum:
            return EthereumAddress(string: address)
        }
    }
}
