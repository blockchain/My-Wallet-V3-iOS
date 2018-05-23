//
//  WalletSwipeAddressDelegate.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for the delegate related to swipe to receive addresses
protocol WalletSwipeAddressDelegate: class {

    /// Method invoked when swipe to receive addresses has been retrieved.
    ///
    /// - Parameters:
    ///   - addresses: the addresses
    ///   - assetType: the type of the asset for the retrieved addresses
    func onRetrievedSwipeToReceive(addresses: [Any], assetType: AssetType)
}
