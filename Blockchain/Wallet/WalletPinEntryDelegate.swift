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

    /// Method invoked when the Wallet.getAPIPinValue method times out
    func errorGetPinValueTimeout()

    /// Method invoked when the Wallet.getAPIPinValue returns an empty response
    func errorGetPinEmptyResponse()

    /// Method invoked when the Wallet.getAPIPinValue returns an invalid response
    func errorGetPinInvalidResponse()

    /// Method invoked when Wallet.putPin fails
    func errorDidFailPutPin(errorMessage: String)

    /// Method invoked when putPin succeeds
    func putPinSuccess(response: PutPinResponse)

    /// Method invoked when getPin succeeds
    func getPinSuccess(response: GetPinResponse)
}
