// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import ComposableArchitectureExtensions
import ComposableNavigation
import DIKit
import FeatureDashboardDomain
import Foundation
import Localization
import MoneyKit
import PlatformKit
import SwiftExtensions
import SwiftUI
import UnifiedActivityDomain

public struct AllActivityScene: ReducerProtocol {
    public let app: AppProtocol
    let activityRepository: UnifiedActivityRepositoryAPI
    let custodialActivityRepository: CustodialActivityRepositoryAPI

    public init(
        activityRepository: UnifiedActivityRepositoryAPI,
        custodialActivityRepository: CustodialActivityRepositoryAPI,
        app: AppProtocol
    ) {
        self.activityRepository = activityRepository
        self.custodialActivityRepository = custodialActivityRepository
        self.app = app
    }

    public enum Action: Equatable, BindableAction {
        case onAppear
        case onCloseTapped
        case onActivityFetched(Result<[ActivityEntry], Never>)
        case binding(BindingAction<State>)
        case onPendingInfoTapped
    }

    public struct State: Equatable {
        var presentedAssetType: PresentedAssetType
        var activityResults: [ActivityEntry]?
        @BindableState var pendingInfoPresented: Bool = false
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
                if state.presentedAssetType.isCustodial {
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
            case .onPendingInfoTapped:
                state.pendingInfoPresented.toggle()
                return .none

            case .onActivityFetched(.success(let activity)):
                state.activityResults = activity
                return .none

            case .binding, .onCloseTapped:
                return .none
            }
        }
    }
}

extension ActivityEntry: Identifiable {}
extension LeafItemType {
    var text: String {
        switch self {
        case .text(let text):
            return text.value
        case .button(let button):
            return button.text
        case .badge(let badge):
            return badge.value
        }
    }
}

extension [ActivityEntry] {
    func filtered(by searchText: String, using algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: true)) -> [Element] {
        filter { entry in
            entry.network.distance(between: searchText, using: algorithm) == 0 ||

            entry.item.leading
                .map(\.text)
                .compactMap({ text in
                    text.distance(between: searchText, using: algorithm) == 0 ? true : nil
                }).isNotEmpty ||

            entry.item.trailing
                .map(\.text)
                .compactMap({ text in
                    text.distance(between: searchText, using: algorithm) == 0 ? true : nil
                }).isNotEmpty
        }
    }
}
