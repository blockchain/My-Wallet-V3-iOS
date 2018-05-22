//
//  WalletTransactionDelegate.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for a delegate for transaction-related wallet callbacks
@objc protocol WalletTransactionDelegate: class {

    /// Method invoked when payment was received on the pin screen (i.e. swipe to receive)
    ///
    /// - Parameters:
    ///   - amount: the amount received
    ///   - assetType: the asset type
    func onPaymentReceived(amount: String, assetType: AssetType)

    /// Method invoked when a transaction is received (only invoked when there is an
    /// active websocket connection when the transaction was received)
    func onTransactionReceived()

    /// Method invoked after pushing a transaction to the network
    func didPushTransaction()
}
