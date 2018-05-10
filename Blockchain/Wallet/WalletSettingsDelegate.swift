//
//  WalletSettingsDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for a delegate for settings-related wallet callbacks
protocol WalletSettingsDelegate: class {
    
    /// Method invoked when the web view needs to be initialized
    func didChangeLocalCurrency()
}
