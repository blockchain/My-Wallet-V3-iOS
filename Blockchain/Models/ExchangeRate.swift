//
//  ExchangeRate.swift
//  Blockchain
//
//  Created by kevinwu on 7/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import JavaScriptCore

/// Used to return exchange information from the ShapeShift API and wallet-options to the ExchangeCreateViewController.
@objc class ExchangeRate: NSObject {

    private struct Keys {
        static let limit = "limit"
        static let minimum = "minimum"
        static let minerFee = "minerFee"
        static let maxLimit = "maxLimit"
        static let rate = "rate"
        static let hardLimit = "hardLimit"
        static let hardLimitRate = "hardLimitRate"
    }

    @objc let limit: NSDecimalNumber? // Not currently used on web, so not used for iOS, but added for documentation
    @objc let minimum: NSDecimalNumber? // Minimum amount required to exchange
    @objc let minerFee: NSDecimalNumber? // Fee for exchange
    @objc let maxLimit: NSDecimalNumber? // Maximum amount allowed to exchange, defined by ShapeShift
    @objc let rate: NSDecimalNumber? // Exchange rate between the 'from' and 'to' asset types
    @objc let hardLimit: NSDecimalNumber? // Maximum amount allowed to exchange, defined by wallet-options
    @objc let hardLimitRate: NSDecimalNumber? // Fiat value for the current 'from' asset type

    @objc init(
        limit: NSDecimalNumber?,
        minimum: NSDecimalNumber?,
        minerFee: NSDecimalNumber?,
        maxLimit: NSDecimalNumber?,
        rate: NSDecimalNumber?,
        hardLimit: NSDecimalNumber?,
        hardLimitRate: NSDecimalNumber?) {
        self.limit = limit
        self.minimum = minimum
        self.minerFee = minerFee
        self.maxLimit = maxLimit
        self.rate = rate
        self.hardLimit = hardLimit
        self.hardLimitRate = hardLimitRate
    }
}

@objc extension ExchangeRate {
    convenience init?(javaScriptValue: JSValue) {
        guard let dictionary = javaScriptValue.toDictionary() else {
            Logger.shared.error("Could not create dictionary from JSValue")
            return nil
        }

        let convertToDecimalNumber = { (value: Any?) -> NSDecimalNumber? in
            guard let number = value as? NSNumber else {
                Logger.shared.error("Could not create NSNumber from dictionary value")
                return nil
            }
            return NSDecimalNumber(decimal: number.decimalValue)
        }

        self.init(limit: convertToDecimalNumber(dictionary[Keys.limit]),
                  minimum: convertToDecimalNumber(dictionary[Keys.minimum]),
                  minerFee: convertToDecimalNumber(dictionary[Keys.minerFee]),
                  maxLimit: convertToDecimalNumber(dictionary[Keys.maxLimit]),
                  rate: convertToDecimalNumber(dictionary[Keys.rate]),
                  hardLimit: convertToDecimalNumber(dictionary[Keys.hardLimit]),
                  hardLimitRate: convertToDecimalNumber(dictionary[Keys.hardLimitRate]))
    }
}
