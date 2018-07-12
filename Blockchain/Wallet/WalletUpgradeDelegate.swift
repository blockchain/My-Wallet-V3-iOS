//
//  WalletUpgradeDelegate.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for a delegate for Bitcoin and Bitcoin Cash related wallet callbacks
@objc protocol WalletUpgradeDelegate: class {
    
    /// Method invoked when the user's wallet has been upgrade from V2 to V3
    func onWalletUpgraded()
}
