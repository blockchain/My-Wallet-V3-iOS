//
//  WalletXlmAccount.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// Model for a XLM account stored in `WalletXlmMetadata`
struct WalletXlmAccount: Codable {
    let publicKey: String
    let label: String?
    let archived: Bool

    init(publicKey: String, label: String?, archived: Bool = false) {
        self.publicKey = publicKey
        self.label = label
        self.archived = archived
    }
}
