// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExtensions
import Errors

public protocol WatchlistRepositoryAPI {

    func addToWatchlist(
        _ assetCode: String
    ) -> AnyPublisher<Void, NetworkError>

    func removeFromWatchlist(
        _ assetCode: String
    ) -> AnyPublisher<Void, NetworkError>

    func getWatchlist() -> AnyPublisher<Set<String>, NetworkError>
}

// MARK: - Preview Helper

public class PreviewWatchlistRepository: WatchlistRepositoryAPI {

    private let add: AnyPublisher<Void, NetworkError>
    private let remove: AnyPublisher<Void, NetworkError>
    private let get: AnyPublisher<Set<String>, NetworkError>

    public init(
        _ add: AnyPublisher<Void, NetworkError> = .empty(),
        _ remove: AnyPublisher<Void, NetworkError> = .empty(),
        _ get: AnyPublisher<Set<String>, NetworkError> = .empty()
    ) {
        self.add = add
        self.remove = remove
        self.get = get
    }

    public func addToWatchlist(
        _ assetCode: String
    ) -> AnyPublisher<Void, NetworkError> {
        add
    }

    public func removeFromWatchlist(
        _ assetCode: String
    ) -> AnyPublisher<Void, NetworkError> {
        remove
    }

    public func getWatchlist() -> AnyPublisher<Set<String>, NetworkError> {
        get
    }
}
