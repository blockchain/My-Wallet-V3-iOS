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
        formatter.roundingMode = .down
        return formatter
    }

    // MARK: Local Currency
    static let localCurrencyFractionDigits: Int = 2

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
    static let assetFractionDigits: Int = 8
    static let stellarFractionDigits: Int = 7

    // Example: 1234.12345678
    static let assetFormatter: NumberFormatter = {
        return decimalStyleFormatter(withMinfractionDigits: 0,
                                     maxfractionDigits: assetFractionDigits,
                                     usesGroupingSeparator: false)
    }()

    // TODO: genericize
    static let stellarFormatter: NumberFormatter = {
        return decimalStyleFormatter(withMinfractionDigits: 0,
                                     maxfractionDigits: stellarFractionDigits,
                                     usesGroupingSeparator: false)
    }()

    // Example: 1,234.12345678
    static let assetFormatterWithGroupingSeparator: NumberFormatter = {
        return decimalStyleFormatter(withMinfractionDigits: 0,
                                     maxfractionDigits: assetFractionDigits,
                                     usesGroupingSeparator: true)
    }()

    // Used to create QR code string from amount
    // Used to convert values from returned from APIs
    static let assetFormatterWithUSLocale: NumberFormatter = {
        let formatter = decimalStyleFormatter(withMinfractionDigits: 0,
                                              maxfractionDigits: assetFractionDigits,
                                              usesGroupingSeparator: false)
        formatter.locale = Locale(identifier: Constants.Locales.englishUS)
        return formatter
    }()
}

// MARK: - Conversions
extension NumberFormatter {
    // Returns local currency amount with two decimal places (assuming stringFromNumber returns a string)
    static func localCurrencyAmount(fromAmount: Decimal, fiatPerAmount: Decimal) -> String {
        let conversionResult = fromAmount * fiatPerAmount
        let formatter = NumberFormatter.localCurrencyFormatter
        return formatter.string(from: NSDecimalNumber(decimal: conversionResult)) ?? "\(conversionResult)"
    }

    // Returns asset type amount with correct number of decimal places (currently 7 or 8 depending on asset type) (assuming stringFromNumber returns a string)
    @objc static func assetTypeAmount(
        fromAmount: Decimal,
        fiatPerAmount: Decimal,
        assetType: AssetType
    ) -> String {
        let conversionResult = fromAmount / fiatPerAmount
        let formatter = assetType == .stellar ? NumberFormatter.stellarFormatter : NumberFormatter.assetFormatter
        return formatter.string(from: NSDecimalNumber(decimal: conversionResult)) ?? "\(conversionResult)"
    }

    // Returns crypto with fiat amount in the format of
    // crypto (fiat)
    static func formattedAssetAndFiatAmountWithSymbols(
        fromAmount: Decimal,
        fiatPerAmount: Decimal,
        assetType: AssetType
    ) -> String {
        let formatter = assetType == .stellar ? NumberFormatter.stellarFormatter : NumberFormatter.assetFormatter
        let crypto = (formatter.string(from: NSDecimalNumber(decimal: fromAmount)) ?? "\(fromAmount)").appendAssetSymbol(for: assetType)
        let fiat = NumberFormatter.localCurrencyAmount(fromAmount: fromAmount, fiatPerAmount: fiatPerAmount).appendCurrencySymbol()
        return "\(crypto) (\(fiat))"
    }

    /// Returns an amount of a whole crypto unit (e.g. BTC) from the smallest
    /// integer value (e.g. satoshis)
    ///
    /// - Parameters:
    ///   - amount: the integer value (e.g. satoshi)
    ///   - assetType: the asset type
    /// - Returns: the concrete AssetAddress
    static func integerToWholeUnit(
        amount: Int,
        assetType: AssetType
    ) -> Decimal? {
        let decimalAmount = Decimal(amount)
        let integerPerUnit: Int
        switch assetType {
        case .bitcoin:
            integerPerUnit = Int(Constants.Conversions.satoshi)
        case .stellar:
            integerPerUnit = Constants.Conversions.stroopsInXlm
        default:
            Logger.shared.error("Asset type conversion not yet supported by this method")
            return nil
        }
        let decimalConversion = Decimal(integerPerUnit)
        let wholeUnit = decimalAmount / decimalConversion
        return wholeUnit
    }
}
