// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureAnnouncementsDomain
import FeatureAnnouncementsData
import DIKit
import PlatformKit

// MARK: - Blockchain Module

extension DependencyContainer {
    static var blockchainFeatureAnnouncements = module {
        factory { () -> AnnouncementsEmailProviderAPI in
            AnnouncementsEmailProvider(userService: DIKit.resolve())
        }
    }
}

final class AnnouncementsEmailProvider: AnnouncementsEmailProviderAPI {
    private let userService: NabuUserServiceAPI

    init(userService: NabuUserServiceAPI) {
        self.userService = userService
    }

    var email: AnyPublisher<String, NabuNetworkError> {
        userService
            .user
            .map(\.email.address)
            .mapError(\.nabu)
            .eraseToAnyPublisher()
    }
}
