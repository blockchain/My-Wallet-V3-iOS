//
//  WalletPinEntryDelegate.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for a delegate for pin entry-related wallet callbacks
protocol WalletPinEntryDelegate: class {

    /// Method invoked when Wallet.putPin fails
    func errorDidFailPutPin(errorMessage: String)

    /// Method invoked when putPin succeeds
    func putPinSuccess(response: PutPinResponse)
}
