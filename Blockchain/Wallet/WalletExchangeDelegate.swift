//
//  WalletExchangeDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 10/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc protocol WalletExchangeDelegate: class {
    /// Method invoked when an error is encountered when
    /// building an exchange order
    func didErrorWhileBuildingExchangeOrder(error: String)
}
