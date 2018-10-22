//
//  WalletXlmMetadata.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model for the XLM metadata that is stored in the wallet metadata
struct WalletXlmMetadata: Codable {

    enum CodingKeys: String, CodingKey {
        case defaultAccountIndex = "default_account_idx"
        case accounts = "accounts"
    }

    let defaultAccountIndex: Int
    let accounts: [WalletXlmAccount]
}
