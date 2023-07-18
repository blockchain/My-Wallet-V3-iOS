// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineExtensions
import DelegatedSelfCustodyDomain
import NetworkKit
import ToolKit
import UnifiedActivityDomain

final class UnifiedActivityRepository: UnifiedActivityRepositoryAPI {

    var activity: AnyPublisher<[ActivityEntry], Never> {
        allEntityRequest
            .publisher(in: appDatabase)
            .subscribe(on: DispatchQueue.main)
            .map(\.activityEntries)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    var pendingActivity: AnyPublisher<[ActivityEntry], Never> {
        pendingEntityRequest
            .publisher(in: appDatabase)
            .subscribe(on: DispatchQueue.main)
            .map(\.activityEntries)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    private let appDatabase: AppDatabaseAPI
    private let allEntityRequest: ActivityEntityRequest
    private let pendingEntityRequest: ActivityEntityRequest

    init(
        appDatabase: AppDatabaseAPI,
        allEntityRequest: ActivityEntityRequest,
        pendingEntityRequest: ActivityEntityRequest
    ) {
        self.appDatabase = appDatabase
        self.allEntityRequest = allEntityRequest
        self.pendingEntityRequest = pendingEntityRequest
    }
}

extension [ActivityEntity] {
    var activityEntries: [ActivityEntry] {
        compactMap { item -> ActivityEntry? in
            let data = Data(item.json.utf8)
            let decoder = JSONDecoder()
            return try? decoder.decode(ActivityEntry.self, from: data)
        }
    }
}
