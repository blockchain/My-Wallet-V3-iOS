// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineSchedulers
import Errors
import Foundation
import SwiftUI

public class AccountPickerEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>

    // Effects / Output
    let rowSelected: (AccountPickerRow.ID) -> Void
    let uxSelected: (UX.Dialog) -> Void
    let backButtonTapped: () -> Void
    let closeButtonTapped: () -> Void
    let onSegmentSelectionChanged: ((Tag) -> Void)?
    let search: (String?) -> Void

    // State / Input
    let sections: () -> AnyPublisher<[AccountPickerRow], Never>

    let updateSingleAccounts: (Set<AnyHashable>)
        -> AnyPublisher<[AnyHashable: AccountPickerRow.SingleAccount.Balances], Error>

    let updateAccountGroups: (Set<AnyHashable>)
        -> AnyPublisher<[AnyHashable: AccountPickerRow.AccountGroup.Balances], Error>

    let header: () -> AnyPublisher<HeaderStyle, Error>

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        rowSelected: @escaping (AccountPickerRow.ID) -> Void,
        uxSelected: @escaping (UX.Dialog) -> Void,
        backButtonTapped: @escaping () -> Void,
        closeButtonTapped: @escaping () -> Void,
        search: @escaping (String?) -> Void,
        sections: @escaping () -> AnyPublisher<[AccountPickerRow], Never>,
        updateSingleAccounts: @escaping (Set<AnyHashable>) -> AnyPublisher<[AnyHashable: AccountPickerRow.SingleAccount.Balances], Error>,
        updateAccountGroups: @escaping (Set<AnyHashable>) -> AnyPublisher<[AnyHashable: AccountPickerRow.AccountGroup.Balances], Error>,
        header: @escaping () -> AnyPublisher<HeaderStyle, Error>,
        onSegmentSelectionChanged: ((Tag) -> Void)?
    ) {
        self.mainQueue = mainQueue
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
}
