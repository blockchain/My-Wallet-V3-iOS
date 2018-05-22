//
//  WalletWatchOnlyDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 5/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc protocol WalletWatchOnlyDelegate: class {
    
    /// Method invoked after scanning private key to send from watch-only address
    func sendFromWatchOnlyAddress()
}
