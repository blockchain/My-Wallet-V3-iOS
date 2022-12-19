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
    let activityRepository: UnifiedActivityRepositoryAPI
    let custodialActivityService: CustodialActivityServiceAPI

    public init(
        activityRepository: UnifiedActivityRepositoryAPI,
        custodialActivityService: CustodialActivityServiceAPI,
        app: AppProtocol
    ) {
        self.activityRepository = activityRepository
        self.custodialActivityService = custodialActivityService
        self.app = app
    }

    public enum Action: Equatable, BindableAction {
        case onAppear
        case onCloseTapped
        case onActivityFetched([ActivityEntry])
        case binding(BindingAction<State>)
    }

    public struct State: Equatable {
        var presentedAssetType: PresentedAssetType
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

        var pendingResults: [ActivityEntry] {
            let results: [ActivityEntry] = searchResults ?? []
            return results.filter { $0.state == .pending }
        }

        var resultsGroupedByDate: [Date: [ActivityEntry]] {
            let empty: [Date: [ActivityEntry]] = [:]
            let results: [ActivityEntry] = searchResults ?? []
            return results.reduce(into: empty) { acc, cur in
                let components = Calendar.current.dateComponents([.year, .month], from: cur.date)
                if let date = Calendar.current.date(from: components) {
                    let existing = acc[date] ?? []
                    acc[date] = existing + [cur]
                }
            }
        }

        var headers: [Date] {
            resultsGroupedByDate.map(\.key).sorted(by: { $0 > $1 })
        }

        public init(with assetType: PresentedAssetType) {
            self.presentedAssetType = assetType
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.presentedAssetType == .custodial {
                    return .run { send in
                        await send(.onActivityFetched(await custodialActivityService.getActivity()))
                    }
                } else {
                    return activityRepository
                        .activity
                        .receive(on: DispatchQueue.main)
                        .eraseToEffect { .onActivityFetched($0) }
                }

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
