// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Foundation
import MoneyKit
import PlatformKit

public struct TopMoverInfo: Identifiable, Equatable {
    public var id: String { currency.id }
    public let currency: CryptoCurrency
    public let delta: Decimal?
    public let price: MoneyValue

    public init(
        currency: CryptoCurrency,
        delta: Decimal? = nil,
        price: MoneyValue
    ) {
        self.currency = currency
        self.delta = delta
        self.price = price
    }
}

public protocol TopMoversServiceAPI {
    func topMovers() async throws -> [TopMoverInfo]
}

public final class TopMoversService: TopMoversServiceAPI {
    private let supportedPairsInteractorService: SupportedPairsInteractorServiceAPI
    private let app: AppProtocol

    private var yesterday, now: AnyCancellable?, task: Task<Void, Never>?

    public init(
        app: AppProtocol = resolve(),
        supportedPairsInteractorService: SupportedPairsInteractorServiceAPI = resolve()
    ) {
        self.app = app
        self.supportedPairsInteractorService = supportedPairsInteractorService
    }

    public func topMovers() async throws -> [TopMoverInfo] {
        do {
            let tradingCurrencies = try await supportedPairsInteractorService.fetchSupportedTradingCryptoCurrencies().await()
            var topMovers: [TopMoverInfo] = []

                for currency in tradingCurrencies
            {
                    let todayPrice = try await app.get(blockchain.api.nabu.gateway.price.at.time["now"].crypto[currency.code].fiat.quote.value, as: MoneyValue.self)
                    let yesterdayPrice = try await app.get(blockchain.api.nabu.gateway.price.at.time["yesterday"].crypto[currency.code].fiat.quote.value, as: MoneyValue.self)
                    let delta = try? MoneyValue.delta(yesterdayPrice, todayPrice).roundTo(places: 2) / 100
                    topMovers.append(TopMoverInfo(
                        currency: currency,
                        delta: delta,
                        price: todayPrice
                    )
                    )
            }
            return topMovers
        } catch {
            throw error
        }
    }
}
