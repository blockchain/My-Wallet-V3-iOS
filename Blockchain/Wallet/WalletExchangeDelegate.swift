//
//  WalletExchangeDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 5/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc protocol WalletExchangeDelegate: class {

    /// Method invoked when trades have been fetched
    func didGetExchangeTrades(trades: NSArray)

    /// Method invoked when rate has been fetched
    func didGetExchangeRate(rate: NSDictionary)

    /// Method invoked when the BTC balance has been fetched
    func didGetAvailableBtcBalance(result: NSDictionary)

    /// Method invoked when the ETH balance has been fetched
    func didGetAvailableEthBalance(result: NSDictionary)

    /// Method invoked when an exchange trade has been built
    func didBuildExchangeTrade(tradeInfo: NSDictionary)

    /// Method invoked when a shift payment has been submitted
    func didShiftPayment()
}
