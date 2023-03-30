// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol AnnouncementsRepositoryAPI {
    func fetchMessages(force: Bool) -> AnyPublisher<[Announcement], NabuNetworkError>
    func setRead(announcement: Announcement) -> AnyPublisher<Void, NabuNetworkError>
    func setTapped(announcement: Announcement) -> AnyPublisher<Void, NabuNetworkError>
    func setDismissed(
        _ announcement: Announcement,
        with action: Announcement.Action
    ) -> AnyPublisher<Void, NabuNetworkError>
}

public extension AnnouncementsRepositoryAPI {
    var messages: AnyPublisher<[Announcement], NabuNetworkError> {
        fetchMessages(force: false)
    }
}
