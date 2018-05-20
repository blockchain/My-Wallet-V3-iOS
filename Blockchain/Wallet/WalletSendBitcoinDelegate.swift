//
//  WalletSendBitcoinDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 5/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for a delegate for Bitcoin and Bitcoin Cash related wallet callbacks
@objc protocol WalletSendBitcoinDelegate: class {

    /// Method invoked after checking for an acceptable amount to be sent
    func didCheckForOverSpending(amount: NSNumber, fee: NSNumber)

    /// Method invoked when sweeping payment (sending all available)
    func didGetMaxFee(fee: NSNumber, amount: NSNumber, dust: NSNumber?, willConfirm: Bool)

    /// Method invoked when getting transaction fee
    func didGetFee(fee: NSNumber, dust: NSNumber?, txSize: NSNumber)

    /// Method invoked when changing fee rate
    func didChangeSatoshiPerByte(sweepAmount: NSNumber, fee: NSNumber, dust: NSNumber?, updateType: FeeUpdateType)

    /// Method invoked when updating a fee fails
    func enableSendPaymentButtons()

    /// Method invoked when changing a payment 'from' to update balance in UI (Bitcoin only)
    func updateSendBalance(balance: NSNumber, fees: NSDictionary)

    /// Method invoked when changing a payment 'from' to update balance in UI (Bitcoin Cash only)
    func didUpdateTotalAvailable(sweepAmount: NSNumber, finalFee: NSNumber)
}
