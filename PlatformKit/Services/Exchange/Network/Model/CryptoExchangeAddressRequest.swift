//
//  CryptoExchangeAddressRequest.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/4/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

struct CryptoExchangeAddressRequest: Encodable {
    /// Currency should be the `Currency.code`
    let currency: String
    
    init(currency: CryptoCurrency) {
        self.currency = currency.code
    }
}
