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
    var fiatCurrencyCode: String
    var fiatCurrencySymbol: String
    var fix: Fix
    var volume: String
    var lastConversion: Conversion?

    init(pair: TradingPair,
         fiatCurrencyCode: String,
         fiatCurrencySymbol: String,
         fix: Fix,
         volume: String) {
        self.pair = pair
        self.fiatCurrencyCode = fiatCurrencyCode
        self.fiatCurrencySymbol = fiatCurrencySymbol
        self.fix = fix
        self.volume = volume
    }
}

extension MarketsModel {
    var isUsingFiat: Bool {
        return fix == .baseInFiat || fix == .counterInFiat
    }

    var isUsingBase: Bool {
        return fix == .base || fix == .baseInFiat
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

    func toggleFix() {
        fix = fix.toggledFix()
    }
}

extension MarketsModel: Equatable {
    // Do not compare lastConversion
    static func == (lhs: MarketsModel, rhs: MarketsModel) -> Bool {
        return lhs.pair == rhs.pair &&
        lhs.fiatCurrencyCode == rhs.fiatCurrencyCode &&
        lhs.fiatCurrencySymbol == rhs.fiatCurrencySymbol &&
        lhs.fix == rhs.fix &&
        lhs.volume == rhs.volume
    }
}
