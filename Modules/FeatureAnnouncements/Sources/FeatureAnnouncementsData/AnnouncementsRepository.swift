// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureAnnouncementsDomain
import Foundation
import ToolKit

final class AnnouncementsRepository: AnnouncementsRepositoryAPI {

    private struct Key: Hashable {}
    private let client: AnnouncementsClientAPI

    private let cachedValue: CachedValueNew<Key, [Announcement], NabuNetworkError>
    private let cache: AnyCache<Key, [Announcement]>

    init(client: AnnouncementsClientAPI) {
        self.client = client

        let cache: AnyCache<Key, [Announcement]> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: .minutes(15))
        ).eraseToAnyCache()

        self.cache = cache
        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ in
                client.fetchMessages()
            }
        )
    }

    func fetchMessages(force: Bool) -> AnyPublisher<[Announcement], NabuNetworkError> {
        cachedValue.get(key: Key(), forceFetch: force)
    }

    func setRead(announcement: Announcement) -> AnyPublisher<Void, NabuNetworkError> {
        client.setRead(announcement: announcement)
    }

    func setTapped(announcement: Announcement) -> AnyPublisher<Void, NabuNetworkError> {
        client
            .setTapped(announcement: announcement)
            .flatMap { [weak self] _ -> AnyPublisher<Void, NabuNetworkError> in
                guard let self else {
                    return .empty()
                }
                return remove(announcement: announcement)
            }
            .eraseToAnyPublisher()
    }

    func setDismissed(
        _ announcement: Announcement,
        with action: Announcement.Action
    ) -> AnyPublisher<Void, NabuNetworkError> {
        client
            .setDismissed(announcement, with: action)
            .flatMap { [weak self] _ -> AnyPublisher<Void, NabuNetworkError> in
                guard let self else {
                    return .empty()
                }
                return remove(announcement: announcement)
            }
            .eraseToAnyPublisher()
    }

    private func remove(announcement: Announcement) -> AnyPublisher<Void, NabuNetworkError> {
        cachedValue
            .get(key: Key())
            .flatMap { [cache] announcements in
                cache.set(announcements.filter { $0 != announcement }, for: Key())
            }
            .mapToVoid()
            .replaceError(with: ())
            .setFailureType(to: NabuNetworkError.self)
            .eraseToAnyPublisher()
    }
}
