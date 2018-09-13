//
//  AssetAccount.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Describes a Blockchain account for a specific `AssetType`
struct AssetAccount {

    /// The index of this account in the wallet metadata (always 0 for ether)
    let index: Int32

    /// The AssetAddress for this account
    let address: AssetAddress

    /// The balance in this account
    let balance: CLongLong

    /// The name of this account
    let name: String
}
