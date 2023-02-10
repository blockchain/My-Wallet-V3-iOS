// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import ComposableArchitectureExtensions
import Errors
import ErrorsUI
import SwiftUI

enum AccountPickerAction {
    case rowsLoaded(LoadedRowsAction)
    case rowsLoading(LoadingRowsAction)

    case subscribeToUpdates
    case deselect

    case updateRows(_ rows: [AccountPickerRow])
    case failedToUpdateRows(Error)

    case updateHeader(_ header: HeaderStyle)
    case failedToUpdateHeader(Error)

    case search(String?)
    case onSegmentSelectionChanged(Tag)

    case prefetching(PrefetchingAction)

    case updateSingleAccounts([AnyHashable: AccountPickerRow.SingleAccount.Balances])

    case updateAccountGroups([AnyHashable: AccountPickerRow.AccountGroup.Balances])
}

enum LoadedRowsAction {
    case success(SuccessRowsAction)
    case failure(FailureRowsAction)
}

enum LoadingRowsAction {}

enum SuccessRowsAction {
    case accountPickerRowDidTap(AccountPickerRow.ID)
    case ux(UX.Dialog)
}

enum FailureRowsAction {}
