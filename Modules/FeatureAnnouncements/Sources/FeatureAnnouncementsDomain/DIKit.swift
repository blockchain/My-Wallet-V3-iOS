// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

extension DependencyContainer {

    // MARK: - FeatureAddressSearchData Module

    public static var featureAnnouncementsDomain = module {

        single {
            AnnouncementsService(
                app: DIKit.resolve(),
                repository: DIKit.resolve()
            ) as AnnouncementsServiceAPI
        }
    }
}
