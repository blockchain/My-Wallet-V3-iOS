//
//  WalletRecoveryDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 5/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc protocol WalletRecoveryDelegate: class {
    
    /// Method invoked when the recovery sequence is completed
    func didRecoverWallet()
    
    /// Method invoked when the recovery sequence fails to complete
    func didFailRecovery()
}
