//
//  LockboxAccount.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for an account that belongs in a LockboxHDAsset or LockboxSimpleAsset
protocol LockboxAccount: Codable {
    var label: String { get }
    var isArchived: Bool { get }
}

/// Model for an account in a LockboxHDAsset
struct LockboxHDAccount: LockboxAccount {
    enum CodingKeys: String, CodingKey {
        case label = "label"
        case isArchived = "archived"
        case xpubAddress = "xpub"
    }

    let label: String
    let isArchived: Bool
    let xpubAddress: String
}

/// Model for an account in a LockboxSimpleAsset
struct LockboxSimpleAccount: LockboxAccount {
    enum CodingKeys: String, CodingKey {
        case label = "label"
        case isArchived = "archived"
        case address = "addr"
    }

    let label: String
    let isArchived: Bool
    let address: String
}
