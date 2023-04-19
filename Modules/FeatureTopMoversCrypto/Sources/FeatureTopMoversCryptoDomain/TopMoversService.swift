// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Combine
import DIKit
import Foundation
import MoneyKit

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
    func getTopMovers() async throws -> [TopMoverInfo]
}

public final class TopMoversService: TopMoversServiceAPI {
    private let app: AppProtocol

    public init(
        app: AppProtocol = resolve()
    ) {
        self.app = app
    }

    public func getTopMovers() async throws -> [TopMoverInfo] {
        do {
            let tradingCurrencies = try await app.get(blockchain.api.nabu.gateway.simple.buy.pairs.ids, as: [CurrencyPair].self)
            var topMovers: [TopMoverInfo] = []

                for pair in tradingCurrencies
            {
                    guard let currency = pair.base.cryptoCurrency else { continue }
                    let todayPrice = try await app.get(
                        blockchain.api.nabu.gateway.price.at.time[PriceTime.now.id].crypto[pair.base.code].fiat[pair.quote.code].quote.value,
                        as: MoneyValue.self
                    )
                    let yesterdayPrice = try await app.get(
                        blockchain.api.nabu.gateway.price.at.time[PriceTime.oneDay.id].crypto[pair.base.code].fiat[pair.quote.code].quote.value,
                        as: MoneyValue.self
                    )
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
