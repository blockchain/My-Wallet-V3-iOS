//
//  StellarAccount.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct StellarAccount {
    let identifier: String
    var assetAccounts: [AssetAccount]
    
    init(identifier: String, accounts: [AssetAccount] = []) {
        self.identifier = identifier
        self.assetAccounts = accounts
    }
}
