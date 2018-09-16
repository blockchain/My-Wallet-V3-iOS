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
    var volume: String
    var lastConversion: Conversion?

    init(pair: TradingPair,
         fiatCurrency: String,
         fix: Fix,
         volume: String) {
        self.pair = pair
        self.fiatCurrency = fiatCurrency
        self.fix = fix
        self.volume = volume
    }
}

extension MarketsModel {
    var isUsingFiat: Bool {
        return fix == .baseInFiat || fix == .counterInFiat
    }

    func toggleFiatInput() {
        switch fix {
        case .base:
            fix = .baseInFiat
        case .baseInFiat:
            fix = .base
        case .counter:
            fix = .counterInFiat
        case .counterInFiat:
            fix = .counter
        }
    }
}

extension MarketsModel: Equatable {
    // Do not compare lastConversion
    static func == (lhs: MarketsModel, rhs: MarketsModel) -> Bool {
        return lhs.pair == rhs.pair &&
        lhs.fiatCurrency == rhs.fiatCurrency &&
        lhs.fix == rhs.fix &&
        lhs.volume == rhs.volume
    }
}
