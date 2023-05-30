// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

/// An API of a generic service which provides fiat currencies for display and trading.
public protocol FiatCurrencyServiceAPI: CurrencyServiceAPI {

    /// A publisher that streams `FiatCurrency` values. This currency should be used **only to display values**, such as the portfolio balance, to the user.
    var displayCurrencyPublisher: AnyPublisher<FiatCurrency, Never> { get }

    /// A publisher that streams `FiatCurrency` values. This currency should be used as **fiat input while transacting** .
    /// E.g. the fiat currency the user can enter amounts in within the Buy, Sell, Swap, or any other transaction flows. Think about this as the currency for the "Enter Amount" screen.
    var tradingCurrencyPublisher: AnyPublisher<FiatCurrency, Never> { get }
}

public protocol SupportedFiatCurrenciesServiceAPI: FiatCurrencyServiceAPI {

    /// A publisher that completes after taking a single value as a `Set` of `FiatCurrency` objects.
    var supportedFiatCurrencies: AnyPublisher<Set<FiatCurrency>, Never> { get }
}

extension FiatCurrencyServiceAPI {

    /// A publisher that completes after taking a single value from the `displayCurrencyPublisher` stream
    public var displayCurrency: AnyPublisher<FiatCurrency, Never> {
        displayCurrencyPublisher
            .first()
            .eraseToAnyPublisher()
    }

    /// A publisher that completes after taking a single value from the `displayCurrencyPublisher` stream
    public var tradingCurrency: AnyPublisher<FiatCurrency, Never> {
        tradingCurrencyPublisher
            .first()
            .eraseToAnyPublisher()
    }
}

extension FiatCurrencyServiceAPI {

    public var currencyPublisher: AnyPublisher<Currency, Never> {
        displayCurrencyPublisher
            .map { $0 as Currency }
            .eraseToAnyPublisher()
    }
}
