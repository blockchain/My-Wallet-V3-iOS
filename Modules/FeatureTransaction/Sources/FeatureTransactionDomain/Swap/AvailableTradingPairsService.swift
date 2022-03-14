// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import RxToolKit
import ToolKit

public protocol AvailableTradingPairsServiceAPI {

    /// Streams cached `[OrderPair]`, or fetch from
    /// remote if they are not cached
    var availableTradingPairs: Single<[OrderPair]> { get }

    /// Fetches `[OrderPair]` from remote
    func fetchTradingPairs() -> Single<[OrderPair]>
}

final class AvailableTradingPairsService: AvailableTradingPairsServiceAPI {

    // MARK: - AvailableTradingPairsServiceAPI

    var availableTradingPairs: Single<[OrderPair]> {
        _ = setup
        return pairsCachedValue.valueSingle
    }

    // MARK: - CachedValue

    private lazy var setup: Void = pairsCachedValue.setFetch(weak: self) { (self) in
        self.repository.availableOrderPairs
            .asObservable()
            .asSingle()
    }

    // MARK: - Properties

    private let pairsCachedValue = CachedValue<[OrderPair]>(
        configuration: .onSubscription(schedulerIdentifier: "AvailableTradingPairsService")
    )

    private let repository: AvailablePairsRepositoryAPI

    // MARK: - Setup

    init(repository: AvailablePairsRepositoryAPI = resolve()) {
        self.repository = repository
    }

    func fetchTradingPairs() -> Single<[OrderPair]> {
        _ = setup
        return pairsCachedValue.fetchValue
    }
}
