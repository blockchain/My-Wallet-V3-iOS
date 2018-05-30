//
//  EthereumAddress.swift
//  Blockchain
//
//  Created by Maurice A. on 5/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// TODO: convert class to struct once there are no more objc dependents

@objc
class EthereumAddress: NSObject & AssetAddress {

    // MARK: - Properties

    private(set) var address: String

    var assetType: AssetType

    override var description: String {
        return address
    }

    // MARK: - Initialization

    public required init(string: String) {
        self.address = string
        self.assetType = .ethereum
    }
}
