// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit
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

    /// Example: 1,234.12
    static let localCurrencyFormatterWithGroupingSeparator: NumberFormatter = decimalStyleFormatter(
        withMinfractionDigits: localCurrencyFractionDigits,
        maxfractionDigits: localCurrencyFractionDigits,
        usesGroupingSeparator: true
    )

    /// A NumberFormatter to be used for BTC/BCH (8 fraction digits).
    /// Example: 1,234.12345678
    static let bitcoinFormatterWithGroupingSeparator: NumberFormatter = decimalStyleFormatter(
        withMinfractionDigits: 0,
        maxfractionDigits: CryptoCurrency.bitcoin.displayPrecision,
        usesGroupingSeparator: true
    )
}
