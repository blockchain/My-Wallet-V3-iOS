//
//  PairType.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum PairType {
    case btcToEth
    case ethToBTC
    
    init?(stringValue: String) {
        switch stringValue {
        case "BTC_ETH",
             "BTC-ETH":
            self = .btcToEth
        case "ETH_BTC",
             "ETH-BTC":
            self = .ethToBTC
        default:
            return nil
        }
    }
}
