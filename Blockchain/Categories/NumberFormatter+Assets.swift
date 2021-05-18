//
//  NumberFormatter+Assets.swift
//  Blockchain
//
//  Created by kevinwu on 5/2/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import ToolKit

@objc
extension NumberFormatter {

    // MARK: Helper functions
    static func decimalStyleFormatter(
        withMinfractionDigits minfractionDigits: Int,
        maxfractionDigits: Int,
        usesGroupingSeparator: Bool
    ) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = usesGroupingSeparator
        formatter.minimumFractionDigits = minfractionDigits
        formatter.maximumFractionDigits = maxfractionDigits
        formatter.roundingMode = .down
        return formatter
    }

    // MARK: Local Currency
    static let localCurrencyFractionDigits: Int = 2

    /// Example: 1234.12
    static let localCurrencyFormatter: NumberFormatter = {
        decimalStyleFormatter(withMinfractionDigits: localCurrencyFractionDigits,
                              maxfractionDigits: localCurrencyFractionDigits,
                              usesGroupingSeparator: false)
    }()

    /// Example: 1,234.12
    static let localCurrencyFormatterWithGroupingSeparator: NumberFormatter = {
        decimalStyleFormatter(withMinfractionDigits: localCurrencyFractionDigits,
                              maxfractionDigits: localCurrencyFractionDigits,
                              usesGroupingSeparator: true)
    }()

    /// A NumberFormatter to be used for Stellar (7 fraction digits).
    /// Example: 1234.1234567
    static let stellarFormatter: NumberFormatter = {
        decimalStyleFormatter(withMinfractionDigits: 0,
                              maxfractionDigits: CryptoCurrency.stellar.maxDisplayableDecimalPlaces,
                              usesGroupingSeparator: false)
    }()

    /// A NumberFormatter to be used for BTC/BCH (8 fraction digits).
    /// Example: 1234.12345678
    static let bitcoinAssetFormatter: NumberFormatter = {
        decimalStyleFormatter(withMinfractionDigits: 0,
                              maxfractionDigits: CryptoCurrency.bitcoin.maxDisplayableDecimalPlaces,
                              usesGroupingSeparator: false)
    }()

    /// A NumberFormatter to be used for BTC/BCH (8 fraction digits).
    /// Example: 1,234.12345678
    static let bitcoinFormatterWithGroupingSeparator: NumberFormatter = {
        decimalStyleFormatter(withMinfractionDigits: 0,
                              maxfractionDigits: CryptoCurrency.bitcoin.maxDisplayableDecimalPlaces,
                              usesGroupingSeparator: true)
    }()
}

// MARK: - Conversions
extension NumberFormatter {
    /// Returns local currency amount with two decimal places (assuming stringFromNumber returns a string)
    @available(*, deprecated, message: "Legacy Send (XLM).")
    static func localCurrencyAmount(fromAmount: Decimal, fiatPerAmount: Decimal) -> String {
        let conversionResult = fromAmount * fiatPerAmount
        let formatter = NumberFormatter.localCurrencyFormatter
        return formatter.string(from: NSDecimalNumber(decimal: conversionResult)) ?? "\(conversionResult)"
    }

    /// Returns crypto with fiat amount in the format of crypto (fiat)
    @available(*, deprecated, message: "Legacy Send (XLM).")
    static func formattedAssetAndFiatAmountWithSymbols(
        fromAmount: Decimal,
        fiatPerAmount: Decimal,
        assetType: CryptoCurrency
    ) -> String {
        let formatter: NumberFormatter
        switch assetType {
        case .stellar:
            formatter = .stellarFormatter
        default:
            /// This method only supports stellar.
            unimplemented()
        }
        let crypto = (formatter.string(from: NSDecimalNumber(decimal: fromAmount)) ?? "\(fromAmount)").appendAssetSymbol(for: assetType)
        let fiat = NumberFormatter.localCurrencyAmount(fromAmount: fromAmount, fiatPerAmount: fiatPerAmount).appendCurrencySymbol()
        return "\(crypto) (\(fiat))"
    }
}
