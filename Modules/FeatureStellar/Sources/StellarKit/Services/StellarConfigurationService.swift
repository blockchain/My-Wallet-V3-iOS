// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ToolKit

protocol StellarConfigurationServiceAPI {
    var configuration: AnyPublisher<StellarConfiguration, Never> { get }
}

final class StellarConfigurationService: StellarConfigurationServiceAPI {

    // MARK: Private Types

    private typealias KeyType = String

    // MARK: Properties

    var configuration: AnyPublisher<StellarConfiguration, Never> {
        cachedValue.get(key: KeyType())
    }

    // MARK: Private Properties

    private let cachedValue: CachedValueNew<KeyType, StellarConfiguration, Never>

    // MARK: Init

    init(app: AppProtocol) {
        let cache: AnyCache<KeyType, StellarConfiguration> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()
        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ -> AnyPublisher<StellarConfiguration, Never> in
                app.publisher(for: blockchain.app.configuration.xlm.horizon.url, as: String.self)
                    .prefix(1)
                    .map { result -> StellarConfiguration in
                        if let value = result.value {
                            return StellarConfiguration(horizonURL: value)
                        }
                        return .Blockchain.production
                    }
                    .replaceError(with: .Blockchain.production)
                    .eraseToAnyPublisher()
            }
        )
    }
}
