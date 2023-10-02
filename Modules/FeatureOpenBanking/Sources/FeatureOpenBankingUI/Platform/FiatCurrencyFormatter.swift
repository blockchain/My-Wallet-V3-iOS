// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary

public protocol CurrencyFormatter {
    func displayString(amountMinor: String, currency: String) -> String?
    func displayImage(currency: String) -> ImageLocation?
}

public protocol FiatCurrencyFormatter: CurrencyFormatter {}
public protocol CryptoCurrencyFormatter: CurrencyFormatter {}

public struct NoFormatCurrencyFormatter: FiatCurrencyFormatter, CryptoCurrencyFormatter {
    public init() {}
    public func displayString(amountMinor: String, currency: String) -> String? {
        "\(currency) \(amountMinor)"
    }

    public func displayImage(currency: String) -> ImageLocation? {
        nil
    }
}
