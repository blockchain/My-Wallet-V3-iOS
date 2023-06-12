// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExtensions

public protocol UnifiedActivityPersistenceServiceAPI {
    func connect()
}

public protocol UnifiedActivityRepositoryAPI {
    var activity: AnyPublisher<[ActivityEntry], Never> { get }
    var pendingActivity: AnyPublisher<[ActivityEntry], Never> { get }
}

