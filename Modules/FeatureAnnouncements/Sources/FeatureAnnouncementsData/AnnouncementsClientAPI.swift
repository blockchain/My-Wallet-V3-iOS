// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureAnnouncementsDomain
import Foundation

public protocol AnnouncementsClientAPI {
    func fetchMessages() -> AnyPublisher<[Announcement], NabuNetworkError>
    func setRead(announcement: Announcement) -> AnyPublisher<Void, NabuNetworkError>
    func setTapped(announcement: Announcement) -> AnyPublisher<Void, NabuNetworkError>
    func setDismissed(
        _ announcement: Announcement,
        with action: Announcement.Action
    ) -> AnyPublisher<Void, NabuNetworkError>
}
