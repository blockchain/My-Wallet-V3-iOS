//
//  MarketsModel.swift
//  Blockchain
//
//  Created by kevinwu on 9/6/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// State model for interacting with the MarketsService
class MarketsModel {
    var pair: TradingPair
    var fiatCurrency: String
    var fix: Fix
    var volume: Double

    init(pair: TradingPair,
         fiatCurrency: String,
         fix: Fix,
         volume: Double) {
        self.pair = pair
        self.fiatCurrency = fiatCurrency
        self.fix = fix
        self.volume = volume
    }
}
