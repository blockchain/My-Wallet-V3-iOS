// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Combine
import DIKit
import Foundation
import MoneyKit


public protocol TopMoversServiceAPI {
//    func getTopMovers() -> AsyncThrowingStream<[TopMoverInfo], Error>
    func alternativeTopMovers() ->  AsyncThrowingStream<[TopMoverInfo], Error>
}

public final class TopMoversService: TopMoversServiceAPI {
    private let app: AppProtocol
    private let priceRepository: PriceRepositoryAPI
    public init(app: AppProtocol = resolve(),
                priceRepository: PriceRepositoryAPI) {
        self.app = app
        self.priceRepository = priceRepository
    }

    public func alternativeTopMovers() -> AsyncThrowingStream<[TopMoverInfo], Error> {
        AsyncThrowingStream<[TopMoverInfo], Error> { continuation in
            let cancellable = priceRepository
                .topMovers(currency: .EUR)
                .sink { completion in
                switch completion {
                case .finished:
                    continuation.finish()
                case .failure(let error):
                    continuation.finish(throwing: error)
                }
            } receiveValue: { value in
                switch value {
                case .success(let value):
                    print("💪 service got value \(value)")
                    continuation.yield(value)
                case .failure(let error):
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { @Sendable _ in
                cancellable.cancel()
            }
        }

    }
//    public func getTopMovers() -> AsyncThrowingStream<[TopMoverInfo], Error> {
//
//        AsyncThrowingStream { continuation in
//            let task = Task {
//                do {
//                    for await pairs in app.stream(blockchain.api.nabu.gateway.simple.buy.pairs.ids, as: [CurrencyPair].self) {
//                        guard let pairs = pairs.value else {
//                            continuation.yield([])
//                            continue
//                        }
//                        let movers = try await withThrowingTaskGroup(of: TopMoverInfo.self) { [app] group in
//                            for pair in pairs {
//                                guard let currency = pair.base.cryptoCurrency else { continue }
//                                group.addTask {
//                                    let price = try await app.get(blockchain.api.nabu.gateway.price.crypto[pair.base.code].fiat[pair.quote.code].quote.value, as: MoneyValue.self)
//                                    let delta = try await app.get(blockchain.api.nabu.gateway.price.crypto[pair.base.code].fiat[pair.quote.code].delta.since.yesterday, as: Double?.self)
//                                    return TopMoverInfo(currency: currency,
//                                                        delta: delta.map { Decimal($0) },
//                                                        price: price)
//                                }
//                            }
//
//
//                            var collected = [TopMoverInfo]()
//                            for try await value in group {
//                                collected.append(value)
//                            }
//                            return collected
//                        }

//                        continuation.yield(movers)
//                    }
//                } catch {
//                    continuation.finish(throwing: error)
//                }
//            }
//
//            continuation.onTermination = { _ in task.cancel() }
//        }
//    }
}
