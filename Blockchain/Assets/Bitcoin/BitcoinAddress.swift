//
//  BitcoinAddress.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct BitcoinAddress: AssetAddress {

    // MARK: - Properties

    public var description: String!
    public var assetType: AssetType

    // MARK: - Initialization

    public init?(string: String) {
        self.assetType = .bitcoin
        if !isValid(string) { return nil }
        description = string
    }

    // MARK: Public Methods

    public func isValid(_ address: String) -> Bool {
        // TODO: implement validation logic natively
        return WalletManager.shared.wallet.isValidAddress(address, assetType: LegacyAssetType.bitcoin)
    }
}
