//
//  Trade.swift
//  Blockchain
//
//  Created by kevinwu on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model for buy-sell trades.
// TODO: integrate with Exchange trades.
struct Trade {

    struct Keys {
        static let created = "createdAt"
        static let receiveAddress = "receiveAddress"
        static let tradeHash = "txHash"
    }

    let date: String
    let hash: String
}
