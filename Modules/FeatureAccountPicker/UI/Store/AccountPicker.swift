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

public struct AccountPicker: ReducerProtocol {
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

    public var body: some ReducerProtocol<State, Action> {
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
                return .fireAndForget {
                    rowSelected(id)
                }
            case .rowsLoaded(.success(.ux(let ux))):
                state.ux = ux
                return .fireAndForget {
                    uxSelected(ux)
                }

            case .prefetching(.fetch(indices: let indices)):
                guard case .loaded(.success(let sections)) = state.sections else {
                    return .none
                }

                var effects: [Effect<AccountPickerAction, Never>] = []

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
                                updateSingleAccounts(singleAccountIds)
                                    .receive(on: mainQueue)
                                    .catchToEffect()
                                    .cancellable(id: UpdateAccountIds(identities: singleAccountIds), cancelInFlight: true)
                                    .map { result in
                                        switch result {
                                        case .success(let balances):
                                            return .updateSingleAccounts(balances)
                                        case .failure:
                                            return .prefetching(.requeue(indices: indices))
                                        }
                                    }
                            )
                        }

                        if !accountGroupIds.isEmpty {
                            effects.append(
                                updateAccountGroups(accountGroupIds)
                                    .receive(on: mainQueue)
                                    .catchToEffect()
                                    .cancellable(id: UpdateAccountIds(identities: accountGroupIds), cancelInFlight: true)
                                    .map { result in
                                        switch result {
                                        case .success(let balances):
                                            return .updateAccountGroups(balances)
                                        case .failure:
                                            return .prefetching(.requeue(indices: indices))
                                        }
                                    }
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
                    return Effect(value: .prefetching(.requeue(indices: requeue)))
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
                    return Effect(value: .prefetching(.requeue(indices: requeue)))
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
                return .fireAndForget {
                    onSegmentSelectionChanged?(segmentControlSelection)
                }

            case .subscribeToUpdates:
                return .merge(
                    sections()
                        .receive(on: mainQueue)
                        .catchToEffect()
                        .cancellable(id: UpdateSubscriptionId())
                        .map { result in
                            switch result {
                            case .success(let section):
                                return .updateSections(section)
                            case .failure(let error):
                                return .failedToUpdateRows(error)
                            }
                        },
                    header()
                        .receive(on: mainQueue)
                        .catchToEffect()
                        .cancellable(id: UpdateHeaderId(), cancelInFlight: true)
                        .map { result in
                            switch result {
                            case .success(let header):
                                return .updateHeader(header)
                            case .failure(let error):
                                return .failedToUpdateHeader(error)
                            }
                        }
                )

            default:
                return .none
            }
        }
    }
}
