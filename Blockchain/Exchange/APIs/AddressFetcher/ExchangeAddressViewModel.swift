//
//  ExchangeAddressViewModel.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

/// This is temporary as the `SendBitcoinViewController` will likely be deprecated soon.
@objc
final class ExchangeAddressViewModel: NSObject {

    // MARK: - Properties
    
    let cryptoCurrency: CryptoCurrency
    @objc var isExchangeLinked = false
    @objc var isTwoFactorEnabled = false
    @objc var address: String?
    
    // MARK: - Setup

    init(cryptoCurrency: CryptoCurrency) {
        self.cryptoCurrency = cryptoCurrency
    }
    
    @objc var legacyAssetType: LegacyAssetType {
        cryptoCurrency.legacy
    }
}
