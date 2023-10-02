// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

final class AssetSupportService {

    private let repository: NetworkConfigRepositoryAPI

    init(repository: NetworkConfigRepositoryAPI) {
        self.repository = repository
    }

    var configurations: AnyPublisher<[DSCNetworkConfig], Never> {
        .just(repository.dscConfigs)
    }
}
