// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol PricesWatchlistRepositoryAPI {
    func watchlist() -> AnyPublisher<Result<Set<String>?, Error>, Never>
}
