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
    private static var localCurrencyFractionDigits: Int { return 2 }

    // Example: 1234.12
    static var localCurrencyFormatter: NumberFormatter {
        return decimalStyleFormatter(withMinfractionDigits: localCurrencyFractionDigits,
                                     maxfractionDigits: localCurrencyFractionDigits,
                                     usesGroupingSeparator: false)
    }

    // Example: 1,234.12
    static var localCurrencyFormatterWithGroupingSeparator: NumberFormatter {
        return decimalStyleFormatter(withMinfractionDigits: localCurrencyFractionDigits,
                                     maxfractionDigits: localCurrencyFractionDigits,
                                     usesGroupingSeparator: true)
    }

    // Used to create QR code string from amount
    static var localCurrencyFormatterWithUSLocale: NumberFormatter {
        let formatter = localCurrencyFormatter
        formatter.locale = Locale(identifier: Constants.Locales.English.us)
        return formatter
    }

    // MARK: Digital Assets
    private static var assetFractionDigits: Int { return 8 }

    // Example: 1234.12345678
    static var assetFormatter: NumberFormatter {
        return decimalStyleFormatter(withMinfractionDigits: 0,
                                     maxfractionDigits: assetFractionDigits,
                                     usesGroupingSeparator: false)
    }

    // Example: 1,234.12345678
    static var assetFormatterWithGroupingSeparator: NumberFormatter {
        return decimalStyleFormatter(withMinfractionDigits: 0,
                                     maxfractionDigits: assetFractionDigits,
                                     usesGroupingSeparator: true)
    }

    // Used to create QR code string from amount
    static var assetFormatterWithUSLocale: NumberFormatter {
        let formatter = assetFormatter
        formatter.locale = Locale(identifier: Constants.Locales.English.us)
        return formatter
    }
}
