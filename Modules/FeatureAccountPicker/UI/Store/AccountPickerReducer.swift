// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableArchitectureExtensions

private struct UpdateSubscriptionId: Hashable {}
private struct UpdateHeaderId: Hashable {}

private struct UpdateAccountIds: Hashable {
    let identities: Set<AnyHashable>
}

let accountPickerReducer = Reducer<
    AccountPickerState,
    AccountPickerAction,
    AccountPickerEnvironment
> { state, action, environment in
    switch action {

    case .deselect:
        state.selected = nil
        return .none

    case .rowsLoaded(.success(.accountPickerRowDidTap(let id))):
        state.selected = id
        return .fireAndForget {
            environment.rowSelected(id)
        }
    case .rowsLoaded(.success(.ux(let ux))):
        state.ux = ux
        return .fireAndForget {
            environment.uxSelected(ux)
        }

    case .prefetching(.fetch(indices: let indices)):
        guard case .loaded(.success(let rows)) = state.rows else {
            return .none
        }

        let fetchingRows = indices.map { rows.content[$0] }
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

        var effects: [Effect<AccountPickerAction, Never>] = []

        if !singleAccountIds.isEmpty {
            effects.append(
                environment.updateSingleAccounts(singleAccountIds)
                    .receive(on: environment.mainQueue)
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
                environment.updateAccountGroups(accountGroupIds)
                    .receive(on: environment.mainQueue)
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

        return .merge(effects)

    case .updateSingleAccounts(let values):
        var requeue: Set<Int> = []

        values.forEach { key, value in
            state.fiatBalances[key] = value.fiatBalance.value
            state.cryptoBalances[key] = value.cryptoBalance.value

            if value.fiatBalance == .loading || value.cryptoBalance == .loading,
               case .loaded(.success(let rows)) = state.rows,
               let index = rows.content.indexed().first(where: { $1.id == key })?.index
            {
                requeue.insert(index)
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
               case .loaded(.success(let rows)) = state.rows,
               let index = rows.content.indexed().first(where: { $1.id == key })?.index
            {
                requeue.insert(index)
            }
        }

        if requeue.isEmpty {
            return .none
        } else {
            return Effect(value: .prefetching(.requeue(indices: requeue)))
        }

    case .rowsLoading:
        return .none

    case .updateRows(rows: let rows):
        state.prefetching.validIndices = rows.indices
        state.rows = .loaded(next: .success(Rows(content: rows)))
        return .none

    case .failedToUpdateRows:
        state.rows = .loaded(next: .failure(.testError))
        return .none

    case .updateHeader(header: let header):
        state.header.headerStyle = header
        return .none

    case .failedToUpdateHeader:
        return .none

    case .search(let text):
        state.header.searchText = text
        environment.search(text)
        return .none

    case .onSegmentSelectionChanged(let segmentControlSelection):
        state.header.segmentControlSelection = segmentControlSelection
        return .fireAndForget {
            environment.onSegmentSelectionChanged?(segmentControlSelection)
        }

    case .subscribeToUpdates:
        return .merge(
            environment.sections()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: UpdateSubscriptionId())
                .map { result in
                    switch result {
                    case .success(let rows):
                        return .updateRows(rows)
                    case .failure(let error):
                        return .failedToUpdateRows(error)
                    }
                },
            environment.header()
                .receive(on: environment.mainQueue)
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
.combined(
    with: PrefetchingReducer(
        state: \AccountPickerState.prefetching,
        action: /AccountPickerAction.prefetching,
        environment: { PrefetchingEnvironment(mainQueue: $0.mainQueue) }
    )
)
