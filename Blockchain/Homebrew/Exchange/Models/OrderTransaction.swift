//
//  OrderTransaction.swift
//  Blockchain
//
//  Created by kevinwu on 9/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class OrderTransaction: NSObject {
    init(
        legacyAssetType: LegacyAssetType,
        from: String,
        to: String,
        amount: String
        ) {
        self.legacyAssetType = legacyAssetType
        self.from = from
        self.to = to
        self.amount = amount
        super.init()
    }
    let legacyAssetType: LegacyAssetType
    let from: String
    let to: String
    let amount: String
}
