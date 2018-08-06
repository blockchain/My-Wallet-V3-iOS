//
//  WalletExchangeIntermediateDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc protocol WalletExchangeIntermediateDelegate: class {
    /// Method invoked when eth account is created when exchange is opened
    func didCreateEthAccountForExchange()
}
