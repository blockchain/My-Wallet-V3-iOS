import Combine
import DIKit
import FeatureAnnouncementsDomain
import NetworkKit
import ToolKit

extension DependencyContainer {

    // MARK: - FeatureAddressSearchData Module

    public static var featureAnnouncementsData = module {
        factory {
            AnnouncementsClient(
                deviceInfo: DIKit.resolve(),
                networkAdapter: DIKit.resolve(),
                requestBuilder: RequestBuilder(
                    config: .iterableConfig,
                    headers: ["api-key": InfoDictionaryHelper.value(for: .iterableApiKey)]
                ),
                userService: DIKit.resolve()
            ) as AnnouncementsClientAPI
        }

        single {
            AnnouncementsRepository(
                client: DIKit.resolve()
            ) as AnnouncementsRepositoryAPI
        }
    }
}
