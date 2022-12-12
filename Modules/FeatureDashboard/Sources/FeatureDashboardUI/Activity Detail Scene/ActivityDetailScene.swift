// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Foundation
import UnifiedActivityDomain

public struct ActivityDetailScene: ReducerProtocol {
    var activityDetailsService: UnifiedActivityDetailsServiceAPI

    public init(activityDetailsService: UnifiedActivityDetailsServiceAPI) {
        self.activityDetailsService = activityDetailsService
    }

    public enum Action: Equatable {
        case onAppear
        case onCloseTapped
        case onActivityDetailsFetched(TaskResult<ActivityDetail.GroupedItems>)
    }

    public struct State: Equatable {
        var items: ActivityDetail.GroupedItems?
        var activityEntry: ActivityEntry

        public init(activityEntry: ActivityEntry) {
            self.activityEntry = activityEntry
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .task { [activityEntry = state.activityEntry] in
                    await .onActivityDetailsFetched(TaskResult {
                        try await activityDetailsService.getActivityDetails(activity: activityEntry)
                    })
                }

            case .onActivityDetailsFetched(.success(let details)):
                state.items = details
                return .none

            case .onCloseTapped:
                return .none

            case .onActivityDetailsFetched(.failure(let error)):
                print(error.localizedDescription)
                return .none
            }
        }
    }
}
