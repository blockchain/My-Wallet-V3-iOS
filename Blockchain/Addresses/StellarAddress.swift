//
//  StellarAddress.swift
//  Blockchain
//
//  Created by kevinwu on 10/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// TODO: convert class to struct once there are no more objc dependents

@objc
public class StellarAddress: NSObject & AssetAddress {

    // MARK: - Properties

    public private(set) var address: String

    public let assetType: AssetType = .stellar

    override public var description: String {
        return address
    }

    // MARK: - Initialization

    public required init(string: String) {
        self.address = string
    }
}
