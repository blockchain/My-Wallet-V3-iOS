//
//  WalletBuySellDelegate.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for a delegate for buy/sell wallet callbacks
protocol WalletBuySellDelegate: class {
    /// Method invoked when trade initiated from buy is completed
    func didCompleteTrade(trade: Trade)

    /// Method invoked when a user requests from inside the web view to see trade details
    func showCompletedTrade(tradeHash: String)
}
