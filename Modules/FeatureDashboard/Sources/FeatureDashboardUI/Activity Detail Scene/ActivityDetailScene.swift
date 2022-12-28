// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import FeatureDashboardDomain
import Foundation
import UnifiedActivityDomain

public struct ActivityDetailScene: ReducerProtocol {
    private var app: AppProtocol
    var nonCustodialActivityDetailsService: UnifiedActivityDetailsServiceAPI
    var custodialActivityDetailsService: CustodialActivityDetailsServiceAPI

    public init(
        app: AppProtocol,
        activityDetailsService: UnifiedActivityDetailsServiceAPI,
        custodialActivityDetailsService: CustodialActivityDetailsServiceAPI
    ) {
        self.app = app
        self.nonCustodialActivityDetailsService = activityDetailsService
        self.custodialActivityDetailsService = custodialActivityDetailsService
    }

    public enum Action: Equatable {
        case onAppear
        case onCloseTapped
        case onActivityDetailsFetched(TaskResult<ActivityDetail.GroupedItems?>)
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
                return .task { [activityEntry = state.activityEntry, app] in
                    await .onActivityDetailsFetched(TaskResult {
                        await app.mode() == .trading ?
                        try await custodialActivityDetailsService.getActivityDetails(for: activityEntry) :
                        try await nonCustodialActivityDetailsService.getActivityDetails(activity: activityEntry)
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
