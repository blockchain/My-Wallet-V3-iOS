//
//  WalletAccountInfoAndExchangeRatesDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 5/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Temporary protocol to use in place of a completion handler that would be passed into getAccountInfoAndExchangeRates()
@objc protocol WalletAccountInfoAndExchangeRatesDelegate: class {
    
    /// Method invoked after getting account info and exchange rates on startup
    func didGetAccountInfoAndExchangeRates()
}
