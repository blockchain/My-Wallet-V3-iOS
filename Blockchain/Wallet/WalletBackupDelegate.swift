//
//  WalletBackupDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 5/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc protocol WalletBackupDelegate: class {
    
    /// Method invoked when backup sequence is completed
    func didBackupWallet()
    
    /// Method invoked when backup attempt fails
    func didFailBackupWallet()
}
