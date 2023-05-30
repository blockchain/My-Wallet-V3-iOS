// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors

/// A Service that provides supported trading pairs for Swap.
public protocol TradingPairsServiceAPI {
    var tradingPairs: AnyPublisher<[TradingPair], NabuNetworkError> { get }
}

final class TradingPairsService: TradingPairsServiceAPI {

    var tradingPairs: AnyPublisher<[TradingPair], NabuNetworkError> {
        client.tradingPairs()
            .map {
                $0.compactMap(TradingPair.init)
            }
            .eraseToAnyPublisher()
    }

    private let client: TradingPairsClientAPI

    init(client: TradingPairsClientAPI = resolve()) {
        self.client = client
    }
}
