//
//  StellarAccount.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct StellarAccount {
    /// The account ID
    let identifier: String

    /// The asset account
    let assetAccount: AssetAccount
    
    // Sequence is used when submitting a transaction
    // from the user's account.
    // [Read more here:](https://www.stellar.org/developers/guides/concepts/fees.html#minimum-account-balance " Minimum Account Balance")
    let sequence: Int
    
    let subentryCount: Int
}

extension StellarAccount {
    static func unfundedAccount(accountId: String) -> StellarAccount {
        let assetAddress = AssetAddressFactory.create(
            fromAddressString: accountId,
            assetType: .stellar
        )
        let assetAccount = AssetAccount(
            index: 0,
            address: assetAddress,
            balance: 0,
            name: LocalizationConstants.Stellar.defaultLabelName
        )
        return StellarAccount(
            identifier: accountId,
            assetAccount: assetAccount,
            sequence: 0,
            subentryCount: 0
        )
    }
}
