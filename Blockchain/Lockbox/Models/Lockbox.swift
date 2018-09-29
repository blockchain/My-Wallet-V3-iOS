//
//  Lockbox.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model for a hardware device (aka "lockbox") that has been synced with a Blockchain Wallet.
struct Lockbox: Codable {

    enum CodingKeys: String, CodingKey {
        case deviceName = "device_name"
        case deviceType = "device_type"
        case btcAccount = "btc"
        case bchAccount = "bch"
        case ethAccount = "eth"
    }

    let deviceName: String
    let deviceType: LockboxDeviceType
    let btcAccount: LockboxHDAsset
    let bchAccount: LockboxHDAsset
    let ethAccount: LockboxSimpleAsset
}
