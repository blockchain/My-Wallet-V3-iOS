//
//  InputType.swift
//  Blockchain
//
//  Created by AlexM on 3/14/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

enum InputType: Equatable {
    case fiat
    case nonfiat(CryptoCurrency)
}

extension InputType {
    static func ==(lhs: InputType, rhs: InputType) -> Bool {
        switch (lhs, rhs) {
        case (.fiat, .fiat):
            return true
        case (.nonfiat(let left), .nonfiat(let right)):
            return left == right
        default:
            return false
        }
    }
}

extension InputType {
    var maxIntegerPlaces: Int {
        switch self {
        case .fiat:
            return 6
        case .nonfiat:
            return 5
        }
    }
    
    var maxFractionalPlaces: Int {
        switch self {
        case .fiat:
            return NumberFormatter.localCurrencyFractionDigits
        case .nonfiat(let asset):
            switch asset {
            case .stellar:
                return NumberFormatter.stellarFractionDigits
            case .bitcoin,
                 .bitcoinCash,
                 .ethereum,
                 .pax:
                return NumberFormatter.assetFractionDigits
            }
        }
    }
}
