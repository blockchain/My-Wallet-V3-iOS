//
//  NumberFormatter+Assets.swift
//  Blockchain
//
//  Created by kevinwu on 5/2/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc
extension NumberFormatter {

    // MARK: Helper functions
    private static func decimalStyleFormatter(withMinfractionDigits minfractionDigits: Int,
                                              maxfractionDigits: Int,
                                              usesGroupingSeparator: Bool) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = usesGroupingSeparator
        formatter.minimumFractionDigits = minfractionDigits
        formatter.maximumFractionDigits = maxfractionDigits
        return formatter
    }

    // MARK: Local Currency
    private static let localCurrencyFractionDigits: Int = 2

    // Example: 1234.12
    static let localCurrencyFormatter: NumberFormatter = {
        return decimalStyleFormatter(withMinfractionDigits: localCurrencyFractionDigits,
                                     maxfractionDigits: localCurrencyFractionDigits,
                                     usesGroupingSeparator: false)
    }()

    // Example: 1,234.12
    static let localCurrencyFormatterWithGroupingSeparator: NumberFormatter = {
        return decimalStyleFormatter(withMinfractionDigits: localCurrencyFractionDigits,
                                     maxfractionDigits: localCurrencyFractionDigits,
                                     usesGroupingSeparator: true)
    }()

    // Used to create QR code string from amount
    static let localCurrencyFormatterWithUSLocale: NumberFormatter = {
        let formatter = decimalStyleFormatter(withMinfractionDigits: localCurrencyFractionDigits,
                                              maxfractionDigits: localCurrencyFractionDigits,
                                              usesGroupingSeparator: false)
        formatter.locale = Locale(identifier: Constants.Locales.englishUS)
        return formatter
    }()

    // MARK: Digital Assets
    private static let assetFractionDigits: Int = 8

    // Example: 1234.12345678
    static let assetFormatter: NumberFormatter = {
        return decimalStyleFormatter(withMinfractionDigits: 0,
                                     maxfractionDigits: assetFractionDigits,
                                     usesGroupingSeparator: false)
    }()

    // Example: 1,234.12345678
    static let assetFormatterWithGroupingSeparator: NumberFormatter = {
        return decimalStyleFormatter(withMinfractionDigits: 0,
                                     maxfractionDigits: assetFractionDigits,
                                     usesGroupingSeparator: true)
    }()

    // Used to create QR code string from amount
    static let assetFormatterWithUSLocale: NumberFormatter = {
        let formatter = decimalStyleFormatter(withMinfractionDigits: 0,
                                              maxfractionDigits: assetFractionDigits,
                                              usesGroupingSeparator: false)
        formatter.locale = Locale(identifier: Constants.Locales.englishUS)
        return formatter
    }()
}
