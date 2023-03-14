// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

final class FiatFormatterProvider {

    /// A singleton value.
    static let shared = FiatFormatterProvider()

    // MARK: - Private Properties

    private var formatters = [String: NumberFormatter]()

    /// Dispatch queue used for thread safe access to `formatters`.
    private let queue = DispatchQueue(label: "FiatFormatterProvider.queue")

    // MARK: - Internal Methods

    /// Returns a `NumberFormatter`.
    ///
    /// Provides caching for the existing number formatters, with thread safe access.
    ///
    /// - Parameters:
    ///   - locale:            A locale.
    ///   - fiatCurrency:      A fiat currency.
    ///   - maxFractionDigits: The maximum number of digits after the decimal separator.
    func formatter(locale: Locale, fiatCurrency: FiatCurrency, maxFractionDigits: Int) -> NumberFormatter {
        queue.sync { [unowned self] in
            let key = key(locale: locale, fiatCurrency: fiatCurrency, maxFractionDigits: maxFractionDigits)
            if let formatter = formatters[key] {
                return formatter
            } else {
                let formatter = NumberFormatter(
                    locale: locale,
                    currencyCode: fiatCurrency.displayCode,
                    maxFractionDigits: maxFractionDigits
                )
                formatters[key] = formatter

                return formatter
            }
        }
    }

    // MARK: - Private Methods

    /// Creates a caching key.
    ///
    /// - Parameters:
    ///   - locale:            A locale.
    ///   - fiatCurrency:      A fiat currency.
    ///   - maxFractionDigits: The maximum number of digits after the decimal separator.
    private func key(locale: Locale, fiatCurrency: FiatCurrency, maxFractionDigits: Int) -> String {
        "\(locale.identifier)_\(fiatCurrency.code)_\(maxFractionDigits)"
    }
}
