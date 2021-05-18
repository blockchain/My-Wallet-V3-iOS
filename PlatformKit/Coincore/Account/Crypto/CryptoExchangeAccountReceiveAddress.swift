//
//  CryptoExchangeAccountReceiveAddress.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/4/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

struct CryptoExchangeAccountReceiveAddress: CryptoReceiveAddress {
    
    typealias TxCompleted = (TransactionResult) -> Completable
    
    let address: String
    let asset: CryptoCurrency
    let label: String
    let onTxCompleted: TxCompleted
    
    init(asset: CryptoCurrency,
         address: String,
         label: String,
         onTxCompleted: @escaping TxCompleted) {
        self.asset = asset
        self.address = address
        self.label = label
        self.onTxCompleted = onTxCompleted
    }
}
