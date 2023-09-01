import Combine
import DIKit
import Errors
import FeatureAnnouncementsDomain
import Localization
import RemoteNotificationsKit
import UIKit

final class RemoteNotificationAnnouncementService: AnnouncementsServiceAPI {

    private var bag: Set<AnyCancellable> = []
    private let notificationAuthorizer: RemoteNotificationAuthorizing

    init(
        notificationAuthorizer: RemoteNotificationAuthorizing = DIKit.resolve()
    ) {
        self.notificationAuthorizer = notificationAuthorizer
    }

    func fetchMessages(for modes: [FeatureAnnouncementsDomain.Announcement.AppMode], force: Bool) async throws -> [FeatureAnnouncementsDomain.Announcement] {
        let status = try await notificationAuthorizer.status.await()
        guard status == .notDetermined else {
            return []
        }
        return [Announcement.apns]
    }

    func setRead(announcement: FeatureAnnouncementsDomain.Announcement) -> AnyPublisher<Void, Errors.NabuNetworkError> {
        .just(())
    }

    func setTapped(announcement: FeatureAnnouncementsDomain.Announcement) -> AnyPublisher<Void, Errors.NabuNetworkError> {
        .just(())
    }

    func setDismissed(_ announcement: FeatureAnnouncementsDomain.Announcement, with action: FeatureAnnouncementsDomain.Announcement.Action) -> AnyPublisher<Void, Errors.NabuNetworkError> {
        .just(())
    }

    func handle(_ announcement: FeatureAnnouncementsDomain.Announcement) -> AnyPublisher<Void, Never> {
        guard announcement == Announcement.apns else {
            return .just(())
        }
        return notificationAuthorizer
            .requestAuthorization()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { _ in
                UIApplication.shared.registerForRemoteNotifications()
            })
            .catch { _ in
                ()
            }
            .eraseToAnyPublisher()
    }
}

private extension Announcement {

    static let apns = Announcement(
        id: "apns",
        createdAt: .now,
        content: Announcement.Content(
            title: LocalizationConstants.Announcements.APNS.title,
            description: LocalizationConstants.Announcements.APNS.message,
            icon: .notification.color(.semantic.title).circle(backgroundColor: .semantic.light).medium(),
            actionUrl: "",
            appMode: .universal
        ),
        priority: 42,
        read: false,
        expiresAt: .distantPast
    )
}
