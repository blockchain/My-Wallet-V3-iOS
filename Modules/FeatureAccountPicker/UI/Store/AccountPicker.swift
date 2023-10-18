// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineSchedulers
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import Errors
import Foundation
import SwiftUI

private struct UpdateSubscriptionId: Hashable {}
private struct UpdateHeaderId: Hashable {}

private struct UpdateAccountIds: Hashable {
    let identities: Set<AnyHashable>
}

public struct AccountPicker: Reducer {
    public typealias State = AccountPickerState

    public typealias Action = AccountPickerAction
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let app: AppProtocol

    // Effects / Output
    let rowSelected: (AccountPickerRow.ID) -> Void
    let uxSelected: (UX.Dialog) -> Void
    let backButtonTapped: () -> Void
    let closeButtonTapped: () -> Void
    let onSegmentSelectionChanged: ((Tag) -> Void)?
    let search: (String) -> Void

    // State / Input
    let sections: () -> AnyPublisher<[AccountPickerSection], Never>

    let updateSingleAccounts: (Set<AnyHashable>)
        -> AnyPublisher<[AnyHashable: AccountPickerRow.SingleAccount.Balances], Error>

    let updateAccountGroups: (Set<AnyHashable>)
        -> AnyPublisher<[AnyHashable: AccountPickerRow.AccountGroup.Balances], Error>

