//
//  BitcoinAddress.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// TODO: convert class to struct once there are no more objc dependents

@objc
public class BitcoinAddress: NSObject & AssetAddress {

    // MARK: - Properties

    private(set) public var address: String

    public var assetType: AssetType

    override public var description: String {
        return address
    }

    // MARK: - Initialization

    public required init(string: String) {
        self.address = string
        self.assetType = .bitcoin
    }
}

extension BitcoinAddress {
    /// Transforms this BTC address to a `BitcoinCashAddress`
    ///
    /// - Parameter wallet: a Wallet instance
    /// - Returns: the transformed BTC address
    @objc func toBitcoinCashAddress(wallet: Wallet) -> BitcoinCashAddress? {
        guard let bchAddress = wallet.toBitcoinCash(address, includePrefix: false) else {
            return nil
        }
        return BitcoinCashAddress(string: bchAddress)
    }
}
