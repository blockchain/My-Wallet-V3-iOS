//
//  WalletFiatAtTimeDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 5/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc protocol WalletFiatAtTimeDelegate: class {

    /// Method invoked after getting fiat at time
    func didGetFiatAtTime(fiatAmount: NSNumber, currencyCode: String, assetType: AssetType)

    /// Method invoked when an error occurs while getting fiat at time
    func didErrorWhenGettingFiatAtTime(error: String?)
}
