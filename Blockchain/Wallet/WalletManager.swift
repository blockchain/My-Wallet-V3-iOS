//
//  WalletManager.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/**
 Manager object for operations to the Blockchain Wallet.
 */
@objc
class WalletManager: NSObject {
    static let shared = WalletManager()

    // TODO: Replace this with asset-specific wallet architecture
    let wallet: Wallet

    private override init() {
        wallet = Wallet()!
        super.init()
        wallet.delegate = self
    }
}

extension WalletManager: WalletDelegate {
    // TODO: Move all WalletDelegate methods from RootService to here
}
