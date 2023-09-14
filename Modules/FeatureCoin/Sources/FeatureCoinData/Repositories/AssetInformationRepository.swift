// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCoinDomain
import Foundation
import ToolKit

public class AssetInformationRepository: AssetInformationRepositoryAPI {

    let client: AssetInformationClientAPI
    let cache: CachedValueNew<String, AssetInformation, NetworkError>

    public init(_ client: AssetInformationClientAPI) {
        self.client = client
        let inMemoryCache = InMemoryCache<String, AssetInformation>(
            configuration: .default(),
            refreshControl: PerpetualCacheRefreshControl()
        )
        self.cache = .init(
            cache: inMemoryCache.eraseToAnyCache(),
            fetch: { [client] key in
                client
                    .fetchInfo(key)
                    .map { response in
                        AssetInformation(
                            description: response.description?.trimmingWhitespaces.nilIfEmpty,
                            whitepaper: response.whitepaper?.trimmingWhitespaces.nilIfEmpty,
                            website: response.website?.trimmingWhitespaces.nilIfEmpty
                        )
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    public func fetchInfo(_ currencyCode: String) -> AnyPublisher<AssetInformation, NetworkError> {
        cache.get(key: currencyCode)
    }
}
