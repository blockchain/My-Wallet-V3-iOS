// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import ComposableArchitectureExtensions
import ComposableNavigation
import DIKit
import FeatureDashboardDomain
import Foundation
import MoneyKit
import PlatformKit
import SwiftExtensions
import SwiftUI
import UnifiedActivityDomain

public struct AllActivityScene: ReducerProtocol {
    public let app: AppProtocol
    public let activityRepository: UnifiedActivityRepositoryAPI

    public init(
        activityRepository: UnifiedActivityRepositoryAPI,
        app: AppProtocol
    ) {
        self.activityRepository = activityRepository
        self.app = app
    }

    public enum Action: Equatable, BindableAction {
        case onAppear
        case onCloseTapped
        case onActivityFetched([ActivityEntry])
        case binding(BindingAction<State>)
    }

    public struct State: Equatable {
        var activityResults: [ActivityEntry]?
        @BindableState var searchText: String = ""
        @BindableState var isSearching: Bool = false
        @BindableState var filterPresented: Bool = false
        @BindableState var showSmallBalancesFilterIsOn: Bool = false

        var searchResults: [ActivityEntry]? {
            if searchText.isEmpty {
                return activityResults
            } else {
                return activityResults?.filtered(by: searchText)
            }
        }

        public init() {}
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return activityRepository
                    .activity
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect { .onActivityFetched($0) }

            case .onActivityFetched(let activity):
                state.activityResults = activity
                return .none

            case .binding, .onCloseTapped:
                return .none
            }
        }
    }
}

extension ActivityEntry: Identifiable {}

extension [ActivityEntry] {
    func filtered(by searchText: String, using algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: true)) -> [Element] {
        filter {
            $0.network.distance(between: searchText, using: algorithm) == 0
        }
    }
}
