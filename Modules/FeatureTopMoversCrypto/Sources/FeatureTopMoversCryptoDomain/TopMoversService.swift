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
    func getTopMovers() -> AsyncThrowingStream<[TopMoverInfo], Error>
}

public final class TopMoversService: TopMoversServiceAPI {
    private let app: AppProtocol

    public init(app: AppProtocol = resolve()) {
        self.app = app
    }

    public func getTopMovers() -> AsyncThrowingStream<[TopMoverInfo], Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for await pairs in app.stream(blockchain.api.nabu.gateway.simple.buy.pairs.ids, as: [CurrencyPair].self) {
                        guard let pairs = pairs.value else { continue }
                        var movers = [TopMoverInfo]()
                        for pair in pairs {
                            guard let currency = pair.base.cryptoCurrency else { continue }
                            let price = try await app.get(blockchain.api.nabu.gateway.price.crypto[pair.base.code].fiat[pair.quote.code].quote.value, as: MoneyValue.self)
                            let delta = try await app.get(blockchain.api.nabu.gateway.price.crypto[pair.base.code].fiat[pair.quote.code].delta.since.yesterday, as: Double?.self)
                            movers.append(TopMoverInfo(currency: currency, delta: delta.map { Decimal($0) }, price: price))
                        }
                        continuation.yield(movers)
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
