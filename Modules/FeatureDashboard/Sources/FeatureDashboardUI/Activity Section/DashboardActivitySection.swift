// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AsyncAlgorithms
import BlockchainNamespace
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureDashboardDomain
import MoneyKit
import PlatformKit
import SwiftUI
import UnifiedActivityDomain

public struct DashboardActivitySection: ReducerProtocol {
    public let app: AppProtocol
    public let activityRepository: UnifiedActivityRepositoryAPI
    public let custodialActivityRepository: CustodialActivityRepositoryAPI

    public init(
        app: AppProtocol,
        activityRepository: UnifiedActivityRepositoryAPI,
        custodialActivityRepository: CustodialActivityRepositoryAPI
    ) {
        self.app = app
        self.activityRepository = activityRepository
        self.custodialActivityRepository = custodialActivityRepository
    }

    public enum Action: Equatable {
        case onAppear
        case onActivityFetched(Result<[ActivityEntry], Never>)
        case onAllActivityTapped
        case onActivityRowTapped(
            id: DashboardActivityRow.State.ID,
            action: DashboardActivityRow.Action
        )
    }

    public struct State: Equatable {
        var activityRows: IdentifiedArrayOf<DashboardActivityRow.State> = []
        let presentedAssetType: PresentedAssetType

        public init(with presentedAssetType: PresentedAssetType) {
            self.presentedAssetType = presentedAssetType
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.presentedAssetType == .custodial {
                    return custodialActivityRepository
                        .activity()
                        .receive(on: DispatchQueue.main)
                        .eraseToEffect { .onActivityFetched($0) }
                } else {
                    return activityRepository
                        .activity
                        .receive(on: DispatchQueue.main)
                        .eraseToEffect { .onActivityFetched(.success($0)) }
                }

            case .onAllActivityTapped:
                return .none
            case .onActivityRowTapped:
                return .none
            case .onActivityFetched(.success(let activity)):
                let maxItems = 5
                let items = Array(activity.prefix(maxItems))
                    .enumerated()
                    .map { offset, item in
                        DashboardActivityRow.State(
                            isLastRow: offset == maxItems - 1,
                            activity: item
                        )
                    }
                state.activityRows = IdentifiedArrayOf(uniqueElements: items)
                return .none
            }
        }
        .forEach(\.activityRows, action: /Action.onActivityRowTapped) {
            DashboardActivityRow(app: self.app)
        }
    }
}
