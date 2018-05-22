//
//  WalletHistoryDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 5/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc protocol WalletHistoryDelegate: class {

    /// Method invoked when getting transaction history fails
    func didFailGetHistory(error: String?)

    /// Method invoked after getting ETH transaction history
    func didFetchEthHistory()

    /// Method invoked after getting BCH transaction history
    func didFetchBitcoinCashHistory()
}
