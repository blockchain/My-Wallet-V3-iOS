//
//  LockboxAsset.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model for an HD asset (i.e. BTC and BCH) in a `Lockbox`
struct LockboxHDAsset: Codable {
    let accounts: [LockboxHDAccount]
}

/// Model for a non-HD asset (i.e. ETH) in a `Lockbox`
struct LockboxSimpleAsset: Codable {
    let accounts: [LockboxSimpleAccount]
}
