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
    private let priceRepository: PriceRepositoryAPI
    public init(
        priceRepository: PriceRepositoryAPI
    ) {
        self.priceRepository = priceRepository
    }

    public func topMovers(
        for appMode: AppMode,
        with fiatCurrency: FiatCurrency
    ) -> AsyncThrowingStream<[TopMoverInfo], Error> {
       return AsyncThrowingStream(
        priceRepository
            .topMovers(currency: fiatCurrency,
                                  custodialOnly: appMode == .trading)
            .get()
            .values
       )
    }
}
