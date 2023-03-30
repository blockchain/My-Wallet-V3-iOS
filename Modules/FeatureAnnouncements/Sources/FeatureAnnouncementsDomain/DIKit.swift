import Combine
import DIKit
import FeatureAnnouncementsDomain
import NetworkKit
import ToolKit

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
