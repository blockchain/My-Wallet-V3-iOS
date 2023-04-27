// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

/// A precision level for formatting a `CryptoValue` into a `String`.
public enum CryptoPrecision: String {

    /// The currency's display precision.
    case short

    /// The currency's full precision.
    case long

    /// Gets the maximum number of digits after the decimal separator, based on the current precision.
    ///
    /// - Parameter currency: A crypto currency.
    func maxFractionDigits(for currency: CryptoCurrency) -> Int {
        switch self {
        case .long:
            return currency.storePrecision
        case .short:
            return currency.displayPrecision
        }
    }
}

public final class CryptoFormatterProvider {

    /// A singleton value.
    static let shared = CryptoFormatterProvider()

    // MARK: - Private Properties

    private var formatters = [String: CryptoFormatter]()

    /// Dispatch queue used for thread safe access to `formatters`.
    private let queue = DispatchQueue(label: "CryptoFormatterProvider.queue.\(UUID().uuidString)")

    // MARK: - Public Methods

    /// Returns a `CryptoFormatter`.
    ///
    /// Provides caching for the existing crypto formatters, with thread safe access.
    ///
    /// - Parameters:
    ///   - locale:            A locale.
    ///   - cryptoCurrency:    A crypto currency.
    ///   - minFractionDigits: The minimum number of digits after the decimal separator.
    ///   - precision:         A precision level.
    public func formatter(
        locale: Locale,
        cryptoCurrency: CryptoCurrency,
        minFractionDigits: Int = 1,
        withPrecision precision: CryptoPrecision
    ) -> CryptoFormatter {
        queue.sync { [unowned self] in
            let key = key(
                locale: locale,
                cryptoCurrency: cryptoCurrency,
                minFractionDigits: minFractionDigits,
                precision: precision
            )
            if let formatter = formatters[key] {
                return formatter
            } else {
                let formatter = CryptoFormatter(
                    locale: locale,
                    cryptoCurrency: cryptoCurrency,
                    minFractionDigits: minFractionDigits,
                    withPrecision: precision
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
    ///   - cryptoCurrency:    A crypto currency.
    ///   - minFractionDigits: The minimum number of digits after the decimal separator.
    ///   - precision:         A precision level.
    private func key(
        locale: Locale,
        cryptoCurrency: CryptoCurrency,
        minFractionDigits: Int,
        precision: CryptoPrecision
    ) -> String {
        "\(locale.identifier)_\(cryptoCurrency.code)_\(minFractionDigits)_\(precision)"
    }
}

public final class CryptoFormatter {

    // MARK: - Private Properties

    private let formatter: NumberFormatter

    /// The associated crypto currency.
    private let cryptoCurrency: CryptoCurrency

    // MARK: - Setup

    /// Creates a crypto formatter.
    ///
    /// - Parameters:
    ///   - locale:            A locale.
    ///   - cryptoCurrency:    A crypto currency
    ///   - minFractionDigits: The minimum number of digits after the decimal separator.
    ///   - precision:         A precision level.
    public init(
        locale: Locale,
        cryptoCurrency: CryptoCurrency,
        minFractionDigits: Int,
        withPrecision precision: CryptoPrecision
    ) {
        self.formatter = .cryptoFormatter(
            locale: locale,
            minFractionDigits: minFractionDigits,
            maxFractionDigits: precision.maxFractionDigits(for: cryptoCurrency)
        )
        self.cryptoCurrency = cryptoCurrency
    }

    // MARK: - Public Methods

    /// Returns a string containing the formatted amount, optionally including the symbol.
    ///
    /// - Parameters:
    ///   - amount:        An amount in major units.
    ///   - includeSymbol: Whether the symbol should be included.
    public func format(
        major amount: Decimal,
        includeSymbol: Bool = false
    ) -> String {
        var formattedString = formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "\(amount)"
        if includeSymbol {
            formattedString += " " + cryptoCurrency.displayCode
        }
        return formattedString
    }

    /// Returns a string containing the formatted amount, optionally including the symbol.
    ///
    /// - Parameters:
    ///   - amount:        An amount in minor units.
    ///   - includeSymbol: Whether the symbol should be included.
    public func format(
        minor amount: BigInt,
        includeSymbol: Bool = false
    ) -> String {
        let majorAmount = amount.toDecimalMajor(
            baseDecimalPlaces: cryptoCurrency.precision,
            roundingDecimalPlaces: cryptoCurrency.precision
        )

        return format(major: majorAmount, includeSymbol: includeSymbol)
    }
}

extension NumberFormatter {

    /// Creates a crypto number formatter.
    ///
    /// - Parameters:
    ///   - locale:            A locale.
    ///   - minFractionDigits: The minimum number of digits after the decimal separator.
    ///   - maxFractionDigits: The maximum number of digits after the decimal separator.
    public static func cryptoFormatter(locale: Locale, minFractionDigits: Int, maxFractionDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = minFractionDigits
        formatter.maximumFractionDigits = maxFractionDigits
        formatter.roundingMode = .down
        return formatter
    }
}
