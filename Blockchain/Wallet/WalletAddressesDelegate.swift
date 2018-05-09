//
//  WalletAddressesDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 5/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for a delegate for addresses-related wallet callbacks
@objc protocol WalletAddressesDelegate: class {
    
    /// Method invoked when generating a new address (V2/legacy wallet only)
    func didGenerateNewAddress()

    /// Method invoked when finding a null account or address when checking if archived
    func returnToAddressesScreen()
}