    let header: () -> AnyPublisher<HeaderStyle, Error>

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        app: AppProtocol,
        rowSelected: @escaping (AccountPickerRow.ID) -> Void,
        uxSelected: @escaping (UX.Dialog) -> Void,
        backButtonTapped: @escaping () -> Void,
        closeButtonTapped: @escaping () -> Void,
        search: @escaping (String) -> Void,
        sections: @escaping () -> AnyPublisher<[AccountPickerSection], Never>,
        updateSingleAccounts: @escaping (Set<AnyHashable>) -> AnyPublisher<[AnyHashable: AccountPickerRow.SingleAccount.Balances], Error>,
        updateAccountGroups: @escaping (Set<AnyHashable>) -> AnyPublisher<[AnyHashable: AccountPickerRow.AccountGroup.Balances], Error>,
        header: @escaping () -> AnyPublisher<HeaderStyle, Error>,
        onSegmentSelectionChanged: ((Tag) -> Void)?
    ) {
        self.mainQueue = mainQueue
        self.app = app
        self.rowSelected = rowSelected
        self.uxSelected = uxSelected
        self.backButtonTapped = backButtonTapped
        self.closeButtonTapped = closeButtonTapped
        self.search = search
        self.sections = sections
        self.updateSingleAccounts = updateSingleAccounts
        self.updateAccountGroups = updateAccountGroups
        self.header = header
        self.onSegmentSelectionChanged = onSegmentSelectionChanged
    }

    public var body: some ReducerOf<Self> {
        Scope<
            AccountPicker.State,
            AccountPicker.Action,
            PrefetchingReducer
        >(
            state: \.prefetching,
            action: /AccountPickerAction.prefetching
        ) {
            PrefetchingReducer(mainQueue: mainQueue)
        }

        Reduce { state, action in
            switch action {

            case .deselect:
                state.selected = nil
                return .none

            case .rowsLoaded(.success(.accountPickerRowDidTap(let id))):
                state.selected = id
                rowSelected(id)
                return .none
            case .rowsLoaded(.success(.ux(let ux))):
                state.ux = ux
                uxSelected(ux)
                return .none

            case .prefetching(.fetch(indices: let indices)):
                guard case .loaded(.success(let sections)) = state.sections else {
                    return .none
                }

                var effects: [Effect<AccountPickerAction>] = []

                for section in sections.content {
                    if case .accounts(let rows) = section {
                        let fetchingRows = indices.map { rows[$0] }
                        let singleAccountIds = Set(
                            fetchingRows
                                .filter(\.isSingleAccount)
                                .map(\.id)
                        )

                        let accountGroupIds = Set(
                            fetchingRows
                                .filter(\.isAccountGroup)
                                .map(\.id)
                        )

                        if !singleAccountIds.isEmpty {
                            effects.append(
                                .publisher {
                                    updateSingleAccounts(singleAccountIds)
                                        .receive(on: mainQueue)
                                        .map { balances in
                                            .updateSingleAccounts(balances)
                                        }
                                        .catch { _ in .prefetching(.requeue(indices: indices)) }
                                }
                                .cancellable(id: UpdateAccountIds(identities: singleAccountIds), cancelInFlight: true)
                            )
                        }

                        if !accountGroupIds.isEmpty {
                            effects.append(
                                .publisher {
                                    updateAccountGroups(accountGroupIds)
                                        .receive(on: mainQueue)
                                        .map { balances in
                                            .updateAccountGroups(balances)
                                        }
                                        .catch { _ in .prefetching(.requeue(indices: indices)) }
                                }
                                .cancellable(id: UpdateAccountIds(identities: accountGroupIds), cancelInFlight: true)
                            )
                        }
                    }
                }

                return .merge(effects)

            case .updateSingleAccounts(let values):
                var requeue: Set<Int> = []

                values.forEach { key, value in
                    state.fiatBalances[key] = value.fiatBalance.value
                    state.cryptoBalances[key] = value.cryptoBalance.value

                    if value.fiatBalance == .loading || value.cryptoBalance == .loading,
                       case .loaded(.success(let sections)) = state.sections
                    {
                        for section in sections.content {
                            if case .accounts(let rows) = section,
                               let index = rows.indexed().first(where: { $1.id == key })?.index
                            {
                                requeue.insert(index)
                            }
                        }
                    }
                }

                if requeue.isEmpty {
                    return .none
                } else {
                    return Effect.send(.prefetching(.requeue(indices: requeue)))
                }

            case .updateAccountGroups(let values):
                var requeue: Set<Int> = []

                values.forEach { key, value in
                    state.fiatBalances[key] = value.fiatBalance.value
                    state.currencyCodes[key] = value.currencyCode.value

                    if value.fiatBalance == .loading || value.currencyCode == .loading,
                       case .loaded(.success(let sections)) = state.sections
                    {
                        for section in sections.content {
                            if case .accounts(let rows) = section,
                               let index = rows.indexed().first(where: { $1.id == key })?.index
                            {
                                requeue.insert(index)
                            }
                        }
                    }
                }

                if requeue.isEmpty {
                    return .none
                } else {
                    return Effect.send(.prefetching(.requeue(indices: requeue)))
                }

            case .rowsLoading:
                return .none

            case .updateSections(sections: let sections):
                for section in sections {
                    if case .accounts(let rows) = section {
                        state.prefetching.validIndices = rows.indices
                    }
                }
                let sections = Sections(content: sections)
                state.sections = .loaded(next: .success(sections))
                return .none

            case .failedToUpdateRows:
                state.sections = .loaded(next: .failure(.testError))
                return .none

            case .updateHeader(header: let header):
                state.header.headerStyle = header
                return .none

            case .failedToUpdateHeader:
                return .none

            case .search(let text):
                state.header.searchText = text
                search(text)
            return .none

            case .onSegmentSelectionChanged(let segmentControlSelection):
                state.header.segmentControlSelection = segmentControlSelection
                onSegmentSelectionChanged?(segmentControlSelection)
                return .none

            case .subscribeToUpdates:
                return .merge(
                    .publisher {
                        sections()
                            .receive(on: mainQueue)
                            .map { section in
                                .updateSections(section)
                            }
                    }
                    .cancellable(id: UpdateSubscriptionId()),
                    .publisher {
                        header()
                            .receive(on: mainQueue)
                            .map { header in
                                .updateHeader(header)
                            }
                            .catch { error in .failedToUpdateHeader(error) }
                    }
                    .cancellable(id: UpdateHeaderId(), cancelInFlight: true)
                )

            default:
                return .none
            }
        }
    }
}
