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

    @objc let limit: String? // Not currently used on web, so not used for iOS, but added for documentation
    @objc let minimum: String? // Minimum amount required to exchange
    @objc let minerFee: String? // Fee for exchange
    @objc let maxLimit: String? // Maximum amount allowed to exchange, defined by ShapeShift
    @objc let rate: String? // Exchange rate between the 'from' and 'to' asset types
    @objc let hardLimit: String? // Maximum amount allowed to exchange, defined by wallet-options
    @objc let hardLimitRate: String? // Fiat value for the current 'from' asset type

    @objc init(
        limit: String?,
        minimum: String?,
        minerFee: String?,
        maxLimit: String?,
        rate: String?,
        hardLimit: String?,
        hardLimitRate: String?) {
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
            print("Could not create dictionary from JSValue")
            return nil
        }

        /*
         Numeric values inside a JSValue converted to [AnyHashable: Any]! with toDictionary()
         cannot be casted to a string - the following error will print:

         Could not cast value of type '__NSCFNumber' to 'NSString'.

         The documentation for JSValue's toDictionary() says "All enumerable properties of the object
         are copied to the dictionary, with JSValues converted to equivalent Objective-C objects
         as specified."

         Ideally we would specify that the JSValues would be converted to strings to completely eliminate
         any possibility of precision errors.
        */
        let stringFromNumericDictValue = { (_ value: Any?) -> String? in
            guard let number = value as? NSNumber else {
                print("Could not convert dictionary value to NSNumber!")
                return nil
            }
            return NumberFormatter.assetFormatterWithUSLocale.string(from: number)
        }

        self.init(limit: stringFromNumericDictValue(dictionary[Keys.limit]),
                  minimum: stringFromNumericDictValue(dictionary[Keys.minimum]),
                  minerFee: stringFromNumericDictValue(dictionary[Keys.minerFee]),
                  maxLimit: stringFromNumericDictValue(dictionary[Keys.maxLimit]),
                  rate: stringFromNumericDictValue(dictionary[Keys.rate]),
                  hardLimit: stringFromNumericDictValue(dictionary[Keys.hardLimit]),
                  hardLimitRate: stringFromNumericDictValue(dictionary[Keys.hardLimitRate]))
    }
}
