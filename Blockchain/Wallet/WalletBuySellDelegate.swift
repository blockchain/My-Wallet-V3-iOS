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

    /// Method invoked when the web view needs to be initialized
    func initializeWebView()
}
