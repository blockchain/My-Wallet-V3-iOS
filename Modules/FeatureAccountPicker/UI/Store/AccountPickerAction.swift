// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import ComposableArchitectureExtensions
import Errors
import ErrorsUI
import FeatureDashboardUI
import SwiftUI

public enum AccountPickerAction {
    case rowsLoaded(LoadedRowsAction)
    case rowsLoading(LoadingRowsAction)

    case subscribeToUpdates
    case deselect

    case updateSections(_ section: [AccountPickerSection])
    case failedToUpdateRows(Error)

    case updateHeader(_ header: HeaderStyle)
    case failedToUpdateHeader(Error)
    case topMoversAction(DashboardTopMoversSection.Action)

    case search(String)
    case onSegmentSelectionChanged(Tag)

    case prefetching(PrefetchingAction)

    case updateSingleAccounts([AnyHashable: AccountPickerRow.SingleAccount.Balances])

    case updateAccountGroups([AnyHashable: AccountPickerRow.AccountGroup.Balances])
}

public enum LoadedRowsAction {
    case success(SuccessRowsAction)
    case failure(FailureRowsAction)
}

public enum LoadingRowsAction {}

public enum SuccessRowsAction {
    case accountPickerRowDidTap(AccountPickerRow.ID)
    case ux(UX.Dialog)
}

public enum FailureRowsAction {}
