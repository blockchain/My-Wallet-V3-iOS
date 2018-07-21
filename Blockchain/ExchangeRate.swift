//
//  ExchangeRate.swift
//  Blockchain
//
//  Created by kevinwu on 7/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

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

    private init(
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
    convenience init(json: JSON) {
        self.init(limit: json[Keys.limit] as? String,
                  minimum: json[Keys.minimum] as? String,
                  minerFee: json[Keys.minerFee] as? String,
                  maxLimit: json[Keys.maxLimit] as? String,
                  rate: json[Keys.rate] as? String,
                  hardLimit: json[Keys.hardLimit] as? String,
                  hardLimitRate: json[Keys.hardLimitRate] as? String)
    }
}

@objc extension ExchangeRate {
    class func limitKey() -> String { return Keys.limit }
    class func minimumKey() -> String { return Keys.minimum }
    class func minerFeeKey() -> String { return Keys.minerFee }
    class func maxLimitKey() -> String { return Keys.maxLimit }
    class func rateKey() -> String { return Keys.rate }
    class func hardLimitKey() -> String { return Keys.hardLimit }
    class func hardLimitRateKey() -> String { return Keys.hardLimitRate }
}
