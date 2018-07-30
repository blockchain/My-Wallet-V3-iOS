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

    private struct Keys {
        static let created = "createdAt"
        static let receiveAddress = "receiveAddress"
        static let tradeHash = "txHash"
    }

    let date: String
    let hash: String
}

extension Trade {
    init?(dict: [String: String]) {
        guard let tradeHash = dict[Trade.Keys.tradeHash] else {
            Logger.shared.warning("Trade hash not found")
            return nil
        }
        guard let tradeDate = dict[Trade.Keys.created] else {
            Logger.shared.warning("Trade date not found")
            return nil
        }
        hash = tradeHash
        date = tradeDate
    }
}
