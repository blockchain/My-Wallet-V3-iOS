// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import GRDB
import GRDBQuery

struct InDiskEntityRequest<T: Equatable & Codable>: Queryable {

    // MARK: - Queryable Implementation

    static var defaultValue: [InDiskEntity<T>] { [] }

    var id: String

    func publisher(in appDatabase: AppDatabase) -> AnyPublisher<[InDiskEntity<T>], Error> {
        // Build the publisher from the general-purpose read-only access granted by `appDatabase.databaseReader`.
        // Some apps will prefer to call a dedicated method of `appDatabase`.
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(
                in: appDatabase.dbReader,
                // The `.immediate` scheduling feeds the view right on
                // subscription, and avoids an undesired animation when the
                // application starts.
                scheduling: .immediate
            )
            .eraseToAnyPublisher()
    }

    // This method is not required by Queryable, but it makes it easier
    // to test PlayerRequest.
    func fetchValue(_ db: Database) throws -> [InDiskEntity<T>] {
        try InDiskEntity<T>
            .filter(id: id)
            .fetchAll(db)
    }
}
