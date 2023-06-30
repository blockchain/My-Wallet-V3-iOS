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
        var isLoading: Bool = false
        let placeholderItems: [ActivityEntry]
        @BindingState var pendingInfoPresented: Bool = false
        @BindingState var searchText: String = ""
        @BindingState var isSearching: Bool = false
        @BindingState var filterPresented: Bool = false
        @BindingState var showSmallBalancesFilterIsOn: Bool = false

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
            self.placeholderItems = providePlaceholderItems()
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                if state.activityResults == nil {
                    state.activityResults = state.placeholderItems
                }
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
                state.isLoading = false
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
                .compactMap { text in
                    text.distance(between: searchText, using: algorithm) == 0 ? true : nil
                }.isNotEmpty ||

            entry.item.trailing
                .map(\.text)
                .compactMap { text in
                    text.distance(between: searchText, using: algorithm) == 0 ? true : nil
                }.isNotEmpty
        }
    }
}

func providePlaceholderItems() -> [ActivityEntry] {
    ["a", "b", "c", "d", "e"].map { id in
        .init(
            id: "a",
            type: .buy,
            network: "bitcoin-\(id)",
            pubKey: id,
            externalUrl: "",
            item: .init(leading: [
                .text(.init(value: "\(id) this is a title", style: .init(typography: .paragraph2, color: .title))),
                .text(.init(value: "subtitle", style: .init(typography: .caption1, color: .title)))
            ], trailing: [
                .text(.init(value: "\(id) another title", style: .init(typography: .paragraph2, color: .title))),
                .text(.init(value: "and subtitle", style: .init(typography: .caption1, color: .title)))
            ]),
            state: .unknown,
            timestamp: Date().timeIntervalSinceNow,
            transactionType: nil
        )
    }
}
