// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import MoneyKit
import ToolKit

/// A Simple Buy Service that provides the supported pairs for the current Fiat Currency.
public protocol SupportedPairsInteractorServiceAPI: AnyObject {

    var pairs: AnyPublisher<SupportedPairs, Error> { get }

    func fetchSupportedTradingCryptoCurrencies() -> AnyPublisher<[CryptoCurrency], Error>
}

final class SupportedPairsInteractorService: SupportedPairsInteractorServiceAPI {

    // MARK: - Public properties

    var pairs: AnyPublisher<SupportedPairs, Error> {
        fiatCurrencyService
            .tradingCurrencyPublisher
            .flatMap { [pairsService] tradingCurrency in
                pairsService.fetchPairs(
                    for: .only(fiatCurrency: tradingCurrency)
                )
            }
            .eraseError()
            .eraseToAnyPublisher()
    }

    // MARK: - Private properties

    private let pairsService: SupportedPairsServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI

    // MARK: - Setup

    init(
        pairsService: SupportedPairsServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.pairsService = pairsService
        self.fiatCurrencyService = fiatCurrencyService
    }

    func fetchSupportedTradingCryptoCurrencies() -> AnyPublisher<[CryptoCurrency], Error> {
        pairs
            .map(\.cryptoCurrencies)
            .flatMap { [pairsService] cryptoCurrencies -> AnyPublisher<[CryptoCurrency], Error> in
                guard cryptoCurrencies.isEmpty else {
                    return .just(cryptoCurrencies)
                }
                return pairsService
                    .fetchSupportedTradingCryptoCurrencies()
                    .eraseError()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
