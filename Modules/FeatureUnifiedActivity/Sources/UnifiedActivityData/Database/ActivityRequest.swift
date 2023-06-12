// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import GRDB
import GRDBQuery
import UnifiedActivityDomain

struct ActivityEntityRequest: Queryable {

    enum Sort {
        case timestampDescending

        var ordering: SQLOrdering {
            switch self {
            case .timestampDescending:
                return Column(DatabaseColumn.timestamp.rawValue).desc
            }
        }
    }

    enum StateFilter {
        case all
        case pendingAndConfirming

        var filtering: SQLSpecificExpressible? {
            switch self {
            case .all:
                return nil
            case .pendingAndConfirming:
                return Column(DatabaseColumn.state.rawValue) == ActivityState.pending.rawValue
                    || Column(DatabaseColumn.state.rawValue) == ActivityState.confirming.rawValue
            }
        }
    }

    let sort: Sort
    let stateFilter: StateFilter

    init(
        sort: Sort = .timestampDescending,
        stateFilter: StateFilter
    ) {
        self.sort = sort
        self.stateFilter = stateFilter
    }

    // MARK: - Queryable Implementation

    static var defaultValue: [ActivityEntity] { [] }

    func publisher(in appDatabase: AppDatabaseAPI) -> AnyPublisher<[ActivityEntity], Error> {
        // Build the publisher from the general-purpose read-only access granted by `appDatabase.databaseReader`.
        // Some apps will prefer to call a dedicated method of `appDatabase`.
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(
                in: appDatabase.databaseReader,
                // The `.immediate` scheduling feeds the view right on
                // subscription, and avoids an undesired animation when the
                // application starts.
                scheduling: .immediate
            )
            .eraseToAnyPublisher()
    }

    // This method is not required by Queryable, but it makes it easier
    // to test PlayerRequest.
    func fetchValue(_ db: Database) throws -> [ActivityEntity] {
        try query.fetchAll(db)
    }

    private var query: QueryInterfaceRequest<ActivityEntity> {
        var result: QueryInterfaceRequest<ActivityEntity> = ActivityEntity
            .order(sort.ordering)
        if let stateFilter = stateFilter.filtering {
            result = result
                .filter(stateFilter)
        }
        return result
    }
}
