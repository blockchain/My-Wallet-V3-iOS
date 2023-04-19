// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

extension DependencyContainer {

    // MARK: - FeatureAddressSearchData Module

    public static var featureAnnouncementsDomain = module {

        single {
            AnnouncementsService(
                repository: DIKit.resolve()
            ) as AnnouncementsServiceAPI
        }
    }
}
