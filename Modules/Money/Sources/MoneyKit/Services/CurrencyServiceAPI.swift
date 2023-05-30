// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol CurrencyServiceAPI: AnyObject {

    /// A publisher that streams `FiatCurrency` values
    var currencyPublisher: AnyPublisher<Currency, Never> { get }

    /// A publisher that streams a single `FiatCurrency` value
    var currency: AnyPublisher<Currency, Never> { get }
}

extension CurrencyServiceAPI {

    public var currency: AnyPublisher<Currency, Never> {
        currencyPublisher
            .first()
            .eraseToAnyPublisher()
    }
}
