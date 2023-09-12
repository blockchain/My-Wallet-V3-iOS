// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Combine
import DIKit
import Foundation
import MoneyKit

public protocol TopMoversServiceAPI {
    func topMovers(
        for appMode: AppMode,
        with fiatCurrency: FiatCurrency
    ) -> AsyncThrowingStream<[TopMoverInfo], Error>
}

public final class TopMoversService: TopMoversServiceAPI {
    private let app: AppProtocol
    private let priceRepository: PriceRepositoryAPI
    public init(
        app: AppProtocol = resolve(),
        priceRepository: PriceRepositoryAPI
    ) {
        self.app = app
        self.priceRepository = priceRepository
    }

    public func topMovers(
        for appMode: AppMode,
        with fiatCurrency: FiatCurrency
    ) -> AsyncThrowingStream<[TopMoverInfo], Error> {
        AsyncThrowingStream<[TopMoverInfo], Error> { continuation in
            let cancellable = priceRepository
                .topMovers(
                    currency: fiatCurrency,
                    custodialOnly: appMode == .trading
                )
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
}
