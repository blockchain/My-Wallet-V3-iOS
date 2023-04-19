// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public final class AnnouncementsService: AnnouncementsServiceAPI {

    private let repository: AnnouncementsRepositoryAPI

    public init(
        repository: AnnouncementsRepositoryAPI
    ) {
        self.repository = repository
    }

    public func fetchMessages(for modes: [Announcement.AppMode], force: Bool) async throws -> [Announcement] {
        do {
            return try await repository
                .fetchMessages(force: force)
                .map { announcements in
                    announcements.filter { announcement in
                        modes.contains(announcement.content.appMode)
                    }
                }
                .await()
        } catch {
            throw error
        }
    }

    public func setRead(announcement: Announcement) -> AnyPublisher<Void, Errors.NabuNetworkError> {
        repository.setRead(announcement: announcement)
    }

    public func setTapped(announcement: Announcement) -> AnyPublisher<Void, Errors.NabuNetworkError> {
        repository.setTapped(announcement: announcement)
    }

    public func setDismissed(_ announcement: Announcement, with action: Announcement.Action) -> AnyPublisher<Void, Errors.NabuNetworkError> {
        repository.setDismissed(announcement, with: action)
    }
}
