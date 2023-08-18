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
        case onExternalTradingEnabled(Bool)
    }

    public struct State: Equatable {
        var items: ActivityDetail.GroupedItems?
        var activityEntry: ActivityEntry
        let placeholderItems: ActivityDetail.GroupedItems
        var isExternalTradingEnabled: Bool = false

        public init(activityEntry: ActivityEntry) {
            self.activityEntry = activityEntry
            self.placeholderItems = ActivityDetail.placeholderItems
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.items = state.placeholderItems
                return .run { [activityEntry = state.activityEntry, app] send in
                    let isExternalTradingEnabled = (try? await app.get(blockchain.app.is.external.brokerage, as: Bool.self)) ?? false
                    await send(.onExternalTradingEnabled(isExternalTradingEnabled))

                    let activityDetails = await TaskResult {
                        await app.mode() == .trading ?
                        try await custodialActivityDetailsService.getActivityDetails(for: activityEntry) :
                        try await nonCustodialActivityDetailsService.getActivityDetails(activity: activityEntry)
                    }
                    await send(.onActivityDetailsFetched(activityDetails))
                }

            case .onActivityDetailsFetched(.success(let details)):
                state.items = details
                return .none

            case .onExternalTradingEnabled(let active):
                state.isExternalTradingEnabled = active
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
